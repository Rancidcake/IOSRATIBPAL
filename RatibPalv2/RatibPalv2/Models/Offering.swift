import Foundation

struct Offering: Codable, Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var category: OfferingCategory
    var subcategory: String?
    var price: Double
    var wholesalePrice: Double?
    var retailPrice: Double?
    var stockLevel: Int?
    var minimumStock: Int?
    var productCode: String?
    var imageURLs: [String]
    var specifications: [String: String]
    var isActive: Bool
    var createdAt: Date
    
    init(name: String, description: String, category: OfferingCategory, price: Double) {
        self.name = name
        self.description = description
        self.category = category
        self.price = price
        self.imageURLs = []
        self.specifications = [:]
        self.isActive = true
        self.createdAt = Date()
    }
}

enum OfferingCategory: String, CaseIterable, Codable {
    case goods = "Goods"
    case services = "Services"
    case utilities = "Utilities"
    
    var systemImageName: String {
        switch self {
        case .goods: return "cube.box"
        case .services: return "wrench.and.screwdriver"
        case .utilities: return "bolt"
        }
    }
}