import Foundation

class OfferingSyncManager {
    static let shared = OfferingSyncManager()
    private init() {}
    
    private let apiService = OfferingAPIService.shared
    private let dataManager = OfferingDataManager.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Sync Keys
    private struct SyncKeys {
        static let lastOfferingSync = "lastOfferingSync"
        static let lastCategorySync = "lastCategorySync"
        static let lastLinkedOfferingSync = "lastLinkedOfferingSync"
    }
    
    // MARK: - Full Synchronization
    @MainActor
    func performFullSync(userId: String) async throws {
        // 1. Get local dirty offerings (marked as edited)
        let dirtyOfferings = dataManager.fetchDirtyOfferings(userId: userId)
        
        // 2. Push dirty offerings to server
        if !dirtyOfferings.isEmpty {
            let offeringResponses = dirtyOfferings.compactMap { convertToResponse($0) }
            try await pushOfferingsToServer(offeringResponses)
            
            // Mark as clean after successful upload
            for offering in dirtyOfferings {
                offering.e = false
            }
            try dataManager.saveContext()
        }
        
        // 3. Pull latest data from server
        let lastSyncTime = userDefaults.object(forKey: SyncKeys.lastOfferingSync) as? Int64
        let serverOfferings = try await pullOfferingsFromServer(lastSyncTime: lastSyncTime)
        
        // 4. Update local database
        try await updateLocalDatabase(with: serverOfferings, userId: userId)
        
        // 5. Sync categories
        try await syncCategories()
        
        // 6. Update last sync time
        userDefaults.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: SyncKeys.lastOfferingSync)
    }
    
    // MARK: - Push Operations
    private func pushOfferingsToServer(_ offerings: [GSUResponse]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.setMyOfferings(offerings: offerings) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Pull Operations
    private func pullOfferingsFromServer(lastSyncTime: Int64?) async throws -> [GSUResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.syncMyOfferings(lastSyncTime: lastSyncTime) { result in
                switch result {
                case .success(let offerings):
                    continuation.resume(returning: offerings)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func pullLinkedOfferingsFromServer(lastSyncTime: Int64?) async throws -> [GSUResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.syncLinkedOfferings(lastSyncTime: lastSyncTime) { result in
                switch result {
                case .success(let offerings):
                    continuation.resume(returning: offerings)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Database Updates
    private func updateLocalDatabase(with serverOfferings: [GSUResponse], userId: String) async throws {
        try dataManager.syncOfferings(from: serverOfferings, userId: userId)
    }
    
    // MARK: - Category Synchronization
    @MainActor
    func syncCategories() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.syncCategories { result in
                switch result {
                case .success(let categories):
                    do {
                        try self.dataManager.saveCategories(categories)
                        self.userDefaults.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: SyncKeys.lastCategorySync)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Linked Offerings Sync
    @MainActor
    func syncLinkedOfferings(userId: String) async throws {
        let lastSyncTime = userDefaults.object(forKey: SyncKeys.lastLinkedOfferingSync) as? Int64
        let linkedOfferings = try await pullLinkedOfferingsFromServer(lastSyncTime: lastSyncTime)
        
        // Update linked offerings in database
        try await updateLocalDatabase(with: linkedOfferings, userId: userId)
        
        userDefaults.set(Int64(Date().timeIntervalSince1970 * 1000), forKey: SyncKeys.lastLinkedOfferingSync)
    }
    
    // MARK: - Search Operations
    func searchMyOfferings(searchText: String) async throws -> [GSUResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.searchMyOfferings(searchText: searchText) { result in
                switch result {
                case .success(let offerings):
                    continuation.resume(returning: offerings)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchOfferingsOfSource(sourceId: String, searchText: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> [GSUResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.fetchOfferingsOfSource(sourceId: sourceId, searchText: searchText, limit: limit, offset: offset) { result in
                switch result {
                case .success(let offerings):
                    continuation.resume(returning: offerings)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Image Upload
    func uploadOfferingImage(_ imageData: Data) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            apiService.uploadOfferingImage(imageData: imageData) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Conversion Helpers
    private func convertToResponse(_ gsu: CDGSU) -> GSUResponse? {
        guard let gid = gsu.gid else { return nil }
        
        let variants = (gsu.variants?.allObjects as? [CDVariant] ?? [])
            .compactMap(convertToResponse)
        
        let prices = (gsu.prices?.allObjects as? [CDPrice] ?? [])
            .compactMap(convertToResponse)
        
        let sources = (gsu.sources?.allObjects as? [CDGSUSource] ?? [])
            .compactMap(convertToResponse)
        
        return GSUResponse(
            gid: gid,
            sid: gsu.sid,
            gci: gsu.gci,
            sdc: nil, // TODO: Add sdc property to CDGSU entity
            nam: gsu.nam,
            shn: gsu.shn,
            dsc: gsu.dsc,
            bcd: nil, // TODO: Add bcd property to CDGSU entity
            img: gsu.img,
            ul: gsu.ul,
            cl: gsu.cl,
            cc: gsu.cc,
            pub: gsu.pub,
            anp: gsu.anp,
            sdt: gsu.sdt,
            edt: gsu.edt,
            ca: gsu.ca,
            cb: gsu.cb,
            ua: gsu.ua,
            ub: gsu.ub,
            d: gsu.d,
            e: gsu.e,
            variants: variants.isEmpty ? nil : variants,
            prices: prices.isEmpty ? nil : prices,
            sources: sources.isEmpty ? nil : sources
        )
    }
    
    private func convertToResponse(_ variant: CDVariant) -> VariantResponse? {
        guard let vid = variant.vid, let gid = variant.gid else { return nil }
        
        return VariantResponse(
            vid: vid,
            gid: gid,
            vnm: variant.vnm,
            bcd: variant.bcd,
            img: variant.img,
            cl: variant.cl,
            cc: variant.cc,
            pub: variant.pub,
            s: variant.s
        )
    }
    
    private func convertToResponse(_ price: CDPrice) -> PriceResponse? {
        guard let gid = price.gid else { return nil }
        
        return PriceResponse(
            id: price.id == 0 ? nil : price.id,
            gid: gid,
            vid: price.vid,
            odt: price.odt,
            trm: price.trm,
            bp: price.bp,
            sp: price.sp,
            stp: price.stp,
            pp: price.pp,
            dco: price.dco,
            dcm: price.dcm,
            dbps: price.dbps,
            dsps: price.dsps,
            dtps: price.dtps,
            dpps: price.dpps,
            tcss: price.tcss
        )
    }
    
    private func convertToResponse(_ source: CDGSUSource) -> GSUSourceResponse? {
        guard let gid = source.gid else { return nil }
        
        return GSUSourceResponse(
            id: source.id == 0 ? nil : source.id,
            gid: gid,
            vid: source.vid,
            sai: source.sai,
            sgi: source.sgi,
            svi: source.svi,
            npc: source.npc,
            qdi: source.qdi
        )
    }
    
    // MARK: - Utility Methods
    func getLastSyncTime() -> Date? {
        let timestamp = userDefaults.object(forKey: SyncKeys.lastOfferingSync) as? Int64
        guard let timestamp = timestamp else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
    }
    
    func hasPendingChanges(userId: String) -> Bool {
        return !dataManager.fetchDirtyOfferings(userId: userId).isEmpty
    }
    
    // MARK: - Background Sync
    func performBackgroundSync(userId: String) {
        Task {
            do {
                try await performFullSync(userId: userId)
                print("Background sync completed successfully")
            } catch {
                print("Background sync failed: \(error)")
            }
        }
    }
}