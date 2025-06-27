import SwiftUI

struct DeliveryView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedDate = Date()
    @State private var showMapView = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Delivery Management")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showMapView.toggle() }) {
                            Image(systemName: showMapView ? "list.bullet" : "map")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Date Selector
                    DatePicker("Delivery Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                
                // Delivery Overview Cards
                DeliveryOverviewSection()
                
                // Delivery List or Map
                if showMapView {
                    DeliveryMapView()
                } else {
                    DeliveryListView()
                }
            }
        }
    }
}

struct DeliveryOverviewSection: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                DeliveryStatCard(
                    title: "Scheduled",
                    count: "8",
                    color: .blue,
                    icon: "clock"
                )
                
                DeliveryStatCard(
                    title: "Out for Delivery",
                    count: "3",
                    color: .orange,
                    icon: "truck"
                )
                
                DeliveryStatCard(
                    title: "Delivered",
                    count: "5",
                    color: .green,
                    icon: "checkmark.circle"
                )
                
                DeliveryStatCard(
                    title: "Failed",
                    count: "1",
                    color: .red,
                    icon: "xmark.circle"
                )
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
}

struct DeliveryStatCard: View {
    let title: String
    let count: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(count)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct DeliveryListView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appViewModel.orders.filter { $0.status == .outForDelivery || $0.status == .confirmed }) { order in
                    DeliveryCard(order: order)
                }
            }
            .padding()
        }
    }
}

struct DeliveryCard: View {
    let order: Order
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.customer.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(order.orderNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            // Address
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(order.deliveryAddress.street)
                        .font(.subheadline)
                    
                    Text("\(order.deliveryAddress.city), \(order.deliveryAddress.state) - \(order.deliveryAddress.pinCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Order Summary
            HStack {
                Text("\(order.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("₹\(order.totalAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            // Delivery Time
            if let deliveryDate = order.deliveryDate {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    
                    Text("Scheduled: \(deliveryDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Call customer
                }) {
                    Label("Call", systemImage: "phone")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                }
                
                Button(action: {
                    // View on map
                }) {
                    Label("Map", systemImage: "map")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                Button("Update Status") {
                    showingDetails = true
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingDetails) {
            DeliveryDetailsView(order: order)
        }
    }
}

struct DeliveryMapView: View {
    var body: some View {
        VStack {
            // Placeholder for map view
            ZStack {
                Color.gray.opacity(0.2)
                
                VStack {
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Map View")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Delivery locations will be shown here")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .cornerRadius(12)
            .padding()
        }
    }
}

struct DeliveryDetailsView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus = OrderStatus.confirmed
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Customer Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Customer Information")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(order.customer.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(order.customer.phoneNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Call") {
                                // Handle call
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                        }
                    }
                    
                    Divider()
                    
                    // Delivery Address
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Delivery Address")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.deliveryAddress.street)
                                .font(.subheadline)
                            
                            if let landmark = order.deliveryAddress.landmark {
                                Text("Near: \(landmark)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(order.deliveryAddress.city), \(order.deliveryAddress.state)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("PIN: \(order.deliveryAddress.pinCode)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("View on Map") {
                            // Handle map view
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    }
                    
                    Divider()
                    
                    // Order Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Items")
                            .font(.headline)
                        
                        ForEach(order.items) { item in
                            HStack {
                                Text(item.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("×\(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Update Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Update Delivery Status")
                            .font(.headline)
                        
                        Picker("Status", selection: $selectedStatus) {
                            ForEach(OrderStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Button("Update Status") {
                            // Handle status update
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Delivery Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DeliveryView()
        .environmentObject(AppViewModel())
}