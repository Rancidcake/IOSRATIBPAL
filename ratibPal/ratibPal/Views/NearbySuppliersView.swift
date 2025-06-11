//
//  NearbySuppliersView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct NearbySuppliersView: View {
    @State private var selectedTab = 0
    
    private let tabs = ["Goods", "Services", "Utilities"]
    
    private let supplierCategories = [
        SupplierCategory(title: "Periodicals", items: ["Newspaper", "Magazine"]),
        SupplierCategory(title: "Food", items: ["Dairy/Bakery", "Meals/snacks", "Nutrition", "Water"])
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Location Header
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                    
                    Text("Home")
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Tab Bar
                HStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabs[index])
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .foregroundColor(selectedTab == index ? .blue : .secondary)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .background(Color(.systemGray6))
                
                // Selected tab indicator
                HStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Rectangle()
                            .fill(selectedTab == index ? .blue : .clear)
                            .frame(height: 2)
                    }
                }
                
                // Content based on selected tab
                if selectedTab == 0 { // Goods
                    List {
                        ForEach(supplierCategories, id: \.title) { category in
                            Section(category.title) {
                                ForEach(category.items, id: \.self) { item in
                                    HStack {
                                        Text(item)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "person.circle")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Handle supplier selection
                                    }
                                }
                            }
                        }
                        
                        // Bottom info section
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Information about existing suppliers and how to connect with them.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        // User profile action
                                    }) {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    // Placeholder for Services and Utilities tabs
                    VStack {
                        Spacer()
                        Text("Coming Soon")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(tabs[selectedTab])
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Nearby Suppliers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}