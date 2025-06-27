import Foundation

struct User: Codable, Identifiable {
    let id = UUID()
    var fullName: String
    var email: String
    var phoneNumber: String
    var businessName: String?
    var businessType: String?
    var isBusinessUser: Bool
    var profileImageURL: String?
    var locations: [Location]
    var createdAt: Date
    
    init(fullName: String, email: String, phoneNumber: String, businessName: String? = nil, businessType: String? = nil, isBusinessUser: Bool = false) {
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.businessName = businessName
        self.businessType = businessType
        self.isBusinessUser = isBusinessUser
        self.locations = []
        self.createdAt = Date()
    }
}

struct Location: Codable, Identifiable {
    let id = UUID()
    var name: String
    var address: String
    var city: String
    var state: String
    var pinCode: String
    var landmark: String?
    var latitude: Double?
    var longitude: Double?
    var isDefault: Bool
    
    init(name: String, address: String, city: String, state: String, pinCode: String, landmark: String? = nil, isDefault: Bool = false) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.pinCode = pinCode
        self.landmark = landmark
        self.isDefault = isDefault
    }
}