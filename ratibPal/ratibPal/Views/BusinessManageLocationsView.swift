//
//  BusinessManageLocationsView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 27/07/25.
//

import SwiftUI
import MapKit

struct BusinessManageLocationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLocationType = "Area"
    @State private var placeName = ""
    @State private var searchLocation = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Sample location pins
    @State private var locationPins: [LocationPin] = [
        LocationPin(id: 1, coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), name: "Baylands Nature Preserve"),
        LocationPin(id: 2, coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094), name: "Shoreline Park"),
        LocationPin(id: 3, coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294), name: "Googleplex"),
        LocationPin(id: 4, coordinate: CLLocationCoordinate2D(latitude: 37.7549, longitude: -122.4394), name: "Computer History Museum"),
        LocationPin(id: 5, coordinate: CLLocationCoordinate2D(latitude: 37.7449, longitude: -122.4494), name: "99 Ranch Market")
    ]
    
    private let locationTypes = ["Area", "Depot", "Store"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Locations")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add new location
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                
                VStack(spacing: 0) {
                    // Subtitle
                    Text("where you do business")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                    
                    // Location Type Selection
                    HStack(spacing: 12) {
                        ForEach(locationTypes, id: \.self) { type in
                            LocationTypeButton(
                                title: type,
                                isSelected: selectedLocationType == type
                            ) {
                                selectedLocationType = type
                            }
                        }
                        
                        // Place name/no. field
                        HStack {
                            TextField("Place name/no.", text: $placeName)
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(minWidth: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        Button(action: {
                            // Clear place name
                            placeName = ""
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .background(Color.white)
                    
                    // Search Location with distance indicator
                    HStack {
                        TextField("Search your location", text: $searchLocation)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Distance indicator
                        Text("1.0")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.trailing, 8)
                        
                        Button(action: {
                            // Get current location
                        }) {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1),
                        alignment: .bottom
                    )
                    
                    // Map View
                    Map(coordinateRegion: $region, annotationItems: locationPins) { pin in
                        MapAnnotation(coordinate: pin.coordinate) {
                            VStack {
                                if pin.name.contains("Baylands") {
                                    // Green pin for nature preserve
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                        .background(Color.white.clipShape(Circle()))
                                } else if pin.name.contains("Shoreline") {
                                    // Green triangle for park
                                    Image(systemName: "triangle.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                        .background(Color.white.clipShape(Circle()))
                                } else if pin.name.contains("Computer History") {
                                    // Purple pin for museum
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.title2)
                                        .background(Color.white.clipShape(Circle()))
                                } else if pin.name.contains("99 Ranch") {
                                    // Blue pin for market
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                        .background(Color.white.clipShape(Circle()))
                                } else {
                                    // Default blue pin
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                
                                // Location label
                                Text(pin.name)
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Save Button
                    Button(action: {
                        // Handle save action
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    BusinessManageLocationsView()
}
