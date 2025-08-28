//
//  UserDefaults+Extensions.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

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
}
