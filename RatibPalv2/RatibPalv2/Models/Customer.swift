import Foundation

struct Customer: Codable, Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
    var email: String?
    var customerType: CustomerType
    var businessName: String?
    var gstNumber: String?
    var deliveryAddress: Address
    var billingAddress: Address?
    var notes: String?
    var creditLimit: Double
    var paymentTerms: String?
    var preferredDeliveryTime: String?
    var createdAt: Date
    
    init(name: String, phoneNumber: String, email: String? = nil, customerType: CustomerType = .individual, deliveryAddress: Address) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.customerType = customerType
        self.deliveryAddress = deliveryAddress
        self.creditLimit = 0
        self.createdAt = Date()
    }
}

enum CustomerType: String, CaseIterable, Codable {
    case individual = "Individual"
    case business = "Business"
}

struct Address: Codable {
    var street: String
    var landmark: String?
    var city: String
    var state: String
    var pinCode: String
    var country: String = "India"
}