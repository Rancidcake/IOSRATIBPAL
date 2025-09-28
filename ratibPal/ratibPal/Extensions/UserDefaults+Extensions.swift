import Foundation

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension UserDefaults {
    
    // MARK: - RatibPal Specific Methods
    
    func setUserProfile(_ profile: Profile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            set(encoded, forKey: UserDefaultsKeys.userProfile)
        }
    }
    
    func getUserProfile() -> Profile? {
        guard let data = data(forKey: UserDefaultsKeys.userProfile) else { return nil }
        return try? JSONDecoder().decode(Profile.self, from: data)
    }
    
    func clearUserData() {
        removeObject(forKey: UserDefaultsKeys.userId)
        removeObject(forKey: UserDefaultsKeys.actingUserId)
        removeObject(forKey: UserDefaultsKeys.apiSessionKey)
        removeObject(forKey: UserDefaultsKeys.userProfile)
        removeObject(forKey: UserDefaultsKeys.shouldShowWelcomeOverlay)
        set(true, forKey: UserDefaultsKeys.firstTimeLogin)
        set(true, forKey: UserDefaultsKeys.notificationSettingStatus)
        set("en", forKey: UserDefaultsKeys.languageSelected)
    }
    
    // MARK: - Safe Getters
    
    var isFirstTimeLogin: Bool {
        if object(forKey: UserDefaultsKeys.firstTimeLogin) == nil {
            // First time opening the app
            return true
        }
        return bool(forKey: UserDefaultsKeys.firstTimeLogin)
    }
    
    var currentUserId: String? {
        return string(forKey: UserDefaultsKeys.userId)
    }
    
    var currentAPIKey: String? {
        return string(forKey: UserDefaultsKeys.apiSessionKey)
    }
    
    var selectedLanguage: String {
        return string(forKey: UserDefaultsKeys.languageSelected) ?? "en"
    }
    
    var notificationsEnabled: Bool {
        if object(forKey: UserDefaultsKeys.notificationSettingStatus) == nil {
            // Default to true if not set
            return true
        }
        return bool(forKey: UserDefaultsKeys.notificationSettingStatus)
    }
    
    var shouldShowWelcomeOverlay: Bool {
        if object(forKey: UserDefaultsKeys.shouldShowWelcomeOverlay) == nil {
            // Default to false if not set
            return false
        }
        return bool(forKey: UserDefaultsKeys.shouldShowWelcomeOverlay)
    }
    
    func setWelcomeOverlayShown() {
        set(false, forKey: UserDefaultsKeys.shouldShowWelcomeOverlay)
    }
    
    func markNewUserRegistration() {
        set(true, forKey: UserDefaultsKeys.shouldShowWelcomeOverlay)
    }
}
