//
//  PointOfSaleView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 22/07/25.
//

import SwiftUI

struct PointOfSaleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var cartItems: [CartItem] = []
    @State private var searchText = ""
    @State private var showPOSHistory = false
    @State private var showCustomerLinking = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with back button and date
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showPOSHistory = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Text("13 Jun 2025")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showCustomerLinking = true
                    }) {
                        HStack(spacing: 2) {
                            VStack(spacing: 1) {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 2)
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 2)
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 2)
                            }
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                
                // Store info
                HStack {
                    Text("In store")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("1")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                // Table Header
                HStack {
                    Text("Items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Count")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 60)
                    
                    Text("Price")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 60)
                    
                    Text("Bill Total")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                
                // Cart content
                if cartItems.isEmpty {
                    VStack {
                        Spacer()
                        
                        Text("Cart is empty")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(cartItems) { item in
                            HStack {
                                Text(item.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(item.count)")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(width: 60)
                                
                                Text("₹\(item.price, specifier: "%.0f")")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(width: 60)
                                
                                Text("₹\(item.total, specifier: "%.0f")")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(width: 80)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Search bar at bottom
                HStack {
                    Text("Filter")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    HStack {
                        TextField("Search name", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Scan") {
                            // Scan action
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showPOSHistory) {
            POSHistoryView()
        }
        .sheet(isPresented: $showCustomerLinking) {
            POSCustomerLinkingView()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
}

// MARK: - Cart Item Model
struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let price: Double
    
    var total: Double {
        return Double(count) * price
    }
}

#Preview {
    PointOfSaleView()
}
