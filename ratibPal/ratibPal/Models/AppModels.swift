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
    let uid: String?         // User ID (Foreign key to Profile) - Added per documentation
    let mod: String?         // Communication mode
    let bnm: String?         // Business name
    let bpr: String?         // Business profile description
    let sdc: String?         // Show delivery charge separately
    let sos: String?         // Show other suppliers
    let ovd: String?         // Admin override setting
    let ccos: String?        // Change cut-off durations as CSV - Added per documentation
    let ent: String?         // Enterprise ID
    let cat: String?         // Category IDs as CSV
    let scl: Int             // Supply chain level (1-7)
    let vtl: Int             // Visible to levels
    let dcn: String?         // Downstream contact number
    let ucn: String?         // Upstream contact number
    
    // Removed fields that don't match documentation:
    // - lnp (Line provider)
    // - cco (Customer care officer) 
    // - rem (Remarks)
}

struct Location: Codable {
    let lid: String          // Location ID (Primary key)
    let uid: String?         // User ID (Foreign key) - Added per documentation
    let hno: String?         // House/store number - Added per documentation
    let adr: String?         // Address
    let lt: String?          // Locality - matches documentation
    let ct: String?          // City
    let st: String?          // State
    let pin: String?         // PIN code
    let glt: String?         // Geolocation type ("Point") - Added per documentation
    let gll: String?         // Geolocation lat,lng as CSV - Added per documentation
    let typ: String?         // Location type (H=home, F=office, etc.) - Made optional
    let rad: Double          // Radius for delivery
    let glc: GeoLocation?    // Geo coordinates - Keep for convenience
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
    static let shouldShowWelcomeOverlay = "should_show_welcome_overlay"
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

// MARK: - Offering System Models

// MARK: - API Response Models for Offerings
struct OfferingAPIResponse: Codable {
    let success: Bool
    let message: String?
    let data: [GSUResponse]?
}

struct GSUResponse: Codable {
    let gid: String
    let sid: String?
    let gci: String?
    let sdc: String?
    let nam: String?
    let shn: String?
    let dsc: String?
    let bcd: String?
    let img: String?
    let ul: String?
    let cl: String?
    let cc: Int32
    let pub: Bool
    let anp: String?
    let sdt: Int32
    let edt: Int32
    let ca: Int64
    let cb: String?
    let ua: Int64
    let ub: String?
    let d: Bool
    let e: Bool
    let variants: [VariantResponse]?
    let prices: [PriceResponse]?
    let sources: [GSUSourceResponse]?
}

struct VariantResponse: Codable {
    let vid: String
    let gid: String
    let vnm: String?
    let bcd: String?
    let img: String?
    let cl: String?
    let cc: Int32
    let pub: Bool
    let s: Int32
}

struct PriceResponse: Codable {
    let id: Int64?
    let gid: String
    let vid: String?
    let odt: Int32
    let trm: Int32
    let bp: Double
    let sp: Double
    let stp: Double
    let pp: Double
    let dco: Double
    let dcm: Double
    let dbps: String?
    let dsps: String?
    let dtps: String?
    let dpps: String?
    let tcss: String?
}

struct GSUSourceResponse: Codable {
    let id: Int64?
    let gid: String
    let vid: String?
    let sai: String?
    let sgi: String?
    let svi: String?
    let npc: Double
    let qdi: Double
}

struct CategoryResponse: Codable {
    let gci: String
    let cnm: String?
    let typ: String?
    let stp: String?
    let bannerId: String?
    let iconId: String?
    let iconGreyId: String?
    let seq: Int32
    let ca: Int64
    let cb: String?
    let ua: Int64
    let ub: String?
    let d: Bool
}

// MARK: - Image Upload Response
struct ImageUploadResponse: Codable {
    let success: Bool
    let fId: String?
    let fUrl: String?
    let thumbUrl: String?
    let message: String?
}

// MARK: - Offering Business Models
struct OfferingModel: Identifiable {
    var id: String { gid }
    let gid: String
    let name: String
    let shortName: String?
    let description: String?
    let barcode: String?
    let imageIds: [String]
    let unitLabel: String?
    let crateLabel: String?
    let crateCapacity: Int32
    let isPublic: Bool
    let availableSlots: String?
    let startDate: Int32
    let endDate: Int32
    let category: String?
    let supplierDefinedCategory: String?
    let variants: [VariantModel]
    let prices: [PriceModel]
    let sources: [GSUSourceModel]
    
    var displayName: String {
        return name.isEmpty ? (shortName ?? "Unnamed Offering") : name
    }
    
    var hasVariants: Bool {
        return !variants.isEmpty
    }
    
    var currentPrice: PriceModel? {
        let currentDate = Int32(DateFormatter.yyyyMMdd.string(from: Date())) ?? 0
        return prices.first { $0.applicableDate <= currentDate }
    }
}

struct VariantModel {
    let vid: String
    let name: String
    let barcode: String?
    let imageIds: [String]
    let crateLabel: String?
    let crateCapacity: Int32
    let isPublic: Bool
    let sequence: Int32
}

struct PriceModel {
    let id: Int64?
    let variantId: String?
    let applicableDate: Int32
    let termMonths: Int32
    let basePrice: Double
    let sellPrice: Double
    let strikeThroughPrice: Double
    let purchasePrice: Double
    let deliveryChargePerOrder: Double
    let deliveryChargePerMonth: Double
    let dayWiseBasePrices: [String: Double]?
    let dayWiseSellPrices: [String: Double]?
    let dayWiseStrikePrices: [String: Double]?
    let dayWisePurchasePrices: [String: Double]?
    let taxCodes: [String]?
    
    var hasPromotion: Bool {
        return strikeThroughPrice > sellPrice && strikeThroughPrice > 0
    }
    
    var discountPercentage: Double? {
        guard hasPromotion else { return nil }
        return ((strikeThroughPrice - sellPrice) / strikeThroughPrice) * 100
    }
}

struct GSUSourceModel {
    let id: Int64?
    let variantId: String?
    let sourceAffiliateId: String?
    let sourceGSUId: String?
    let sourceVariantId: String?
    let needPercentage: Double
    let quantityDivision: Double
}

struct CategoryModel {
    let id: String
    let name: String
    let type: String // G/S/U
    let subType: String?
    let bannerId: String?
    let iconId: String?
    let iconGreyId: String?
    let sequence: Int32
    
    var displayName: String {
        return name.isEmpty ? "Category" : name
    }
    
    var typeDescription: String {
        switch type.uppercased() {
        case "G": return "Goods"
        case "S": return "Services"
        case "U": return "Utilities"
        default: return type
        }
    }
}

// MARK: - Offering Filter and Search Models
struct OfferingFilter {
    var categoryId: String?
    var supplierDefinedCategory: String?
    var searchText: String?
    var isPublicOnly: Bool = false
    var hasVariantsOnly: Bool = false
    var startDate: Date?
    var endDate: Date?
    
    var hasActiveFilters: Bool {
        return categoryId != nil || 
               supplierDefinedCategory != nil || 
               (searchText?.isEmpty == false) ||
               isPublicOnly ||
               hasVariantsOnly ||
               startDate != nil ||
               endDate != nil
    }
}

// MARK: - Time Slot Management
enum TimeSlot: String, CaseIterable {
    case morning = "AM"
    case noon = "Noon" 
    case evening = "PM"
    case always = "Always"
    case asap = "ASAP"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning (6AM - 12PM)"
        case .noon: return "Noon (12PM - 6PM)"
        case .evening: return "Evening (6PM - 12AM)"
        case .always: return "Always Available"
        case .asap: return "As Soon As Possible"
        }
    }
    
    static func fromString(_ string: String?) -> [TimeSlot] {
        guard let string = string else { return [] }
        return string.split(separator: ",")
            .compactMap { TimeSlot(rawValue: String($0).trimmingCharacters(in: .whitespaces)) }
    }
    
    static func toString(_ slots: [TimeSlot]) -> String {
        return slots.map { $0.rawValue }.joined(separator: ",")
    }
}
