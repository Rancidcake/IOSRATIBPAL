import SwiftUI

struct OfferingDetailView: View {
    let offering: OfferingModel
    let viewModel: OfferingViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var selectedVariant: VariantModel?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    descriptionSection
                    pricingSection
                    availabilitySection
                    variantsSection
                    sourcesSection
                    technicalDetailsSection
                }
                .padding()
            }
            .navigationTitle(offering.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit") {
                            showingEditView = true
                        }
                        
                        Button("Delete", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                AddEditOfferingView(offeringViewModel: viewModel, editingOffering: offering)
            }
            .alert("Delete Offering", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteOffering(offering)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(offering.displayName)'? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image gallery
            if !offering.imageIds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(offering.imageIds, id: \.self) { imageId in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No Image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // Title and basic info
            VStack(alignment: .leading, spacing: 8) {
                Text(offering.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let shortName = offering.shortName, !shortName.isEmpty {
                    Text(shortName)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if offering.isPublic {
                        Label("Public", systemImage: "globe")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                    
                    if offering.hasVariants {
                        Label("\(offering.variants.count) variants", systemImage: "square.stack.3d.up")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    if let barcode = offering.barcode, !barcode.isEmpty {
                        Label(barcode, systemImage: "barcode")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        Group {
            if let description = offering.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pricing")
                .font(.headline)
            
            if let currentPrice = offering.currentPrice {
                VStack(spacing: 8) {
                    PriceCardView(price: currentPrice, isCurrentPrice: true)
                    
                    if offering.prices.count > 1 {
                        Text("Price History")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(offering.prices.dropFirst(), id: \.id) { price in
                            PriceCardView(price: price, isCurrentPrice: false)
                        }
                    }
                }
            } else {
                Text("No pricing information available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Availability")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if offering.startDate > 0 && offering.endDate > 0 {
                    HStack {
                        Text("Available from:")
                        Spacer()
                        Text(dateString(from: offering.startDate))
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Available until:")
                        Spacer()
                        Text(dateString(from: offering.endDate))
                            .fontWeight(.medium)
                    }
                }
                
                if let timeSlots = offering.availableSlots, !timeSlots.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time Slots:")
                            .font(.subheadline)
                        
                        let slots = TimeSlot.fromString(timeSlots)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                            ForEach(slots, id: \.self) { slot in
                                Text(slot.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                if let unitLabel = offering.unitLabel, !unitLabel.isEmpty {
                    HStack {
                        Text("Unit:")
                        Spacer()
                        Text(unitLabel)
                            .fontWeight(.medium)
                    }
                }
                
                if let crateLabel = offering.crateLabel, !crateLabel.isEmpty {
                    HStack {
                        Text("Crate:")
                        Spacer()
                        Text("\(crateLabel) (Capacity: \(offering.crateCapacity))")
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    private var variantsSection: some View {
        Group {
            if offering.hasVariants {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Variants")
                        .font(.headline)
                    
                    ForEach(offering.variants, id: \.vid) { variant in
                        VariantCardView(variant: variant) {
                            selectedVariant = variant
                        }
                    }
                }
            }
        }
    }
    
    private var sourcesSection: some View {
        Group {
            if !offering.sources.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sources")
                        .font(.headline)
                    
                    ForEach(offering.sources, id: \.id) { source in
                        SourceCardView(source: source)
                    }
                }
            }
        }
    }
    
    private var technicalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Technical Details")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(label: "Offering ID", value: offering.gid)
                
                if let category = offering.category, !category.isEmpty {
                    DetailRow(label: "Category", value: category)
                }
                
                if let supplierCategory = offering.supplierDefinedCategory, !supplierCategory.isEmpty {
                    DetailRow(label: "Supplier Category", value: supplierCategory)
                }
                
                DetailRow(label: "Public Offering", value: offering.isPublic ? "Yes" : "No")
                DetailRow(label: "Has Variants", value: offering.hasVariants ? "Yes" : "No")
                DetailRow(label: "Total Images", value: "\(offering.imageIds.count)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func dateString(from dateInt: Int32) -> String {
        let dateString = String(dateInt)
        if let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            return DateFormatter.displayDate.string(from: date)
        }
        return dateString
    }
}

// MARK: - Supporting Views

struct PriceCardView: View {
    let price: PriceModel
    let isCurrentPrice: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isCurrentPrice ? "Current Price" : "Price from \(dateString(from: price.applicableDate))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if isCurrentPrice {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if price.hasPromotion {
                        HStack(spacing: 8) {
                            Text("₹\(price.sellPrice, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("₹\(price.strikeThroughPrice, specifier: "%.2f")")
                                .font(.body)
                                .strikethrough()
                                .foregroundColor(.gray)
                            
                            if let discount = price.discountPercentage {
                                Text("\(discount, specifier: "%.0f")% OFF")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(4)
                            }
                        }
                    } else {
                        Text("₹\(price.sellPrice, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    if price.basePrice > 0 && price.basePrice != price.sellPrice {
                        Text("Base: ₹\(price.basePrice, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if price.deliveryChargePerOrder > 0 {
                        Text("Delivery: ₹\(price.deliveryChargePerOrder, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if price.termMonths > 0 {
                        Text("Term: \(price.termMonths) months")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func dateString(from dateInt: Int32) -> String {
        let dateString = String(dateInt)
        if let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            return DateFormatter.displayDate.string(from: date)
        }
        return dateString
    }
}

struct VariantCardView: View {
    let variant: VariantModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(variant.sequence + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(variant.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if let barcode = variant.barcode, !barcode.isEmpty {
                            Text("Barcode: \(barcode)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        if variant.isPublic {
                            Text("Public")
                                .font(.caption)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(3)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SourceCardView: View {
    let source: GSUSourceModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let affiliateId = source.sourceAffiliateId {
                Text("Source Affiliate: \(affiliateId)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let gsuId = source.sourceGSUId {
                        Text("GSU ID: \(gsuId)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if let variantId = source.sourceVariantId {
                        Text("Variant ID: \(variantId)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if source.needPercentage > 0 {
                        Text("Need: \(source.needPercentage, specifier: "%.1f")%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if source.quantityDivision > 0 {
                        Text("Qty Division: \(source.quantityDivision, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let sampleOffering = OfferingModel(
        gid: "sample-id",
        name: "Sample Offering",
        shortName: "Sample",
        description: "This is a sample offering for preview purposes",
        barcode: "123456789",
        imageIds: [],
        unitLabel: "kg",
        crateLabel: "Box",
        crateCapacity: 10,
        isPublic: true,
        availableSlots: "AM,PM",
        startDate: 20240901,
        endDate: 20241231,
        category: "Goods",
        supplierDefinedCategory: "Food Items",
        variants: [],
        prices: [],
        sources: []
    )
    
    OfferingDetailView(offering: sampleOffering, viewModel: OfferingViewModel())
}