import SwiftUI

struct BillingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var searchText = ""
    @State private var selectedDateRange = DateRange.thisMonth
    @State private var showingFilters = false
    @State private var showingNewBill = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Billing & Payments")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingNewBill = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search bills, customers, amounts...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                
                // Financial Overview
                FinancialOverviewSection()
                
                // Bills List
                BillsListView()
            }
            .sheet(isPresented: $showingNewBill) {
                NewBillView()
            }
            .sheet(isPresented: $showingFilters) {
                BillingFiltersView()
            }
        }
    }
}

struct FinancialOverviewSection: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                FinancialCard(
                    title: "Outstanding",
                    amount: "₹12,450",
                    subtitle: "From 8 bills",
                    color: .orange,
                    icon: "clock"
                )
                
                FinancialCard(
                    title: "This Month",
                    amount: "₹45,600",
                    subtitle: "Revenue",
                    color: .green,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                FinancialCard(
                    title: "Pending",
                    amount: "₹8,200",
                    subtitle: "3 overdue",
                    color: .red,
                    icon: "exclamationmark.triangle"
                )
                
                FinancialCard(
                    title: "Collected",
                    amount: "₹25,800",
                    subtitle: "This week",
                    color: .blue,
                    icon: "checkmark.circle"
                )
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
}

struct FinancialCard: View {
    let title: String
    let amount: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(amount)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 140, height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct BillsListView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appViewModel.orders) { order in
                    BillCard(order: order)
                }
            }
            .padding()
        }
    }
}

struct BillCard: View {
    let order: Order
    @State private var showingDetails = false
    @State private var showingPaymentEntry = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bill Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BILL-\(order.orderNumber.suffix(6))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(order.customer.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(order.totalAmount, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    PaymentStatusBadge(isPaid: order.isPaid)
                }
            }
            
            // Bill Details
            HStack {
                Label(order.createdAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !order.isPaid {
                    Label("Due: \(order.createdAt.addingTimeInterval(30*24*60*60).formatted(date: .abbreviated, time: .omitted))", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("View Bill") {
                    showingDetails = true
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
                
                if !order.isPaid {
                    Button("Record Payment") {
                        showingPaymentEntry = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(6)
                }
                
                Spacer()
                
                Menu {
                    Button("Send Reminder") { }
                    Button("Download PDF") { }
                    Button("Duplicate Bill") { }
                    if !order.isPaid {
                        Button("Edit Bill") { }
                    }
                    Button("Cancel Bill") { }
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
            BillDetailsView(order: order)
        }
        .sheet(isPresented: $showingPaymentEntry) {
            PaymentEntryView(order: order)
        }
    }
}

struct PaymentStatusBadge: View {
    let isPaid: Bool
    
    var body: some View {
        Text(isPaid ? "Paid" : "Pending")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isPaid ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundColor(isPaid ? .green : .orange)
            .cornerRadius(4)
    }
}

struct BillDetailsView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Bill Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("BILL #\(order.orderNumber)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            PaymentStatusBadge(isPaid: order.isPaid)
                        }
                        
                        Text("Date: \(order.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Customer Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bill To:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.customer.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            if let businessName = order.customer.businessName {
                                Text(businessName)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(order.customer.phoneNumber)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let email = order.customer.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Bill Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            // Header
                            HStack {
                                Text("Item")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("Qty")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 40)
                                
                                Text("Rate")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60)
                                
                                Text("Amount")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80)
                            }
                            
                            Divider()
                            
                            // Items
                            ForEach(order.items) { item in
                                HStack {
                                    Text(item.name)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text("\(item.quantity)")
                                        .font(.subheadline)
                                        .frame(width: 40)
                                    
                                    Text("₹\(item.unitPrice, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .frame(width: 60)
                                    
                                    Text("₹\(item.totalPrice, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .frame(width: 80)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Bill Summary
                    VStack(spacing: 8) {
                        HStack {
                            Text("Subtotal")
                                .font(.subheadline)
                            Spacer()
                            Text("₹\(order.totalAmount, specifier: "%.2f")")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Text("Tax (18%)")
                                .font(.subheadline)
                            Spacer()
                            Text("₹\(order.totalAmount * 0.18, specifier: "%.2f")")
                                .font(.subheadline)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("₹\(order.totalAmount * 1.18, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Payment Information
                    if order.isPaid {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Payment Information")
                                .font(.headline)
                            
                            Text("Status: Paid")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            
                            Text("Payment Date: \(order.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Bill Details")
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

struct PaymentEntryView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var paymentAmount = ""
    @State private var selectedPaymentMethod = PaymentMethod.cash
    @State private var paymentDate = Date()
    @State private var referenceNumber = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Payment Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Enter amount", text: $paymentAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                    
                    TextField("Reference Number (Optional)", text: $referenceNumber)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 60)
                }
                
                Section("Bill Summary") {
                    HStack {
                        Text("Bill Amount")
                        Spacer()
                        Text("₹\(order.totalAmount, specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Customer")
                        Spacer()
                        Text(order.customer.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Record Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Handle payment recording
                        dismiss()
                    }
                    .disabled(paymentAmount.isEmpty)
                }
            }
        }
        .onAppear {
            paymentAmount = String(format: "%.2f", order.totalAmount)
        }
    }
}

struct NewBillView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCustomer: Customer?
    @State private var selectedItems: [OrderItem] = []
    @State private var showingCustomerPicker = false
    
    var body: some View {
        NavigationView {
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
                    
                    // Items Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Items")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(appViewModel.offerings) { offering in
                                OfferingCard(offering: offering) {
                                    addToBill(offering)
                                }
                            }
                        }
                    }
                    
                    // Selected Items
                    if !selectedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bill Items")
                                .font(.headline)
                            
                            ForEach(selectedItems) { item in
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
                                    
                                    Button(action: { removeFromBill(item) }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Subtotal")
                                    .font(.headline)
                                Spacer()
                                Text("₹\(selectedItems.reduce(0) { $0 + $1.totalPrice }, specifier: "%.2f")")
                                    .font(.headline)
                            }
                            
                            HStack {
                                Text("Tax (18%)")
                                    .font(.subheadline)
                                Spacer()
                                Text("₹\(selectedItems.reduce(0) { $0 + $1.totalPrice } * 0.18, specifier: "%.2f")")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("₹\(selectedItems.reduce(0) { $0 + $1.totalPrice } * 1.18, specifier: "%.2f")")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createBill()
                    }
                    .disabled(selectedCustomer == nil || selectedItems.isEmpty)
                }
            }
            .sheet(isPresented: $showingCustomerPicker) {
                CustomerPickerView(selectedCustomer: $selectedCustomer)
            }
        }
    }
    
    private func addToBill(_ offering: Offering) {
        if let existingIndex = selectedItems.firstIndex(where: { $0.offeringId == offering.id }) {
            selectedItems[existingIndex].quantity += 1
            selectedItems[existingIndex].totalPrice = Double(selectedItems[existingIndex].quantity) * selectedItems[existingIndex].unitPrice
        } else {
            let item = OrderItem(offeringId: offering.id, name: offering.name, quantity: 1, unitPrice: offering.price)
            selectedItems.append(item)
        }
    }
    
    private func removeFromBill(_ item: OrderItem) {
        selectedItems.removeAll { $0.id == item.id }
    }
    
    private func createBill() {
        guard let customer = selectedCustomer else { return }
        
        let order = Order(customer: customer, items: selectedItems)
        appViewModel.addOrder(order)
        dismiss()
    }
}

struct BillingFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Date Range") {
                    DatePicker("From", selection: .constant(Date()), displayedComponents: .date)
                    DatePicker("To", selection: .constant(Date()), displayedComponents: .date)
                }
                
                Section("Payment Status") {
                    Toggle("Paid", isOn: .constant(true))
                    Toggle("Pending", isOn: .constant(true))
                    Toggle("Overdue", isOn: .constant(true))
                }
                
                Section("Amount Range") {
                    TextField("Min Amount", text: .constant(""))
                        .keyboardType(.decimalPad)
                    TextField("Max Amount", text: .constant(""))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Billing Filters")
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

enum DateRange: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case custom = "Custom"
}

#Preview {
    BillingView()
        .environmentObject(AppViewModel())
}
