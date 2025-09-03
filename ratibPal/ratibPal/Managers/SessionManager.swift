//
//  SessionManager.swift
//  ratibPal
//
//  Created by AI Assistant on 03/09/25.
//

import Foundation
import Security

class SessionManager {
    static let shared = SessionManager()
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainService()
    
    private init() {}
    
    // MARK: - Session Token Management (Keychain for security)
    func setApiSessionKey(_ token: String) {
        keychain.set(token, forKey: "apiSessionKey")
        // Also set in UserDefaults for backward compatibility
        userDefaults.set(token, forKey: UserDefaultsKeys.apiSessionKey)
    }
    
    func getApiSessionKey() -> String? {
        // Try keychain first, fallback to UserDefaults
        if let token = keychain.get("apiSessionKey"), !token.isEmpty {
            return token
        }
        return userDefaults.string(forKey: UserDefaultsKeys.apiSessionKey)
    }
    
    // MARK: - User Identity
    func setUserId(_ id: String) {
        userDefaults.set(id, forKey: UserDefaultsKeys.userId)
    }
    
    func getUserId() -> String? {
        return userDefaults.string(forKey: UserDefaultsKeys.userId)
    }
    
    func setActingUserId(_ id: String) {
        userDefaults.set(id, forKey: UserDefaultsKeys.actingUserId)
    }
    
    func getActingUserId() -> String? {
        return userDefaults.string(forKey: UserDefaultsKeys.actingUserId) ?? getUserId()
    }
    
    // MARK: - Business Information
    func setUserBizCat(_ category: String) {
        userDefaults.set(category, forKey: "bizcat")
    }
    
    func getUserBizCat() -> String? {
        return userDefaults.string(forKey: "bizcat")
    }
    
    func setUserSuppChainLevel(_ level: Int) {
        userDefaults.set(level, forKey: "suppchainlevel")
    }
    
    func getUserSuppChainLevel() -> Int {
        return userDefaults.integer(forKey: "suppchainlevel") // Default 0 = retail customer
    }
    
    // MARK: - Push Notifications
    func setFCMToken(_ token: String) {
        userDefaults.set(token, forKey: UserDefaultsKeys.pushToken)
    }
    
    func getFCMToken() -> String? {
        return userDefaults.string(forKey: UserDefaultsKeys.pushToken)
    }
    
    func setNotificationSettingStatus(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: UserDefaultsKeys.notificationSettingStatus)
    }
    
    func getNotificationSettingStatus() -> Bool {
        return userDefaults.bool(forKey: UserDefaultsKeys.notificationSettingStatus)
    }
    
    func setNotificationBadgeCount(_ count: Int) {
        userDefaults.set(count, forKey: "notificationBadgeCount")
    }
    
    func getNotificationBadgeCount() -> Int {
        return userDefaults.integer(forKey: "notificationBadgeCount")
    }
    
    // MARK: - Sync Timestamps (Critical for data synchronization)
    func setCategorySyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "category_sync_timestamp")
    }
    
    func getCategorySyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "category_sync_timestamp"))
    }
    
    func setOrdersSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "orders_sync_timestamp")
    }
    
    func getOrdersSyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "orders_sync_timestamp"))
    }
    
    func setAffiliatesSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "affiliates_sync_timestamp")
    }
    
    func getAffiliatesSyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "affiliates_sync_timestamp"))
    }
    
    func setMyOfferingSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "my_offering_sync_timestamp")
    }
    
    func getMyOfferingSyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "my_offering_sync_timestamp"))
    }
    
    func setDeliveriesSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "deliveries_sync_timestamp")
    }
    
    func getDeliveriesSyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "deliveries_sync_timestamp"))
    }
    
    func setBillsSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "bills_sync_timestamp")
    }
    
    func getBillsSyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "bills_sync_timestamp"))
    }
    
    func setSyncTimestamp(_ timestamp: Int64) {
        userDefaults.set(timestamp, forKey: "sync_timestamp")
    }
    
    func getSyncTimestamp() -> Int64 {
        return Int64(userDefaults.double(forKey: "sync_timestamp"))
    }
    
    // MARK: - User State
    func setFirstTimeLogin(_ isFirst: Bool) {
        userDefaults.set(isFirst, forKey: UserDefaultsKeys.firstTimeLogin)
    }
    
    func getFirstTimeLogin() -> Bool {
        return userDefaults.bool(forKey: UserDefaultsKeys.firstTimeLogin)
    }
    
    func setNewUserFlag(_ flag: Bool) {
        userDefaults.set(flag, forKey: "isNewUser")
    }
    
    func getIsNewUser() -> Bool {
        return userDefaults.bool(forKey: "isNewUser")
    }
    
    // MARK: - Language & Preferences
    func setLanguage(_ language: String) {
        userDefaults.set(language, forKey: UserDefaultsKeys.languageSelected)
    }
    
    func getLanguage() -> String {
        return userDefaults.string(forKey: UserDefaultsKeys.languageSelected) ?? "en"
    }
    
    // MARK: - Session Management
    func isUserLoggedIn() -> Bool {
        return getApiSessionKey() != nil && getUserId() != nil
    }
    
    func clearAllUserData() {
        // Clear UserDefaults
        let bundleId = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: bundleId)
        
        // Clear Keychain
        keychain.delete("apiSessionKey")
        
        // Clear Core Data will be handled separately by CoreDataManager
    }
}

// MARK: - Keychain Service for secure token storage
class KeychainService {
    func set(_ value: String, forKey key: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Keychain set error: \(status)")
        }
    }
    
    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        if status != errSecItemNotFound {
            print("Keychain get error: \(status)")
        }
        
        return nil
    }
    
    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete error: \(status)")
        }
    }
}
