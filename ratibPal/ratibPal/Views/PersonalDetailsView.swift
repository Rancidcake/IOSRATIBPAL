//
//  PersonalDetailsView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 17/07/25.
//

import SwiftUI

struct PersonalDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = "Faheem"
    @State private var mobileNumber = "9356763651"
    @State private var emailID = ""
    
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
                    
                    Text("Personal Details")
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
                        // Form Fields
                        VStack(spacing: 0) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    TextField("Name", text: $name)
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
                            
                            // Mobile Number Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mobile Number")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    TextField("Mobile Number", text: $mobileNumber)
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
                            
                            // Email ID Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("e-mail ID")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    TextField("Email ID", text: $emailID)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
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
                            // Navigate to manage locations
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    PersonalDetailsView()
}
