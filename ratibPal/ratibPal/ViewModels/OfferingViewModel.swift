import Foundation
import SwiftUI
import Combine

// MARK: - Supporting Types for Organization
enum OfferingListItem: Identifiable {
    case header(String)
    case offering(OfferingModel)
    
    var id: String {
        switch self {
        case .header(let title):
            return "header_\(title)"
        case .offering(let offering):
            return "offering_\(offering.id)"
        }
    }
}

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
    // Sync manager removed - focusing on local storage only
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
        
        // Load from local database only
        loadOfferingsFromDatabase()
        loadCategoriesFromDatabase()
        isLoading = false
    }
    
    func refreshOfferings() async {
        isRefreshing = true
        // Refresh from local storage only
        refreshLocalData()
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
        // Get distinct categories using the enhanced data manager method
        supplierDefinedCategories = dataManager.getDistinctCategories(
            userId: userId, 
            distinctGci: false, 
            distinctSDC: true
        )
    }
    
    // Server sync removed - focusing on local storage only
    private func refreshLocalData() {
        loadOfferingsFromDatabase()
        loadCategoriesFromDatabase()
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Search and Filter
    
    func searchOfferings(_ text: String) {
        searchText = text
        loadOfferingsFromDatabase()
    }
    
    // Enhanced search with server fallback (following Android pattern)
    func performAdvancedSearch(_ text: String, categoryId: String? = nil) async {
        searchText = text
        
        // Search locally only
        loadOfferingsFromDatabase()
        
        print("[OfferingViewModel] Server search disabled - using local data only")
    }
    
    // Database sync methods removed - focusing on local storage only
    
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
    
    // Image upload removed - focusing on local storage only
    func uploadImage(_ imageData: Data) async throws -> String {
        // Return a local placeholder image ID
        return "local_image_\(UUID().uuidString)"
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
            let categoryKey = (offering.category ?? "") + (offering.supplierDefinedCategory ?? "")
            return categoryKey.isEmpty ? "Uncategorized" : (offering.supplierDefinedCategory ?? offering.category ?? "Uncategorized")
        }
    }
    
    // MARK: - Category Organization (Following Android pattern)
    func organizeOfferingsByCategory() -> [(header: String, offerings: [OfferingModel])] {
        let grouped = offeringsByCategory
        return grouped.map { (key, value) in
            (header: key, offerings: value.sorted { $0.name < $1.name })
        }.sorted { $0.header < $1.header }
    }
    
    func getOfferingsWithHeaders() -> [OfferingListItem] {
        var items: [OfferingListItem] = []
        let organized = organizeOfferingsByCategory()
        
        for section in organized {
            // Add category header
            items.append(.header(section.header))
            
            // Add offerings in this category
            for offering in section.offerings {
                items.append(.offering(offering))
            }
        }
        
        return items
    }
    
    // MARK: - Background Operations
    
    // Background sync removed - focusing on local storage only
}