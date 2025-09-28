import Foundation
import SwiftUI

@MainActor
class OfferingViewModel: ObservableObject {
    @Published var offerings: [OfferingModel] = []
    @Published var categories: [CategoryModel] = []
    @Published var supplierDefinedCategories: [String] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var filter = OfferingFilter()
    @Published var searchText = ""
    
    private let dataManager = OfferingDataManager.shared
    private let syncManager = OfferingSyncManager.shared
    private var userId: String {
        return SessionManager.shared.getUserId() ?? ""
    }
    
    init() {
        loadCachedData()
    }
    
    // MARK: - Data Loading
    
    func loadMyOfferings() {
        isLoading = true
        errorMessage = nil
        
        // Load from local database first
        loadOfferingsFromDatabase()
        
        // Then sync with server
        Task {
            await syncWithServer()
        }
    }
    
    func refreshOfferings() async {
        isRefreshing = true
        await syncWithServer()
        isRefreshing = false
    }
    
    private func loadOfferingsFromDatabase() {
        let gsuEntities = dataManager.fetchOfferingsByCategory(
            userId: userId,
            categoryFilter: filter.categoryId,
            searchText: searchText.isEmpty ? nil : searchText
        )
        
        offerings = gsuEntities.map { dataManager.convertToModel($0) }
        updateSupplierDefinedCategories()
    }
    
    private func loadCachedData() {
        loadOfferingsFromDatabase()
        loadCategoriesFromDatabase()
    }
    
    private func loadCategoriesFromDatabase() {
        let categoryEntities = dataManager.fetchCategories()
        categories = categoryEntities.map { entity in
            CategoryModel(
                id: entity.gci ?? "",
                name: entity.cnm ?? "",
                type: entity.typ ?? "",
                subType: entity.stp,
                bannerId: entity.bannerId,
                iconId: entity.iconId,
                iconGreyId: entity.iconGreyId,
                sequence: entity.seq
            )
        }
    }
    
    private func updateSupplierDefinedCategories() {
        let categories = Set(offerings.compactMap { $0.supplierDefinedCategory })
        supplierDefinedCategories = Array(categories).sorted()
    }
    
    private func syncWithServer() async {
        do {
            try await syncManager.performFullSync(userId: userId)
            loadOfferingsFromDatabase()
            loadCategoriesFromDatabase()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Offering Management
    
    func createOffering(_ offering: OfferingModel) async {
        do {
            let gsu = createGSUEntity(from: offering)
            try dataManager.saveGSU(gsu)
            
            // Add to local array
            let offeringModel = dataManager.convertToModel(gsu)
            offerings.append(offeringModel)
            updateSupplierDefinedCategories()
            
            // Sync with server in background
            Task {
                await syncWithServer()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateOffering(_ offering: OfferingModel) async {
        guard let existingGSU = dataManager.fetchOffering(by: offering.gid) else {
            errorMessage = "Offering not found"
            return
        }
        
        do {
            updateGSUEntity(existingGSU, from: offering)
            try dataManager.saveGSU(existingGSU)
            
            // Update local array
            if let index = offerings.firstIndex(where: { $0.gid == offering.gid }) {
                offerings[index] = dataManager.convertToModel(existingGSU)
            }
            updateSupplierDefinedCategories()
            
            // Sync with server in background
            Task {
                await syncWithServer()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteOffering(_ offering: OfferingModel) async {
        guard let gsu = dataManager.fetchOffering(by: offering.gid) else {
            errorMessage = "Offering not found"
            return
        }
        
        do {
            try dataManager.deleteOffering(gsu)
            
            // Remove from local array
            offerings.removeAll { $0.gid == offering.gid }
            updateSupplierDefinedCategories()
            
            // Sync with server in background
            Task {
                await syncWithServer()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Search and Filter
    
    func searchOfferings(_ text: String) {
        searchText = text
        loadOfferingsFromDatabase()
    }
    
    func applyFilter(_ newFilter: OfferingFilter) {
        filter = newFilter
        loadOfferingsFromDatabase()
    }
    
    func clearFilters() {
        filter = OfferingFilter()
        searchText = ""
        loadOfferingsFromDatabase()
    }
    
    // MARK: - Image Upload
    
    func uploadImage(_ imageData: Data) async throws -> String {
        return try await syncManager.uploadOfferingImage(imageData)
    }
    
    // MARK: - Entity Creation Helpers
    
    private func createGSUEntity(from offering: OfferingModel) -> CDGSU {
        let context = CoreDataManager.shared.mainContext
        let gsu = CDGSU(context: context)
        
        gsu.gid = offering.gid
        gsu.sid = userId
        gsu.gci = offering.category
        gsu.sdc = offering.supplierDefinedCategory
        gsu.nam = offering.name
        gsu.shn = offering.shortName
        gsu.dsc = offering.description
        gsu.bcd = offering.barcode
        gsu.img = offering.imageIds.joined(separator: ",")
        gsu.ul = offering.unitLabel
        gsu.cl = offering.crateLabel
        gsu.cc = offering.crateCapacity
        gsu.pub = offering.isPublic
        gsu.anp = offering.availableSlots
        gsu.sdt = offering.startDate
        gsu.edt = offering.endDate
        gsu.ca = Int64(Date().timeIntervalSince1970 * 1000)
        gsu.cb = userId
        gsu.ua = Int64(Date().timeIntervalSince1970 * 1000)
        gsu.ub = userId
        gsu.d = false
        gsu.e = true // Mark as edited
        
        return gsu
    }
    
    private func updateGSUEntity(_ gsu: CDGSU, from offering: OfferingModel) {
        gsu.gci = offering.category
        gsu.sdc = offering.supplierDefinedCategory
        gsu.nam = offering.name
        gsu.shn = offering.shortName
        gsu.dsc = offering.description
        gsu.bcd = offering.barcode
        gsu.img = offering.imageIds.joined(separator: ",")
        gsu.ul = offering.unitLabel
        gsu.cl = offering.crateLabel
        gsu.cc = offering.crateCapacity
        gsu.pub = offering.isPublic
        gsu.anp = offering.availableSlots
        gsu.sdt = offering.startDate
        gsu.edt = offering.endDate
        gsu.ua = Int64(Date().timeIntervalSince1970 * 1000)
        gsu.ub = userId
        gsu.e = true // Mark as edited
    }
    
    // MARK: - Computed Properties
    
    var hasOfferings: Bool {
        return !offerings.isEmpty
    }
    
    var filteredOfferings: [OfferingModel] {
        return offerings // Already filtered in loadOfferingsFromDatabase
    }
    
    var offeringsByCategory: [String: [OfferingModel]] {
        return Dictionary(grouping: offerings) { offering in
            offering.supplierDefinedCategory ?? "Uncategorized"
        }
    }
    
    // MARK: - Background Operations
    
    func performBackgroundSync() {
        syncManager.performBackgroundSync(userId: userId)
    }
}