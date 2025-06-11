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
    @State private var isSupplier = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    // Personal Details Section
                    Section {
                        HStack {
                            Text("Personal Details")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Navigate to personal details
                        }
                    }
                    
                    // Location Section
                    Section {
                        HStack {
                            Text("Share my live location")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $shareLocation)
                                .tint(.blue)
                        }
                    }
                    
                    // Supplier Section
                    Section {
                        HStack {
                            Button(action: {
                                isSupplier.toggle()
                            }) {
                                HStack {
                                    Image(systemName: isSupplier ? "checkmark.square" : "square")
                                        .foregroundColor(.blue)
                                    
                                    Text("I am a supplier")
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("My details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSideMenu = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            // QR Scanner action
                        }) {
                            Image(systemName: "qrcode.viewfinder")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {
                            // Notifications action
                        }) {
                            Image(systemName: "bell")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}