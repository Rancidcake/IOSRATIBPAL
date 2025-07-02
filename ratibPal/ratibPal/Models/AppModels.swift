//
//  AppModels.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import Foundation

// MARK: - Tab Items
enum TabItem: String, CaseIterable {
    case home = "Home"
    case purchase = "Purchase"
    case deliver = "Delivery"
    case billing = "Billing"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .purchase: return "cart"
        case .deliver: return "box.truck"
        case .billing: return "doc.text"
        case .profile: return "person"
        }
    }
}

// MARK: - Menu Items
struct MenuItem {
    let title: String
    let hasToggle: Bool
    let hasDisclosure: Bool
    let isToggleOn: Bool
    
    init(title: String, hasToggle: Bool = false, hasDisclosure: Bool = true, isToggleOn: Bool = false) {
        self.title = title
        self.hasToggle = hasToggle
        self.hasDisclosure = hasDisclosure
        self.isToggleOn = isToggleOn
    }
}

// MARK: - Payment Data
struct PaymentSection {
    let title: String
    let items: [String]
    let isExpanded: Bool
}

// MARK: - Supplier Category
struct SupplierCategory {
    let title: String
    let items: [String]
}

// MARK: - Welcome Steps
struct WelcomeStep {
    let id: Int
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let isActive: Bool
}

// MARK: - Line Management
struct DeliveryLine {
    let id: UUID = UUID()
    let name: String
    let isExpanded: Bool
    let customers: [Customer]
}

struct Customer {
    let id: UUID = UUID()
    let name: String
    let address: String
}

// MARK: - Filter Options
enum FilterOption: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case inactive = "Inactive"
    
    var title: String {
        return self.rawValue
    }
}
