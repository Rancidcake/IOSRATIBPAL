//
//  LocationSetupView.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationSetupView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocationType = "" // Will be set based on user type
    @State private var searchText = ""
    @State private var placeName = ""
    @State private var address = ""
    @State private var editableAddress = "1600 Amphitheatre Pkwy, Mountain View" // New state for editable address
    @State private var city = ""
    @State private var state = ""
    @State private var pinCode = ""
    @State private var currentLocationAddress = "Getting your location..."
    @State private var isCurrentLocationLoading = true
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567), // Pune coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Sample location pins for the map
    @State private var locationPins: [LocationSetupPin] = []
    
    // Location types based on user type
    private var locationTypes: [(String, String)] {
        if registrationManager.isSupplier {
            return [
                ("AREA", "Area"),
                ("WAREHOUSE", "Depot"), 
                ("STORE", "Store")
            ]
        } else {
            return [
                ("H", "Home"),
                ("F", "Office"),
                ("O", "Other")
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Button(action: {
                        registrationManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Locations")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add location action
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                
                Text("where you do business")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Location type selection
                HStack(spacing: 20) {
                    ForEach(locationTypes, id: \.0) { locationType in
                        LocationTypeSelectionButton(
                            code: locationType.0,
                            title: locationType.1,
                            isSelected: selectedLocationType == locationType.0
                        ) {
                            selectedLocationType = locationType.0
                        }
                    }
                    
                    Spacer()
                    
                    // Search field with place name
                    HStack {
                        TextField("Place name/no.", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                        
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                    .frame(width: 120)
                }
                .padding(.horizontal, 20)
                
                // Search location field
                HStack {
                    if isCurrentLocationLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Getting your location...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        TextField("Search your location", text: $currentLocationAddress)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                // Handle location search
                                performLocationSearch()
                            }
                        
                        Button(action: {
                            refreshCurrentLocation()
                        }) {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 18))
                        }
                    }
                    
                    Spacer()
                    
                    // Show manual input hint when user has entered address
                    if !isCurrentLocationLoading && editableAddress != "1600 Amphitheatre Pkwy, Mountain View" && !editableAddress.isEmpty {
                        Text("Manual entry")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal, 20)
                
                // Address display
                HStack {
                    TextField("Enter your address", text: $editableAddress)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: editableAddress) { newValue in
                            // If user is manually editing the address, stop location loading
                            if newValue != "1600 Amphitheatre Pkwy, Mountain View" && !newValue.isEmpty {
                                isCurrentLocationLoading = false
                            }
                        }
                    
                    Spacer()
                    
                    Text("1.0")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 10)
            .background(Color(.systemBackground))
            
            // Map View
            Map(coordinateRegion: $region, annotationItems: locationPins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text(pin.name)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .onTapGesture { location in
                // Handle map tap to set location
                let coordinate = region.center
                updateLocationFromCoordinate(coordinate)
            }
            
            // Save Button
            Button(action: {
                Task {
                    await saveLocation()
                }
            }) {
                HStack {
                    if registrationManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Saving...")
                            .foregroundColor(.white)
                    } else {
                        Text("Save")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(0)
            }
            .disabled(registrationManager.isLoading || !isFormValid)
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialValues()
            requestLocationPermission()
        }
        .onChange(of: locationManager.currentLocation) { newLocation in
            if let location = newLocation {
                updateRegionAndAddress(for: location)
            }
        }
        .alert("Location Error", isPresented: .constant(locationManager.errorMessage != nil)) {
            Button("OK") {
                locationManager.errorMessage = nil
            }
        } message: {
            Text(locationManager.errorMessage ?? "")
        }
        .alert("Registration Error", isPresented: .constant(registrationManager.errorMessage != nil)) {
            Button("OK") {
                registrationManager.errorMessage = nil
            }
        } message: {
            Text(registrationManager.errorMessage ?? "")
        }
    }
    
    private var isFormValid: Bool {
        // Allow saving if location type is selected and address is provided (either manually or via location)
        // Be more lenient - just need location type and some address
        !selectedLocationType.isEmpty && (
            (!editableAddress.isEmpty && editableAddress != "1600 Amphitheatre Pkwy, Mountain View") ||
            !address.isEmpty
        )
    }
    
    private func setupInitialValues() {
        // Set default location type and sample data
        if registrationManager.isSupplier {
            selectedLocationType = "AREA"
        } else {
            selectedLocationType = "H"
        }
        
        // Initially empty until we get actual location
        address = ""
        city = ""
        state = ""
        pinCode = ""
        
        // Setup sample location pins
        locationPins = [
            LocationSetupPin(id: 1, coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), name: "Baylands Nature Preserve"),
            LocationSetupPin(id: 2, coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094), name: "Shoreline Park"),
            LocationSetupPin(id: 3, coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294), name: "Googleplex"),
            LocationSetupPin(id: 4, coordinate: CLLocationCoordinate2D(latitude: 37.7549, longitude: -122.4394), name: "Computer History Museum"),
            LocationSetupPin(id: 5, coordinate: CLLocationCoordinate2D(latitude: 37.7449, longitude: -122.4494), name: "99 Ranch Market")
        ]
    }
    
    private func requestLocationPermission() {
        isCurrentLocationLoading = true
        locationManager.requestLocation()
    }
    
    private func updateRegionAndAddress(for location: CLLocation) {
        region.center = location.coordinate
        isCurrentLocationLoading = false
        
        // Perform reverse geocoding
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.currentLocationAddress = "Unable to get address"
                    self.address = "Location unavailable"
                }
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    // Update the search field with current location
                    let addressComponents = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.locality
                    ].compactMap { $0 }.joined(separator: " ")
                    
                    self.currentLocationAddress = addressComponents.isEmpty ? "Current Location" : addressComponents
                    
                    // Update form fields
                    self.address = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.subLocality
                    ].compactMap { $0 }.joined(separator: " ")
                    
                    // Update the editable address field as well
                    let fullAddress = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    self.editableAddress = fullAddress.isEmpty ? "1600 Amphitheatre Pkwy, Mountain View" : fullAddress
                    
                    self.city = placemark.locality ?? ""
                    self.state = placemark.administrativeArea ?? ""
                    self.pinCode = placemark.postalCode ?? ""
                }
            } else {
                DispatchQueue.main.async {
                    self.currentLocationAddress = "Current Location"
                    self.address = "Location found"
                }
            }
        }
    }
    
    private func refreshCurrentLocation() {
        isCurrentLocationLoading = true
        currentLocationAddress = "Getting your location..."
        locationManager.requestLocation()
    }
    
    private func performLocationSearch() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(currentLocationAddress) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                DispatchQueue.main.async {
                    self.updateRegionAndAddress(for: location)
                }
            }
        }
    }
    
    private func updateLocationFromCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // Here you would typically do reverse geocoding to get address details
        // For now, we'll use placeholder data
        region.center = coordinate
    }
    
    private func saveLocation() async {
        let coordinate = locationManager.currentLocation?.coordinate ?? region.center
        
        // If user manually entered address and other fields are empty, provide reasonable defaults
        let finalCity = city.isEmpty ? "Unknown City" : city
        let finalState = state.isEmpty ? "Unknown State" : state  
        let finalPinCode = pinCode.isEmpty ? "000000" : pinCode
        
        await registrationManager.addLocation(
            title: placeName.isEmpty ? selectedLocationType : placeName,
            address: editableAddress, // Use the editable address instead
            city: finalCity,
            state: finalState,
            pinCode: finalPinCode,
            locationType: selectedLocationType,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        // If no error, proceed to complete registration
        if registrationManager.errorMessage == nil {
            await registrationManager.completeRegistration()
        }
    }
}

struct LocationTypeSelectionButton: View {
    let code: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .stroke(isSelected ? Color.green : Color.gray, lineWidth: 2)
                    .fill(isSelected ? Color.green : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .primary : .gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// LocationSetupPin model for map annotations
struct LocationSetupPin: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let name: String
}

// Location Manager (keeping existing implementation)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Location services are not enabled"
            return
        }
        
        isLoading = true
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable in Settings."
            isLoading = false
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            errorMessage = "Unknown location authorization status"
            isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Failed to get location: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isLoading = false
            errorMessage = "Location access denied. Please enable in Settings."
        default:
            break
        }
    }
}

#Preview {
    NavigationView {
        LocationSetupView(registrationManager: RegistrationFlowManager())
    }
}
