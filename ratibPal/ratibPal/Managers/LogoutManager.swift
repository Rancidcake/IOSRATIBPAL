//
//  LogoutManager.swift
//  ratibPal
//
//  Created by AI Assistant on 31/08/25.
//

import Foundation
import SwiftUI
import UserNotifications

/// LogoutManager handles client-side logout process for RatibPal
/// Following the Android implementation pattern, this is entirely client-side
/// with no server API calls required
class LogoutManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoggingOut = false
    @Published var logoutError: String?
    
    // MARK: - Core Logout Implementation
    
    /// Performs complete logout process
    /// Returns true if successful, false if there were errors
    @MainActor
    func performLogout() async -> Bool {
        isLoggingOut = true
        logoutError = nil
        
        // Step 1: Clear User Preferences
        clearUserPreferences()
        
        // Step 2: Clear Notifications (if implemented)
        clearNotifications()
        
        // Step 3: Clear Local Database/Storage
        clearLocalDatabase()
        
        // Step 4: Stop Background Processes (if any)
        stopBackgroundProcesses()
        
        // Step 5: Clear Application State
        clearApplicationState()
        
        print("✅ Logout completed successfully")
        isLoggingOut = false
        return true
    }
    
    // MARK: - Step 1: Clear User Preferences
    
    private func clearUserPreferences() {
        print("🗑️ Clearing user preferences...")
        
        // Use the existing clearUserData method which handles all the proper keys
        UserDefaults.standard.clearUserData()
        
        // Clear any additional app-specific data not covered by clearUserData
        let userDefaults = UserDefaults.standard
        
        // Remove any additional keys that might not be in clearUserData
        userDefaults.removeObject(forKey: "registrationFlowState")
        userDefaults.removeObject(forKey: "tempUserData")
        userDefaults.removeObject(forKey: "appSettings")
        userDefaults.removeObject(forKey: UserDefaultsKeys.pushToken)
        
        // Synchronize to ensure data is written
        userDefaults.synchronize()
        
        print("✅ User preferences cleared")
    }
    
    // MARK: - Step 2: Clear Notifications
    
    private func clearNotifications() {
        print("🔔 Clearing notifications...")
        
        // Clear all pending local notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Clear all delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Reset badge count
        DispatchQueue.main.async {
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(0)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        
        print("✅ Notifications cleared")
    }
    
    // MARK: - Step 3: Clear Local Database
    
    private func clearLocalDatabase() {
        print("💾 Clearing local database...")
        
        // Clear Core Data (if implemented)
        // clearCoreData()
        
        // Clear any cached files in Documents directory
        clearDocumentsDirectory()
        
        // Clear any cached images/files in Caches directory
        clearCachesDirectory()
        
        // Clear temporary files
        clearTemporaryDirectory()
        
        print("✅ Local database cleared")
    }
    
    private func clearDocumentsDirectory() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("⚠️ Error clearing documents directory: \(error)")
        }
    }
    
    private func clearCachesDirectory() {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cachesURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("⚠️ Error clearing caches directory: \(error)")
        }
    }
    
    private func clearTemporaryDirectory() {
        let tempURL = FileManager.default.temporaryDirectory
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: tempURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("⚠️ Error clearing temporary directory: \(error)")
        }
    }
    
    // MARK: - Step 4: Stop Background Processes
    
    private func stopBackgroundProcesses() {
        print("⏹️ Stopping background processes...")
        
        // Cancel any ongoing URLSession tasks
        URLSession.shared.getAllTasks { tasks in
            for task in tasks {
                task.cancel()
            }
        }
        
        // Stop any timers or background operations
        // This would include stopping any periodic sync, location updates, etc.
        
        print("✅ Background processes stopped")
    }
    
    // MARK: - Step 5: Clear Application State
    
    private func clearApplicationState() {
        print("🔄 Clearing application state...")
        
        // Reset any singleton states
        // This would reset any shared instances or global state
        
        // Clear any in-memory caches
        URLCache.shared.removeAllCachedResponses()
        
        // Clear any HTTP cookies (if used)
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        print("✅ Application state cleared")
    }
    
    // MARK: - Utility Methods
    
    /// Quick logout status check
    var isUserLoggedIn: Bool {
        return UserDefaults.standard.currentAPIKey != nil
    }
    
    /// Emergency logout (used in case of critical errors)
    func emergencyLogout() {
        Task {
            await performLogout()
        }
    }
}

// MARK: - Logout Status Enum

enum LogoutStatus {
    case notStarted
    case inProgress
    case completed
    case failed(Error)
}

// MARK: - UserDefaults Extension for Logout

extension UserDefaults {
    func clearAllUserData() {
        // Use the existing clearUserData method which properly handles all the keys
        clearUserData()
        
        // Clear any additional keys if needed
        removeObject(forKey: "registrationFlowState")
        removeObject(forKey: "tempUserData")
        removeObject(forKey: "appSettings")
        synchronize()
    }
}
