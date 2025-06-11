//
//  SettingsView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var expandedTrouble: Set<Int> = []
    @Environment(\.dismiss) private var dismiss
    
    private let menuItems = [
        MenuItem(title: "Notifications", hasToggle: true, hasDisclosure: false, isToggleOn: true),
        MenuItem(title: "Language Switch"),
        MenuItem(title: "Terms & Conditions"),
        MenuItem(title: "Help"),
        MenuItem(title: "About Us"),
        MenuItem(title: "Contact Us")
    ]
    
    private let troubleshootingItems = [
        "Connection Issues",
        "Payment Problems", 
        "Account Settings"
    ]
    
    var body: some View {
        NavigationView {
            List {
                // Main Settings Section
                Section {
                    ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text(item.title)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if item.hasToggle {
                                Toggle("", isOn: $notificationsEnabled)
                                    .tint(.green)
                            } else if item.hasDisclosure {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !item.hasToggle {
                                // Handle navigation
                            }
                        }
                    }
                }
                
                // Troubleshooting Section
                Section("Troubleshooting") {
                    ForEach(Array(troubleshootingItems.enumerated()), id: \.offset) { index, item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: expandedTrouble.contains(index) ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    if expandedTrouble.contains(index) {
                                        expandedTrouble.remove(index)
                                    } else {
                                        expandedTrouble.insert(index)
                                    }
                                }
                            }
                            
                            if expandedTrouble.contains(index) {
                                Text("Support information for \(item.lowercased()) would appear here.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}