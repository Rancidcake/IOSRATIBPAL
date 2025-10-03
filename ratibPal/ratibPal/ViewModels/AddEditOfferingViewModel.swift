import Foundation
import SwiftUI
import UIKit

@MainActor
class AddEditOfferingViewModel: ObservableObject {
    @Published var offering: OfferingModel
    @Published var variants: [VariantModel] = []
    @Published var prices: [PriceModel] = []
    @Published var selectedImages: [UIImage] = []
    @Published var uploadedImageIds: [String] = []
    @Published var availableTimeSlots: [TimeSlot] = []
    @Published var isUploading = false
    @Published var errorMessage: String?
    
    // Form fields
    @Published var name = ""
    @Published var shortName = ""
    @Published var description = ""
    @Published var barcode = ""
    @Published var unitLabel = ""
    @Published var crateLabel = ""
    @Published var crateCapacity: Int = 0
    @Published var isPublic = false
    @Published var category = ""
    @Published var supplierDefinedCategory = ""
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    
    // Pricing
    @Published var basePrice: Double = 0
    @Published var sellPrice: Double = 0
    @Published var strikeThroughPrice: Double = 0
    @Published var purchasePrice: Double = 0
    @Published var deliveryChargePerOrder: Double = 0
    @Published var deliveryChargePerMonth: Double = 0
    
    private let offeringViewModel: OfferingViewModel
    // Sync manager removed - focusing on local storage only
    private var isEditMode: Bool
    
    init(offering: OfferingModel? = nil, offeringViewModel: OfferingViewModel) {
        self.offeringViewModel = offeringViewModel
        self.isEditMode = offering != nil
        
        if let offering = offering {
            self.offering = offering
        } else {
            // Initialize with a temporary offering first
            self.offering = OfferingModel(
                gid: "",
                name: "",
                shortName: nil,
                description: nil,
                barcode: nil,
                imageIds: [],
                unitLabel: nil,
                crateLabel: nil,
                crateCapacity: 0,
                isPublic: false,
                availableSlots: nil,
                startDate: 0,
                endDate: 0,
                category: nil,
                supplierDefinedCategory: nil,
                variants: [],
                prices: [],
                sources: []
            )
        }
        
        // Now set up the UI fields
        if let offering = offering {
            setupFromOffering(offering)
        } else {
            // Set up for new offering
            self.offering = createNewOffering()
        }
    }
    
    // MARK: - Setup
    
    private func setupFromOffering(_ offering: OfferingModel) {
        name = offering.name
        shortName = offering.shortName ?? ""
        description = offering.description ?? ""
        barcode = offering.barcode ?? ""
        unitLabel = offering.unitLabel ?? ""
        crateLabel = offering.crateLabel ?? ""
        crateCapacity = Int(offering.crateCapacity)
        isPublic = offering.isPublic
        category = offering.category ?? ""
        supplierDefinedCategory = offering.supplierDefinedCategory ?? ""
        
        // Convert dates
        startDate = dateFromInt(offering.startDate) ?? Date()
        endDate = dateFromInt(offering.endDate) ?? Date().addingTimeInterval(30 * 24 * 60 * 60)
        
        // Convert time slots
        availableTimeSlots = TimeSlot.fromString(offering.availableSlots)
        
        // Set up variants, prices, and images
        variants = offering.variants
        prices = offering.prices
        uploadedImageIds = offering.imageIds
        
        // Set current price if available
        if let currentPrice = offering.currentPrice {
            basePrice = currentPrice.basePrice
            sellPrice = currentPrice.sellPrice
            strikeThroughPrice = currentPrice.strikeThroughPrice
            purchasePrice = currentPrice.purchasePrice
            deliveryChargePerOrder = currentPrice.deliveryChargePerOrder
            deliveryChargePerMonth = currentPrice.deliveryChargePerMonth
        }
    }
    
    private func createNewOffering() -> OfferingModel {
        return OfferingModel(
            gid: UUID().uuidString,
            name: "",
            shortName: nil,
            description: nil,
            barcode: nil,
            imageIds: [],
            unitLabel: nil,
            crateLabel: nil,
            crateCapacity: 0,
            isPublic: false,
            availableSlots: nil,
            startDate: intFromDate(Date()),
            endDate: intFromDate(Date().addingTimeInterval(30 * 24 * 60 * 60)),
            category: nil,
            supplierDefinedCategory: nil,
            variants: [],
            prices: [],
            sources: []
        )
    }
    
    // MARK: - Image Management
    
    func addImages(_ images: [UIImage]) {
        selectedImages.append(contentsOf: images)
    }
    
    func removeImage(at index: Int) {
        if index < selectedImages.count {
            selectedImages.remove(at: index)
        } else {
            let uploadedIndex = index - selectedImages.count
            if uploadedIndex < uploadedImageIds.count {
                uploadedImageIds.remove(at: uploadedIndex)
            }
        }
    }
    
    func uploadImages() async {
        guard !selectedImages.isEmpty else { return }
        
        isUploading = true
        errorMessage = nil
        
        for image in selectedImages {
            guard image.jpegData(compressionQuality: 0.8) != nil else {
                continue
            }
            
            // Generate local image ID - sync removed
            let imageId = "local_image_\(UUID().uuidString)"
            uploadedImageIds.append(imageId)
        }
        
        selectedImages.removeAll()
        isUploading = false
    }
    
    // MARK: - Time Slot Management
    
    func toggleTimeSlot(_ slot: TimeSlot) {
        if availableTimeSlots.contains(slot) {
            availableTimeSlots.removeAll { $0 == slot }
        } else {
            availableTimeSlots.append(slot)
        }
    }
    
    func isTimeSlotSelected(_ slot: TimeSlot) -> Bool {
        return availableTimeSlots.contains(slot)
    }
    
    // MARK: - Variant Management
    
    func addVariant() {
        let variant = VariantModel(
            vid: UUID().uuidString,
            name: "Variant \(variants.count + 1)",
            barcode: nil,
            imageIds: [],
            crateLabel: nil,
            crateCapacity: 0,
            isPublic: true,
            sequence: Int32(variants.count)
        )
        variants.append(variant)
    }
    
    func removeVariant(at index: Int) {
        guard index < variants.count else { return }
        variants.remove(at: index)
        
        // Update sequences
        for i in 0..<variants.count {
            variants[i] = VariantModel(
                vid: variants[i].vid,
                name: variants[i].name,
                barcode: variants[i].barcode,
                imageIds: variants[i].imageIds,
                crateLabel: variants[i].crateLabel,
                crateCapacity: variants[i].crateCapacity,
                isPublic: variants[i].isPublic,
                sequence: Int32(i)
            )
        }
    }
    
    func updateVariant(at index: Int, name: String) {
        guard index < variants.count else { return }
        
        variants[index] = VariantModel(
            vid: variants[index].vid,
            name: name,
            barcode: variants[index].barcode,
            imageIds: variants[index].imageIds,
            crateLabel: variants[index].crateLabel,
            crateCapacity: variants[index].crateCapacity,
            isPublic: variants[index].isPublic,
            sequence: variants[index].sequence
        )
    }
    
    // MARK: - Price Management
    
    func addPrice() {
        let price = PriceModel(
            id: nil,
            variantId: nil,
            applicableDate: intFromDate(Date()),
            termMonths: 0,
            basePrice: basePrice,
            sellPrice: sellPrice,
            strikeThroughPrice: strikeThroughPrice,
            purchasePrice: purchasePrice,
            deliveryChargePerOrder: deliveryChargePerOrder,
            deliveryChargePerMonth: deliveryChargePerMonth,
            dayWiseBasePrices: nil,
            dayWiseSellPrices: nil,
            dayWiseStrikePrices: nil,
            dayWisePurchasePrices: nil,
            taxCodes: nil
        )
        prices.append(price)
    }
    
    func removePrice(at index: Int) {
        guard index < prices.count else { return }
        prices.remove(at: index)
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               sellPrice >= 0 &&
               basePrice >= 0
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Name is required")
        }
        
        if sellPrice < 0 {
            errors.append("Sell price cannot be negative")
        }
        
        if basePrice < 0 {
            errors.append("Base price cannot be negative")
        }
        
        if strikeThroughPrice > 0 && strikeThroughPrice <= sellPrice {
            errors.append("Strike through price should be higher than sell price")
        }
        
        return errors
    }
    
    // MARK: - Save Operation
    
    func saveOffering() async -> Bool {
        guard isValid else {
            errorMessage = validationErrors.joined(separator: "\n")
            return false
        }
        
        // Upload images first if needed
        await uploadImages()
        
        // Create updated offering model
        let updatedOffering = createOfferingModel()
        
        if isEditMode {
            await offeringViewModel.updateOffering(updatedOffering)
        } else {
            await offeringViewModel.createOffering(updatedOffering)
        }
        return true
    }
    
    private func createOfferingModel() -> OfferingModel {
        // Add current price if needed
        if prices.isEmpty || (basePrice > 0 || sellPrice > 0) {
            let currentPrice = PriceModel(
                id: nil,
                variantId: nil,
                applicableDate: intFromDate(Date()),
                termMonths: 0,
                basePrice: basePrice,
                sellPrice: sellPrice,
                strikeThroughPrice: strikeThroughPrice,
                purchasePrice: purchasePrice,
                deliveryChargePerOrder: deliveryChargePerOrder,
                deliveryChargePerMonth: deliveryChargePerMonth,
                dayWiseBasePrices: nil,
                dayWiseSellPrices: nil,
                dayWiseStrikePrices: nil,
                dayWisePurchasePrices: nil,
                taxCodes: nil
            )
            
            if prices.isEmpty {
                prices.append(currentPrice)
            } else {
                prices[0] = currentPrice
            }
        }
        
        return OfferingModel(
            gid: offering.gid,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            shortName: shortName.isEmpty ? nil : shortName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            barcode: barcode.isEmpty ? nil : barcode.trimmingCharacters(in: .whitespacesAndNewlines),
            imageIds: uploadedImageIds,
            unitLabel: unitLabel.isEmpty ? nil : unitLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            crateLabel: crateLabel.isEmpty ? nil : crateLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            crateCapacity: Int32(crateCapacity),
            isPublic: isPublic,
            availableSlots: availableTimeSlots.isEmpty ? nil : TimeSlot.toString(availableTimeSlots),
            startDate: intFromDate(startDate),
            endDate: intFromDate(endDate),
            category: category.isEmpty ? nil : category,
            supplierDefinedCategory: supplierDefinedCategory.isEmpty ? nil : supplierDefinedCategory.trimmingCharacters(in: .whitespacesAndNewlines),
            variants: variants,
            prices: prices,
            sources: offering.sources
        )
    }
    
    // MARK: - Utility Methods
    
    private func dateFromInt(_ dateInt: Int32) -> Date? {
        let dateString = String(dateInt)
        return DateFormatter.yyyyMMdd.date(from: dateString)
    }
    
    private func intFromDate(_ date: Date) -> Int32 {
        let dateString = DateFormatter.yyyyMMdd.string(from: date)
        return Int32(dateString) ?? 0
    }
    
    // MARK: - Computed Properties
    
    var allImageIds: [String] {
        return uploadedImageIds
    }
    
    var totalImages: Int {
        return selectedImages.count + uploadedImageIds.count
    }
    
    var hasUnsavedImages: Bool {
        return !selectedImages.isEmpty
    }
}