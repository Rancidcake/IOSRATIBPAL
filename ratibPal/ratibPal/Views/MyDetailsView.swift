//
//  MyDetailsView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct MyDetailsView: View {
    @Binding var showSideMenu: Bool
    @State private var shareLocation = false
    @State private var showServiceCharge = true
    @State private var showOtherSuppliers = true
    @State private var amSlotDays = 1
    @State private var noonSlotDays = 1
    @State private var pmSlotDays = 0
    @State private var amEndTime = "05:00 PM"
    @State private var noonEndTime = "midnight"
    @State private var pmEndTime = "10:00 AM"
    @State private var newOrderNoticeDays = 1
    @State private var endOrderNoticeDays = 7
    
    // Navigation states
    @State private var showPersonalDetails = false
    @State private var showBusinessDetails = false
    @State private var showOfferingsList = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Personal Details
                    ProfileMenuItem(
                        title: "Personal Details",
                        hasDisclosure: true
                    ) {
                        showPersonalDetails = true
                    }
                    
                    Divider()
                        .padding(.leading, 16)
                    
                    // Share Location Toggle
                    HStack {
                        Text("Share my live location")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $shareLocation)
                            .tint(.green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    
                    Divider()
                        .padding(.leading, 16)
                    
                    // Business Details
                    ProfileMenuItem(
                        title: "Business Details",
                        hasDisclosure: true
                    ) {
                        showBusinessDetails = true
                    }
                    
                    Divider()
                        .padding(.leading, 16)
                    
                    // Bank Details
                    ProfileMenuItem(
                        title: "Bank Details",
                        hasDisclosure: true
                    ) {
                        // Navigate to bank details
                    }
                    
                    Divider()
                        .padding(.leading, 16)
                    
                    // Offerings List
                    ProfileMenuItem(
                        title: "Offerings list",
                        hasDisclosure: true
                    ) {
                        showOfferingsList = true
                    }
                    
                    Divider()
                        .padding(.leading, 16)
                    
                    // Vehicles List
                    ProfileMenuItem(
                        title: "Vehicles list",
                        hasDisclosure: true
                    ) {
                        // Navigate to vehicles list
                    }
                    
                    // Apply Settings Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Apply settings to my customers")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                        
                        // Show Service Charge Toggle
                        HStack {
                            Text("Show service charge")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $showServiceCharge)
                                .tint(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        
                        // Show Other Suppliers Toggle
                        HStack {
                            Text("Show other suppliers of my business")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $showOtherSuppliers)
                                .tint(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        
                        // Slot Configuration
                        VStack(spacing: 16) {
                            // Headers
                            HStack {
                                Text("Slot")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                Text("Order changes ok before")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                
                                Text("by time")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // AM Slot
                            SlotConfigurationRow(
                                slotName: "AM",
                                days: $amSlotDays,
                                endTime: $amEndTime,
                                isActive: true
                            )
                            
                            // Noon Slot
                            SlotConfigurationRow(
                                slotName: "Noon",
                                days: $noonSlotDays,
                                endTime: $noonEndTime,
                                isActive: false
                            )
                            
                            // PM Slot
                            SlotConfigurationRow(
                                slotName: "PM",
                                days: $pmSlotDays,
                                endTime: $pmEndTime,
                                isActive: false
                            )
                        }
                        .padding(.bottom, 16)
                        .background(Color.white)
                        
                        // Notice Days Settings
                        VStack(spacing: 12) {
                            HStack {
                                Text("Notice(days) for new order from online customer")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            HStack {
                                TextField("1", value: $newOrderNoticeDays, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            HStack {
                                Text("Notice(days) to end order by online customer")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            HStack {
                                TextField("7", value: $endOrderNoticeDays, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .background(Color.white)
                    }
                    
                    Divider()
                        .padding(.leading, 16)
                        .padding(.top, 16)
                    
                    // My Plan
                    ProfileMenuItem(
                        title: "My Plan: Pal Beginner",
                        hasDisclosure: true
                    ) {
                        // Navigate to plan details
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showPersonalDetails) {
                PersonalDetailsView()
            }
            .sheet(isPresented: $showBusinessDetails) {
                BusinessDetailsView()
            }
            .sheet(isPresented: $showOfferingsList) {
                OfferingsListView()
            }
        }
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let title: String
    let hasDisclosure: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
                
                if hasDisclosure {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Slot Configuration Row
struct SlotConfigurationRow: View {
    let slotName: String
    @Binding var days: Int
    @Binding var endTime: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Text(slotName)
                .font(.body)
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .leading)
            
            HStack {
                TextField("\(days)", value: $days, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                
                if isActive {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 3)
                        .padding(.horizontal, 8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 8)
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(endTime)
                .font(.body)
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}