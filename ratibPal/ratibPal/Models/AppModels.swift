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
    case purchase = "Purcha"
    case deliver = "Deliver"
    case billing = "Billing"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .purchase: return "cart"
        case .deliver: return "truck"
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