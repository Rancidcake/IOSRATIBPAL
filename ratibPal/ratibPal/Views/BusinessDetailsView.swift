//
//  BusinessDetailsView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 17/07/25.
//

import SwiftUI

struct BusinessDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var businessName = "Faheem Times"
    @State private var businessProfile = ""
    @State private var customerContactNumber = ""
    @State private var agentSupplierContactNumber = ""
    @State private var showManageLocations = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Business Details")
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Image Section
                        VStack(spacing: 16) {
                            Button(action: {
                                // Handle profile image selection
                            }) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    )
                            }
                            .padding(.top, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .padding(.bottom, 16)
                        
                        // Form Fields
                        VStack(spacing: 0) {
                            // Business Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Business Name")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    TextField("Business Name", text: $businessName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Business Profile Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Business Profile")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    TextField("Business Profile", text: $businessProfile)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Contact number for customers Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contact number for customers")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    TextField("Contact number for customers", text: $customerContactNumber)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .keyboardType(.phonePad)
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            
                            // Contact number for agents/suppliers Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contact number for agents / suppliers")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    TextField("Contact number for agents / suppliers", text: $agentSupplierContactNumber)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .keyboardType(.phonePad)
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                        }
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Manage Locations
                        Button(action: {
                            showManageLocations = true
                        }) {
                            HStack {
                                Text("Manage locations")
                                    .foregroundColor(.primary)
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer(minLength: 50)
                    }
                }
                
                // Update Button
                Button(action: {
                    // Handle update action
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Update")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(0)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showManageLocations) {
                BusinessManageLocationsView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    BusinessDetailsView()
}
