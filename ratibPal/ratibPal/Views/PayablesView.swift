//
//  PayablesView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import SwiftUI

struct PayablesView: View {
    @State private var selectedSegment = 0
    @State private var expandedSections: Set<String> = []
    
    private let segments = ["Payments Till Now", "All"]
    
    private let paymentSections = [
        PaymentSection(title: "My sources", items: ["Cash", "Cheque", "QR", "My UPI", "My bank"], isExpanded: true),
        PaymentSection(title: "In Clearance", items: [], isExpanded: false),
        PaymentSection(title: "Online", items: ["App", "bilbox UPI", "Link", "Service Fees"], isExpanded: false),
        PaymentSection(title: "Due", items: [], isExpanded: false)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date and Filter Header
                HStack {
                    Text("May 2025 end")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        // Filter action
                    }) {
                        Image(systemName: "line.horizontal.3.decrease")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Segmented Control
                Picker("Payment Type", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Text(segments[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Paid ₹")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("0")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Due ₹")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("0")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                
                // Payment Sections List
                List {
                    ForEach(paymentSections, id: \.title) { section in
                        Section {
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedSections.contains(section.title) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedSections.insert(section.title)
                                        } else {
                                            expandedSections.remove(section.title)
                                        }
                                    }
                                )
                            ) {
                                ForEach(section.items, id: \.self) { item in
                                    HStack {
                                        Text(item)
                                            .padding(.leading)
                                        Spacer()
                                        Text("₹0")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(section.title)
                                        .fontWeight(.medium)
                                    Spacer()
                                    if section.title == "My sources" {
                                        Text("Offline")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Payables")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            expandedSections.insert("My sources")
        }
    }
}