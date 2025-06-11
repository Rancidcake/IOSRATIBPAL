//
//  ExpenseDiaryView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct ExpenseDiaryView: View {
    @State private var currentDate = Date()
    @State private var expandedSections: Set<String> = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Navigation Header
                HStack {
                    Button(action: {
                        // Previous day
                        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    
                    Text(dateFormatter.string(from: currentDate))
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        // Next day
                        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Collection Till Section
                HStack {
                    Text("Collection Till")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Dual filter dropdowns
                    HStack {
                        Button(action: {
                            // Filter 1
                        }) {
                            HStack {
                                Text("Filter")
                                    .font(.caption)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8))
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            // Filter 2
                        }) {
                            HStack {
                                Text("Filter")
                                    .font(.caption)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8))
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                
                // Column Headers
                HStack {
                    Text("Paid ₹")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Due ₹")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Content List
                List {
                    Section {
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedSections.contains("NO_SOURCE") },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedSections.insert("NO_SOURCE")
                                    } else {
                                        expandedSections.remove("NO_SOURCE")
                                    }
                                }
                            )
                        ) {
                            Text("No entries found")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.leading)
                        } label: {
                            HStack {
                                Text("NO_SOURCE")
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("₹0")
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("₹0")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Expense Diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // More options
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}