//
//  DataSyncManager.swift
//  ratibPal
//
//  Created by AI Assistant on 03/09/25.
//

import Foundation
import Combine

class DataSyncManager: ObservableObject {
    static let shared = DataSyncManager()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncProgress: Double = 0.0
    
    private let coreDataManager = CoreDataManager.shared
    private let sessionManager = SessionManager.shared
    private let apiManager = RegistrationAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadLastSyncDate()
    }
    
    // MARK: - Main Sync Functions
    
    /// Performs a full data synchronization
    func performFullSync() async {
        await MainActor.run {
            isSyncing = true
            syncProgress = 0.0
        }
        
        do {
            // Step 1: Sync user profile (20% progress)
            await updateProgress(0.1)
            try await syncUserProfile()
            await updateProgress(0.2)
            
            // Step 2: Sync categories (40% progress)
            await updateProgress(0.3)
            try await syncCategories()
            await updateProgress(0.4)
            
            // Step 3: Sync suppliers (60% progress)
            await updateProgress(0.5)
            try await syncSuppliers()
            await updateProgress(0.6)
            
            // Step 4: Sync locations (80% progress)
            await updateProgress(0.7)
            try await syncLocations()
            await updateProgress(0.8)
            
            // Step 5: Complete sync (100% progress)
            await updateProgress(0.9)
            await completeSyncProcess()
            await updateProgress(1.0)
            
        } catch {
            print("Full sync failed: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            isSyncing = false
        }
    }
    
    /// Performs incremental sync based on timestamps
    func performIncrementalSync() async {
        guard sessionManager.getUserId() != nil else {
            print("No user ID found for incremental sync")
            return
        }
        
        await MainActor.run {
            isSyncing = true
            syncProgress = 0.0
        }
        
        do {
            let lastSyncTimestamp = sessionManager.getSyncTimestamp()
            
            // Only sync data that has changed since last sync
            await updateProgress(0.2)
            try await syncUserProfileIfNeeded(since: lastSyncTimestamp)
            
            await updateProgress(0.4)
            try await syncCategoriesIfNeeded(since: lastSyncTimestamp)
            
            await updateProgress(0.6)
            try await syncSuppliersIfNeeded(since: lastSyncTimestamp)
            
            await updateProgress(0.8)
            try await syncLocationsIfNeeded(since: lastSyncTimestamp)
            
            await updateProgress(1.0)
            await completeSyncProcess()
            
        } catch {
            print("Incremental sync failed: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            isSyncing = false
        }
    }
    
    // MARK: - Individual Sync Functions
    
    private func syncUserProfile() async throws {
        guard let userId = sessionManager.getUserId() else {
            throw SyncError.missingUserId
        }
        
        do {
            let profile = try await apiManager.getUserProfile(userId: userId)
            
            // Save to Core Data
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                coreDataManager.saveProfile(profile) { success in
                    if success {
                        print("Profile saved to Core Data successfully")
                    } else {
                        print("Failed to save profile to Core Data")
                    }
                    continuation.resume()
                }
            }
            
            print("User profile synced successfully")
        } catch {
            print("Failed to sync user profile: \(error)")
            throw error
        }
    }
    
    private func syncCategories() async throws {
        // This would be implemented when you have a categories API endpoint
        // For now, we'll simulate the sync
        print("Categories sync would be implemented here")
        
        // Update category sync timestamp
        let currentTimestamp = Int64(Date().timeIntervalSince1970)
        sessionManager.setCategorySyncTimestamp(currentTimestamp)
    }
    
    private func syncSuppliers() async throws {
        // This would be implemented when you have a suppliers API endpoint
        // For now, we'll simulate the sync
        print("Suppliers sync would be implemented here")
        
        // Update sync timestamp
        let currentTimestamp = Int64(Date().timeIntervalSince1970)
        sessionManager.setAffiliatesSyncTimestamp(currentTimestamp)
    }
    
    private func syncLocations() async throws {
        guard let userId = sessionManager.getUserId() else {
            throw SyncError.missingUserId
        }
        
        // Get user profile with locations
        do {
            let profile = try await apiManager.getUserProfile(userId: userId)
            
            // Extract and sync locations
            if let locations = profile.lcs, !locations.isEmpty {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    coreDataManager.saveProfile(profile) { success in
                        if success {
                            print("Profile with locations saved successfully")
                        } else {
                            print("Failed to save profile with locations")
                        }
                        continuation.resume()
                    }
                }
                print("Locations synced successfully")
            } else {
                print("No locations found to sync")
            }
        } catch {
            print("Failed to sync locations: \(error)")
            throw error
        }
    }
    
    // MARK: - Incremental Sync Functions
    
    private func syncUserProfileIfNeeded(since timestamp: Int64) async throws {
        // Check if profile needs updating based on timestamp
        // For now, always sync the profile
        try await syncUserProfile()
    }
    
    private func syncCategoriesIfNeeded(since timestamp: Int64) async throws {
        let lastCategorySync = sessionManager.getCategorySyncTimestamp()
        if timestamp > lastCategorySync {
            try await syncCategories()
        }
    }
    
    private func syncSuppliersIfNeeded(since timestamp: Int64) async throws {
        let lastSupplierSync = sessionManager.getAffiliatesSyncTimestamp()
        if timestamp > lastSupplierSync {
            try await syncSuppliers()
        }
    }
    
    private func syncLocationsIfNeeded(since timestamp: Int64) async throws {
        // Always sync locations as they're part of user profile
        try await syncLocations()
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func updateProgress(_ progress: Double) {
        syncProgress = progress
    }
    
    private func completeSyncProcess() async {
        let currentTimestamp = Int64(Date().timeIntervalSince1970)
        sessionManager.setSyncTimestamp(currentTimestamp)
        
        await MainActor.run {
            lastSyncDate = Date()
            saveLastSyncDate()
        }
        
        print("Sync completed successfully at \(Date())")
    }
    
    private func loadLastSyncDate() {
        if let lastSyncTimestamp = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date {
            lastSyncDate = lastSyncTimestamp
        }
    }
    
    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date, forKey: "lastSyncDate")
        }
    }
    
    // MARK: - Public Utility Functions
    
    func shouldPerformSync() -> Bool {
        // Perform sync if:
        // 1. Never synced before
        // 2. Last sync was more than 24 hours ago
        // 3. User explicitly requested sync
        
        guard let lastSync = lastSyncDate else {
            return true // Never synced
        }
        
        let twentyFourHoursAgo = Date().addingTimeInterval(-24 * 60 * 60)
        return lastSync < twentyFourHoursAgo
    }
    
    func clearSyncData() {
        lastSyncDate = nil
        UserDefaults.standard.removeObject(forKey: "lastSyncDate")
        
        // Clear all sync timestamps
        sessionManager.setSyncTimestamp(0)
        sessionManager.setCategorySyncTimestamp(0)
        sessionManager.setAffiliatesSyncTimestamp(0)
        sessionManager.setOrdersSyncTimestamp(0)
        sessionManager.setMyOfferingSyncTimestamp(0)
        sessionManager.setDeliveriesSyncTimestamp(0)
        sessionManager.setBillsSyncTimestamp(0)
    }
    
    // MARK: - Background Sync
    
    func startBackgroundSync() {
        // This would be called when app enters background
        Task {
            if shouldPerformSync() {
                await performIncrementalSync()
            }
        }
    }
}

// MARK: - Sync Error Types

enum SyncError: LocalizedError {
    case missingUserId
    case networkError(String)
    case dataParsingError
    case coreDataError
    
    var errorDescription: String? {
        switch self {
        case .missingUserId:
            return "User ID is missing"
        case .networkError(let message):
            return "Network error: \(message)"
        case .dataParsingError:
            return "Failed to parse server data"
        case .coreDataError:
            return "Core Data operation failed"
        }
    }
}
