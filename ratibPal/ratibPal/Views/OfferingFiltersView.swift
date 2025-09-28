import SwiftUI

struct OfferingFiltersView: View {
    let currentFilter: OfferingFilter
    let categories: [CategoryModel]
    let supplierDefinedCategories: [String]
    let onApplyFilter: (OfferingFilter) -> Void
    
    @State private var filter: OfferingFilter
    @Environment(\.dismiss) private var dismiss
    
    init(filter: OfferingFilter, categories: [CategoryModel], supplierDefinedCategories: [String], onApplyFilter: @escaping (OfferingFilter) -> Void) {
        self.currentFilter = filter
        self.categories = categories
        self.supplierDefinedCategories = supplierDefinedCategories
        self.onApplyFilter = onApplyFilter
        self._filter = State(initialValue: filter)
    }
    
    var body: some View {
        NavigationView {
            Form {
                categorySection
                supplierCategorySection
                availabilitySection
                dateRangeSection
                otherFiltersSection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApplyFilter(filter)
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        filter = OfferingFilter()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $filter.categoryId) {
                Text("All Categories")
                    .tag(nil as String?)
                
                ForEach(categories, id: \.id) { category in
                    Text(category.displayName)
                        .tag(category.id as String?)
                }
            }
            .pickerStyle(.automatic)
        }
    }
    
    private var supplierCategorySection: some View {
        Section("Supplier Category") {
            Picker("Supplier Category", selection: $filter.supplierDefinedCategory) {
                Text("All Types")
                    .tag(nil as String?)
                
                ForEach(supplierDefinedCategories, id: \.self) { category in
                    Text(category)
                        .tag(category as String?)
                }
            }
            .pickerStyle(.automatic)
        }
    }
    
    private var availabilitySection: some View {
        Section("Availability") {
            Toggle("Public Only", isOn: $filter.isPublicOnly)
            Toggle("Has Variants Only", isOn: $filter.hasVariantsOnly)
        }
    }
    
    private var dateRangeSection: some View {
        Section("Date Range") {
            DatePicker(
                "Start Date",
                selection: Binding(
                    get: { filter.startDate ?? Date() },
                    set: { filter.startDate = $0 }
                ),
                displayedComponents: .date
            )
            .disabled(filter.startDate == nil)
            
            DatePicker(
                "End Date",
                selection: Binding(
                    get: { filter.endDate ?? Date() },
                    set: { filter.endDate = $0 }
                ),
                displayedComponents: .date
            )
            .disabled(filter.endDate == nil)
            
            Toggle("Enable Date Range", isOn: Binding(
                get: { filter.startDate != nil || filter.endDate != nil },
                set: { enabled in
                    if enabled {
                        if filter.startDate == nil {
                            filter.startDate = Date()
                        }
                        if filter.endDate == nil {
                            filter.endDate = Date()
                        }
                    } else {
                        filter.startDate = nil
                        filter.endDate = nil
                    }
                }
            ))
        }
    }
    
    private var otherFiltersSection: some View {
        Section("Search") {
            TextField("Search text", text: Binding(
                get: { filter.searchText ?? "" },
                set: { text in
                    filter.searchText = text.isEmpty ? nil : text
                }
            ))
            
            if let searchText = filter.searchText, !searchText.isEmpty {
                Button("Clear Search") {
                    filter.searchText = nil
                }
                .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Filter Summary View

struct FilterSummaryView: View {
    let filter: OfferingFilter
    let categories: [CategoryModel]
    
    var body: some View {
        if filter.hasActiveFilters {
            VStack(alignment: .leading, spacing: 8) {
                Text("Active Filters")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let categoryId = filter.categoryId {
                        let categoryName = categories.first { $0.id == categoryId }?.displayName ?? categoryId
                        FilterSummaryRow(label: "Category", value: categoryName)
                    }
                    
                    if let supplierCategory = filter.supplierDefinedCategory {
                        FilterSummaryRow(label: "Supplier Category", value: supplierCategory)
                    }
                    
                    if let searchText = filter.searchText {
                        FilterSummaryRow(label: "Search", value: searchText)
                    }
                    
                    if filter.isPublicOnly {
                        FilterSummaryRow(label: "Visibility", value: "Public Only")
                    }
                    
                    if filter.hasVariantsOnly {
                        FilterSummaryRow(label: "Variants", value: "Has Variants Only")
                    }
                    
                    if let startDate = filter.startDate {
                        FilterSummaryRow(label: "Start Date", value: DateFormatter.displayDate.string(from: startDate))
                    }
                    
                    if let endDate = filter.endDate {
                        FilterSummaryRow(label: "End Date", value: DateFormatter.displayDate.string(from: endDate))
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct FilterSummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

// MARK: - Quick Filter Buttons

struct QuickFiltersView: View {
    let onFilterSelected: (OfferingFilter) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickFilterButton(title: "All", filter: OfferingFilter(), onTap: onFilterSelected)
                
                QuickFilterButton(
                    title: "Public Only",
                    filter: OfferingFilter(isPublicOnly: true),
                    onTap: onFilterSelected
                )
                
                QuickFilterButton(
                    title: "With Variants",
                    filter: OfferingFilter(hasVariantsOnly: true),
                    onTap: onFilterSelected
                )
                
                QuickFilterButton(
                    title: "This Week",
                    filter: OfferingFilter(
                        startDate: Calendar.current.startOfWeek(for: Date()),
                        endDate: Calendar.current.endOfWeek(for: Date())
                    ),
                    onTap: onFilterSelected
                )
                
                QuickFilterButton(
                    title: "This Month",
                    filter: OfferingFilter(
                        startDate: Calendar.current.startOfMonth(for: Date()),
                        endDate: Calendar.current.endOfMonth(for: Date())
                    ),
                    onTap: onFilterSelected
                )
            }
            .padding(.horizontal)
        }
    }
}

struct QuickFilterButton: View {
    let title: String
    let filter: OfferingFilter
    let onTap: (OfferingFilter) -> Void
    
    var body: some View {
        Button(action: {
            onTap(filter)
        }) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
        }
    }
}

// MARK: - Calendar Extensions

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfWeek(for date: Date) -> Date {
        guard let startOfWeek = self.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return date
        }
        return self.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
    }
    
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfMonth(for date: Date) -> Date {
        guard let startOfMonth = self.date(from: dateComponents([.year, .month], from: date)) else {
            return date
        }
        return self.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? date
    }
}

#Preview {
    OfferingFiltersView(
        filter: OfferingFilter(),
        categories: [
            CategoryModel(id: "1", name: "Food Items", type: "G", subType: nil, bannerId: nil, iconId: nil, iconGreyId: nil, sequence: 1),
            CategoryModel(id: "2", name: "Electronics", type: "G", subType: nil, bannerId: nil, iconId: nil, iconGreyId: nil, sequence: 2)
        ],
        supplierDefinedCategories: ["Fresh Produce", "Packaged Foods", "Beverages"]
    ) { _ in }
}