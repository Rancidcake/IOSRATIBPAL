import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var orders: [Order] = []
    @Published var offerings: [Offering] = []
    @Published var selectedTab = 0
    @Published var showFABMenu = false
    @Published var showLocationPermission = false
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample customers
        let address1 = Address(street: "123 Main St", landmark: "Near Park", city: "Mumbai", state: "Maharashtra", pinCode: "400001")
        let address2 = Address(street: "456 High St", landmark: "Opposite Mall", city: "Mumbai", state: "Maharashtra", pinCode: "400002")
        
        customers = [
            Customer(name: "John Doe", phoneNumber: "+91 9876543210", email: "john@example.com", customerType: .individual, deliveryAddress: address1),
            Customer(name: "Jane Smith", phoneNumber: "+91 9876543211", email: "jane@example.com", customerType: .business, deliveryAddress: address2)
        ]
        
        // Sample offerings
        offerings = [
            Offering(name: "Product A", description: "High quality product", category: .goods, price: 100.0),
            Offering(name: "Delivery Service", description: "Fast delivery", category: .services, price: 50.0),
            Offering(name: "Power Connection", description: "Electricity connection", category: .utilities, price: 200.0)
        ]
        
        // Sample orders
        let orderItems = [OrderItem(offeringId: offerings[0].id, name: offerings[0].name, quantity: 2, unitPrice: offerings[0].price)]
        orders = [
            Order(customer: customers[0], items: orderItems)
        ]
    }
    
    func addCustomer(_ customer: Customer) {
        customers.append(customer)
    }
    
    func addOrder(_ order: Order) {
        orders.append(order)
    }
    
    func addOffering(_ offering: Offering) {
        offerings.append(offering)
    }
    
    func toggleFABMenu() {
        withAnimation(.spring()) {
            showFABMenu.toggle()
        }
    }
}