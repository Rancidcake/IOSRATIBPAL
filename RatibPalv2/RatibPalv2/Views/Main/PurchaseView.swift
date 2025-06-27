import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Search and Filters
                VStack(spacing: 12) {
                    HStack {
                        Text("Purchase Management")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingFilters = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search orders, customers, products...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                
                // Tab Selection
                Picker("Purchase Tabs", selection: $selectedTab) {
                    Text("New Purchase").tag(0)
                    Text("Active Orders").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    NewPurchaseView()
                        .tag(0)
                    
                    ActiveOrdersView()
                        .tag(1)
                    
                    PurchaseHistoryView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .sheet(isPresented: $showingFilters) {
                FilterView()
            }
        }
    }
}

struct NewPurchaseView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedCustomer: Customer?
    @State private var showingCustomerPicker = false
    @State private var selectedItems: [OrderItem] = []
    @State private var deliveryDate = Date()
    @State private var specialInstructions = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Customer Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Customer")
                        .font(.headline)
                    
                    Button(action: { showingCustomerPicker = true }) {
                        HStack {
                            if let customer = selectedCustomer {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(customer.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(customer.phoneNumber)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("Choose customer")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Product Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Products/Services")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(appViewModel.offerings) { offering in
                            OfferingCard(offering: offering) {
                                addToCart(offering)
                            }
                        }
                    }
                }
                
                // Selected Items
                if !selectedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Order Summary")
                            .font(.headline)
                        
                        ForEach(selectedItems) { item in
                            OrderItemRow(item: item) {
                                removeFromCart(item)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("₹\(selectedItems.reduce(0) { $0 + $1.totalPrice }, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
                
                // Order Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Order Details")
                        .font(.headline)
                    
                    DatePicker("Delivery Date", selection: $deliveryDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Special Instructions")
                            .font(.subheadline)
                        
                        TextEditor(text: $specialInstructions)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Create Order Button
                Button(action: createOrder) {
                    Text("Create Order")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canCreateOrder ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!canCreateOrder)
            }
            .padding()
        }
        .sheet(isPresented: $showingCustomerPicker) {
            CustomerPickerView(selectedCustomer: $selectedCustomer)
        }
    }
    
    private var canCreateOrder: Bool {
        selectedCustomer != nil && !selectedItems.isEmpty
    }
    
    private func addToCart(_ offering: Offering) {
        if let existingIndex = selectedItems.firstIndex(where: { $0.offeringId == offering.id }) {
            selectedItems[existingIndex].quantity += 1
            selectedItems[existingIndex].totalPrice = Double(selectedItems[existingIndex].quantity) * selectedItems[existingIndex].unitPrice
        } else {
            let item = OrderItem(offeringId: offering.id, name: offering.name, quantity: 1, unitPrice: offering.price)
            selectedItems.append(item)
        }
    }
    
    private func removeFromCart(_ item: OrderItem) {
        selectedItems.removeAll { $0.id == item.id }
    }
    
    private func createOrder() {
        guard let customer = selectedCustomer else { return }
        
        var order = Order(customer: customer, items: selectedItems)
        order.deliveryDate = deliveryDate
        order.specialInstructions = specialInstructions
        
        appViewModel.addOrder(order)
        
        // Reset form
        selectedCustomer = nil
        selectedItems = []
        specialInstructions = ""
        deliveryDate = Date()
    }
}

struct OfferingCard: View {
    let offering: Offering
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: offering.category.systemImageName)
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(offering.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(offering.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(offering.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("₹\(offering.price, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderItemRow: View {
    let item: OrderItem
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("₹\(item.unitPrice, specifier: "%.2f") × \(item.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("₹\(item.totalPrice, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ActiveOrdersView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appViewModel.orders.filter { $0.status != .delivered && $0.status != .cancelled }) { order in
                    OrderCard(order: order)
                }
            }
            .padding()
        }
    }
}

struct PurchaseHistoryView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appViewModel.orders) { order in
                    OrderCard(order: order)
                }
            }
            .padding()
        }
    }
}

struct OrderCard: View {
    let order: Order
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Order Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.orderNumber)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(order.customer.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: order.status)
                    
                    Text("₹\(order.totalAmount, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            // Order Details
            HStack {
                Label(order.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let deliveryDate = order.deliveryDate {
                    Label(deliveryDate.formatted(date: .abbreviated, time: .omitted), systemImage: "truck")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack {
                Button("View Details") {
                    showingDetails = true
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
                
                Spacer()
                
                Menu {
                    Button("Edit Order") { }
                    Button("Duplicate Order") { }
                    Button("Cancel Order") { }
                    Button("View Receipt") { }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingDetails) {
            OrderDetailsView(order: order)
        }
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .inProgress: return .yellow
        case .outForDelivery: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

struct CustomerPickerView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var selectedCustomer: Customer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(appViewModel.customers) { customer in
                Button(action: {
                    selectedCustomer = customer
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(customer.name)
                            .font(.headline)
                        
                        Text(customer.phoneNumber)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let businessName = customer.businessName {
                            Text(businessName)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Customer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct OrderDetailsView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Order Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Information")
                            .font(.headline)
                        
                        InfoRow(label: "Order Number", value: order.orderNumber)
                        InfoRow(label: "Status", value: order.status.rawValue)
                        InfoRow(label: "Created", value: order.createdAt.formatted(date: .abbreviated, time: .shortened))
                        
                        if let deliveryDate = order.deliveryDate {
                            InfoRow(label: "Delivery Date", value: deliveryDate.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    
                    Divider()
                    
                    // Customer Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Customer Information")
                            .font(.headline)
                        
                        InfoRow(label: "Name", value: order.customer.name)
                        InfoRow(label: "Phone", value: order.customer.phoneNumber)
                        
                        if let email = order.customer.email {
                            InfoRow(label: "Email", value: email)
                        }
                        
                        if let businessName = order.customer.businessName {
                            InfoRow(label: "Business", value: businessName)
                        }
                    }
                    
                    Divider()
                    
                    // Order Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Items")
                            .font(.headline)
                        
                        ForEach(order.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("₹\(item.unitPrice, specifier: "%.2f") × \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("₹\(item.totalPrice, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("₹\(order.totalAmount, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    
                    if let instructions = order.specialInstructions, !instructions.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Special Instructions")
                                .font(.headline)
                            
                            Text(instructions)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Order Details")
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

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Date Range") {
                    DatePicker("From", selection: .constant(Date()), displayedComponents: .date)
                    DatePicker("To", selection: .constant(Date()), displayedComponents: .date)
                }
                
                Section("Status") {
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        HStack {
                            Text(status.rawValue)
                            Spacer()
                            Toggle("", isOn: .constant(false))
                        }
                    }
                }
                
                Section("Amount Range") {
                    TextField("Min Amount", text: .constant(""))
                        .keyboardType(.decimalPad)
                    TextField("Max Amount", text: .constant(""))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        // Reset filters
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PurchaseView()
        .environmentObject(AppViewModel())
}