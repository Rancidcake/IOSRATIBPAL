//
//  POSCustomerLinkingView.swift
//  ratibPal
//
//  Created by GitHub Copilot on 27/07/25.
//

import SwiftUI

struct POSCustomerLinkingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDefaultLine = "Default line"
    @State private var customerName = ""
    @State private var mobileNumber = ""
    @State private var erpUserId = ""
    
    private let defaultLineOptions = ["Default line"]
    
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
                    
                    Text("Bill 1 - linked customer")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                
                // Form Content
                VStack(spacing: 0) {
                    // Default line dropdown
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Menu {
                                ForEach(defaultLineOptions, id: \.self) { option in
                                    Button(option) {
                                        selectedDefaultLine = option
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedDefaultLine)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .background(Color.white)
                    
                    // Customer name field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Customer name", text: $customerName)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                // Add customer action
                            }) {
                                Image(systemName: "person.badge.plus")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .background(Color.white)
                    
                    // Mobile Number and ERP user id fields
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Mobile Number", text: $mobileNumber)
                                .font(.body)
                                .foregroundColor(.primary)
                                .keyboardType(.phonePad)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("ERP user id", text: $erpUserId)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    
                    // Action buttons
                    HStack {
                        Button(action: {
                            // Scan QR action
                        }) {
                            Text("Scan QR")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Print QR action
                        }) {
                            Text("Print QR")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    
                    Spacer()
                    
                    // Update button
                    Button(action: {
                        // Handle update action
                        dismiss()
                    }) {
                        Text("Update")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    POSCustomerLinkingView()
}
