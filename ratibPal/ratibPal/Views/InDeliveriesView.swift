//
//  InDeliveriesView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct InDeliveriesView: View {
    @State private var selectedDate = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with filter
                HStack {
                    Text("All")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        // Balance action
                    }) {
                        Image(systemName: "scalemass")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Calendar Header
                HStack {
                    Button(action: {
                        // Previous month
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        // Next month
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.blue.opacity(0.1))
                
                // Calendar Week View
                VStack {
                    // Week days header
                    HStack {
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar dates (showing current week)
                    HStack {
                        ForEach(7...13, id: \.self) { day in
                            Button(action: {
                                // Select date
                            }) {
                                Text("\(day)")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(day == 11 ? .white : .primary)
                                    .frame(width: 35, height: 35)
                                    .background(day == 11 ? .blue : .clear)
                                    .clipShape(Circle())
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Location sections
                List {
                    Section {
                        HStack {
                            Text("My location not tagged")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Handle location tagging
                        }
                        
                        HStack {
                            Text("Personal Home")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Handle personal home
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("In Deliveries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.blue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}