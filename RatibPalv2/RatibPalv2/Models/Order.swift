import Foundation

struct Order: Codable, Identifiable {
    let id = UUID()
    var orderNumber: String
    var customer: Customer
    var items: [OrderItem]
    var totalAmount: Double
    var status: OrderStatus
    var deliveryDate: Date?
    var deliveryAddress: Address
    var specialInstructions: String?
    var paymentMethod: PaymentMethod?
    var isPaid: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(customer: Customer, items: [OrderItem] = []) {
        self.orderNumber = "ORD-\(Date().timeIntervalSince1970)"
        self.customer = customer
        self.items = items
        self.totalAmount = items.reduce(0) { $0 + $1.totalPrice }
        self.status = .pending
        self.deliveryAddress = customer.deliveryAddress
        self.isPaid = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct OrderItem: Codable, Identifiable {
    let id = UUID()
    var offeringId: UUID
    var name: String
    var quantity: Int
    var unitPrice: Double
    var totalPrice: Double
    
    init(offeringId: UUID, name: String, quantity: Int, unitPrice: Double) {
        self.offeringId = offeringId
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = Double(quantity) * unitPrice
    }
}

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case inProgress = "In Progress"
    case outForDelivery = "Out for Delivery"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .inProgress: return "yellow"
        case .outForDelivery: return "purple"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case card = "Card"
    case upi = "UPI"
    case bankTransfer = "Bank Transfer"
    case credit = "Credit"
}