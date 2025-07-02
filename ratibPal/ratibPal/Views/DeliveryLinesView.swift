

import SwiftUI

struct DeliveryLinesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showKebabMenu = false
    @State private var showAddLine = false
    @State private var showRemoveLine = false
    @State private var showOrderLines = false

    var body: some View {
        NavigationView {
            VStack {
                List { Text("Default line") }
                Spacer()
            }
            .navigationTitle("Delivery Lines")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.left") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showKebabMenu.toggle() }) {
                        Image(systemName: "ellipsis")
                    }
                    .actionSheet(isPresented: $showKebabMenu) {
                        ActionSheet(title: Text("Delivery Lines Options"), buttons: [
                            .default(Text("Add Delivery Line")) { showAddLine = true },
                            .default(Text("Remove Delivery Line")) { showRemoveLine = true },
                            .default(Text("Order of Delivery Lines")) { showOrderLines = true },
                            .cancel()
                        ])
                    }
                }
            }
            .sheet(isPresented: $showAddLine) {
                AddDeliveryLineView()
            }
            .sheet(isPresented: $showRemoveLine) {
                RemoveDeliveryLineView()
            }
            .sheet(isPresented: $showOrderLines) {
                OrderDeliveryLinesView()
            }
        }
    }
}

// Placeholder subviews
struct AddDeliveryLineView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var lineName = ""
    var body: some View {
        VStack(spacing: 16) {
            TextField("Line name", text: $lineName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Add") { dismiss() }
        }
        .padding()
    }
}

struct RemoveDeliveryLineView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLine = "Default line"
    var body: some View {
        VStack(spacing: 16) {
            Picker("Select line", selection: $selectedLine) {
                Text("Default line").tag("Default line")
            }
            Button("Remove") { dismiss() }
        }
        .padding()
    }
}

struct OrderDeliveryLinesView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Text("Order Delivery Lines")
        Button("Done") { dismiss() }
            .padding()
    }
}