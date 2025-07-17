//
//  OfferingsListView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 17/07/25.
//

import SwiftUI

struct OfferingsListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var offerings: [String] = [] // Empty list as shown in screenshot
    @State private var showAddOffering = false
    
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
                    
                    Text("Offerings list")
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
                
                // Content Area
                VStack {
                    if offerings.isEmpty {
                        // Empty State
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Text("No offerings available")
                                .font(.body)
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // List of offerings (for future use)
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(offerings, id: \.self) { offering in
                                    HStack {
                                        Text(offering)
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
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                // Add New Offering Button
                Button(action: {
                    showAddOffering = true
                }) {
                    Text("Add new offering")
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
            .sheet(isPresented: $showAddOffering) {
                AddOfferingView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    OfferingsListView()
}
