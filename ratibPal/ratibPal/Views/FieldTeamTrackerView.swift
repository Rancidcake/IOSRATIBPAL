//
//  FieldTeamTrackerView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 22/07/25.
//

import SwiftUI
import MapKit

struct FieldTeamTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567), // Pune coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Sample team members data
    @State private var teamMembers: [TeamMember] = [
        TeamMember(id: 1, name: "Sanidhya", coordinate: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567), status: "Unavailable"),
        TeamMember(id: 2, name: "Faheem", coordinate: CLLocationCoordinate2D(latitude: 18.5304, longitude: 73.8467), status: "Available"),
        TeamMember(id: 3, name: "Mayank", coordinate: CLLocationCoordinate2D(latitude: 18.5104, longitude: 73.8667), status: "On Route")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Field team tracker")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible placeholder to center the title
                    Image(systemName: "arrow.left")
                        .opacity(0)
                        .font(.title2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                
                // Team member list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(teamMembers.enumerated()), id: \.element.id) { index, member in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(index + 1).")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(member.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // Status indicator
                                    Circle()
                                        .fill(statusColor(for: member.status))
                                        .frame(width: 12, height: 12)
                                }
                                
                                Text(member.status)
                                    .font(.subheadline)
                                    .foregroundColor(statusColor(for: member.status))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            
                            if index < teamMembers.count - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                
                Divider()
                
                // Map View
                Map(coordinateRegion: $region, annotationItems: teamMembers) { member in
                    MapAnnotation(coordinate: member.coordinate) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(statusColor(for: member.status))
                                    .frame(width: 30, height: 30)
                                
                                Text(String(member.name.prefix(1)))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Text(member.name)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 6)
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
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Helper function to get status color
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "available":
            return .green
        case "unavailable":
            return .orange
        case "on route":
            return .blue
        default:
            return .gray
        }
    }
}

// MARK: - Team Member Model
struct TeamMember: Identifiable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let status: String
}

#Preview {
    FieldTeamTrackerView()
}
