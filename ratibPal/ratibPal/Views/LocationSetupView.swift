//
//  LocationSetupView.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI
import CoreLocation

struct LocationSetupView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocationType = "H" // H=Home, F=Office, O=Other
    @State private var locationName = ""
    @State private var address = ""
    @State private var city = ""
    
    private let locationTypes = [
        ("H", "Home", "house.fill"),
        ("F", "Office", "building.2.fill"),
        ("O", "Other", "mappin.circle.fill")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        registrationManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Location Setup")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    // Invisible button for alignment
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                    .disabled(true)
                }
                
                // Progress indicator
                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Icon and title
                    VStack(spacing: 20) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 10) {
                            Text("Set Your Location")
                                .font(.title2)
                                .bold()
                            
                            Text("Help us serve you better by setting up your primary location")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Location type selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Location Type")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 15) {
                            ForEach(locationTypes, id: \.0) { type in
                                LocationTypeButton(
                                    code: type.0,
                                    title: type.1,
                                    icon: type.2,
                                    isSelected: selectedLocationType == type.0
                                ) {
                                    selectedLocationType = type.0
                                    if type.0 == "H" {
                                        locationName = "Home"
                                    } else if type.0 == "F" {
                                        locationName = "Office"
                                    } else {
                                        locationName = ""
                                    }
                                }
                            }
                        }
                    }
                    
                    // Location name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter location name", text: $locationName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Address field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your address", text: $address, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3, reservesSpace: true)
                            .autocapitalization(.words)
                    }
                    
                    // City field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("City")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your city", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Current location button
                    Button(action: {
                        locationManager.requestLocation()
                    }) {
                        HStack {
                            if locationManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "location.fill")
                            }
                            Text("Use Current Location")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                    .disabled(locationManager.isLoading)
                    
                    // Location info
                    if let location = locationManager.currentLocation {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Current Coordinates:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Lat: \(location.coordinate.latitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Lng: \(location.coordinate.longitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 30)
            }
            
            // Continue button
            Button(action: {
                Task {
                    await completeLocationSetup()
                }
            }) {
                HStack {
                    if registrationManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Completing...")
                            .foregroundColor(.white)
                    } else {
                        Text("Complete Registration")
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(registrationManager.isLoading || !isFormValid)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Location Error", isPresented: .constant(locationManager.errorMessage != nil)) {
            Button("OK") {
                locationManager.errorMessage = nil
            }
        } message: {
            Text(locationManager.errorMessage ?? "")
        }
        .onChange(of: locationManager.currentLocation) { _, location in
            if let location = location {
                // You can implement reverse geocoding here to populate address and city
                // For now, we'll just note that location is captured
            }
        }
    }
    
    private var isFormValid: Bool {
        !locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func completeLocationSetup() async {
        // Here you would typically save the location data
        // For now, we'll just proceed to completion
        await registrationManager.completeRegistration()
    }
}

// Location Manager
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
