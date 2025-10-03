import Foundation

// DISABLED: OfferingSyncManager - Focusing on local storage only
// All sync functionality has been removed to focus on local data storage
class OfferingSyncManager {
    static let shared = OfferingSyncManager()
    private init() {}
    
    // MARK: - Disabled Sync Methods - Providing Stubs for Compilation
    
    @MainActor
    func performFullSync(userId: String) async throws {
        print("⚠️ OfferingSyncManager.performFullSync() disabled - using local storage only")
        // No-op: all sync functionality removed
    }
    
    func syncLinkedOfferings(userId: String) async throws {
        print("⚠️ syncLinkedOfferings disabled - using local storage only")
    }
    
    func searchMyOfferings(searchText: String, categoryId: String? = nil, city: String? = nil) async throws -> [GSUResponse] {
        print("⚠️ searchMyOfferings disabled - using local storage only")
        return []
    }
    
    func fetchOfferingsOfSource(sourceId: String, searchText: String? = nil, limit: Int? = nil, offset: Int = 0) async throws -> [GSUResponse] {
        print("⚠️ fetchOfferingsOfSource disabled - using local storage only")
        return []
    }
    
    func uploadOfferingImage(_ imageData: Data) async throws -> String {
        print("⚠️ uploadOfferingImage disabled - returning local ID")
        return "local_image_\(UUID().uuidString)"
    }
    
    func getLastSyncTime() -> Date? {
        return nil
    }
    
    func hasPendingChanges(userId: String) -> Bool {
        return false
    }
    
    func performBackgroundSync(userId: String) {
        print("⚠️ performBackgroundSync disabled - using local storage only")
    }
}
