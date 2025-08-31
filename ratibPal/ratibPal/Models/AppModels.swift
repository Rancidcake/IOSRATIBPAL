//
//  AppModels.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//

import Foundation
import UIKit

// MARK: - RatibPal API Models

// MARK: - Registration Request Models
struct LoginRequest: Codable {
    let mobileNo: String    // 10-digit mobile number
    let appType: String     // "omni"
}

struct OtpModel: Codable {
    let mobileNo: String
    let otp: String                    // 4-digit OTP
    let deviceDetails: DeviceDetails
}

struct DeviceDetails: Codable {
    let deviceId: String      // iOS: UIDevice.current.identifierForVendor
    let deviceType: String    // "ios" to match Android format
    let os: String           // iOS system name
    let osVer: String        // iOS version
    let appVer: String       // App version
    let pushToken: String    // FCM/APNS token for notifications
    let appType: String      // "omni"
    
    static var current: DeviceDetails {
        return DeviceDetails(
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            deviceType: "ios",
            os: UIDevice.current.systemName,
            osVer: UIDevice.current.systemVersion,
            appVer: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            pushToken: UserDefaults.standard.string(forKey: "pushToken") ?? "",
            appType: "omni"
        )
    }
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let message: String
    let messageCode: String
    // Inherits mobileNo and appType from LoginRequest
}

struct Profile: Codable {
    let uid: String          // User ID
    let mno: String?         // Mobile number
    let nam: String?         // Full name
    let eml: String?         // Email
    let img: String?         // Profile image ID
    let irl: String?         // Profile image URL
    let pid: String?         // Photo ID image
    let stk: String          // Security token (API key)
    let plc: String?         // Preferred language code
    let pns: Bool            // Notification preferences
    let blk: Bool            // Blocked status
    let off: Bool            // Offline status
    
    // Supplier details (if user is a supplier)
    let sup: Supplier?
    
    // Locations
    var lcs: [Location]?
    
    // Audit fields
    let ca: Int64            // Created at
    let cb: String?          // Created by
    let ua: Int64            // Updated at
    let ub: String?          // Updated by
    let d: Bool              // Deleted flag
}

struct Supplier: Codable {
    let bnm: String?         // Business name
    let bpr: String?         // Business profile/description
    let scl: Int             // Supply chain level
    let dcn: String?         // Delivery contact number
    let ucn: String?         // Upstream contact number
    let sdc: String?         // Show delivery charges setting
    let mod: String?         // Communication mode
    let ent: String?         // Entry
    let lnp: String?         // Line provider
    let cco: String?         // Customer care officer
    let cat: String?         // Category
    let sos: String?         // Show other suppliers
    let rem: String?         // Remarks
    let ovd: String?         // Override
    let vtl: Int?            // Vital (changed from String to Int to match server response)
}

struct Location: Codable {
    let lid: String          // Location ID
    let adr: String?         // Full address
    let ct: String?          // City
    let glc: GeoLocation?    // Geo coordinates
    let lt: String?          // Location title/name
    let pin: String?         // PIN code
    let rad: Double          // Radius
    let st: String?          // State
    let typ: String          // Location type (H=Home, F=Office, O=Other for personal; AREA, WAREHOUSE, STORE for business)
}

struct GeoLocation: Codable {
    let type: String         // "Point"
    let coordinates: [Double] // [longitude, latitude]
}

struct ImageUploadResponseModel: Codable {
    let fId: String          // File ID from server
    let fUrl: String?        // Full image URL
    let thumbUrl: String?    // Thumbnail URL
    
    // For backward compatibility, map to the expected field names
    var actualImageId: String {
        return fId
    }
    
    var actualImageUrl: String? {
        return fUrl
    }
}

struct Errors: Codable {
    let general: [ErrorItem]?
}

struct ErrorItem: Codable {
    let message: String
    let messageCode: String
}

// MARK: - UserDefaults Keys
struct UserDefaultsKeys {
    static let userId = "user_id"
    static let actingUserId = "acting_user_id"
    static let apiSessionKey = "api_session_key"
    static let notificationSettingStatus = "notification_setting_status"
    static let languageSelected = "language_selected"
    static let firstTimeLogin = "first_time_login"
    static let pushToken = "push_token"
    static let userProfile = "user_profile"
}

// MARK: - Registration Flow
enum RegistrationStep: CaseIterable {
    case mobileEntry
    case otpVerification
    case nameEntry
    case photoUpload
    case locationSetup
    case completed
}

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
