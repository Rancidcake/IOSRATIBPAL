import SwiftUI

struct OfferingsListView: View {
    @StateObject private var viewModel = OfferingViewModel()
    @State private var showingAddOffering = false
    @State private var showingFilters = false
    @State private var selectedOffering: OfferingModel?
    @State private var showingOfferingDetail = false
    @State private var searchText = ""
    @State private var showOrganizedView = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("My Offerings")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        showOrganizedView.toggle()
                    }) {
                        Image(systemName: showOrganizedView ? "list.bullet" : "rectangle.3.group")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Button(action: {
                        showingAddOffering = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.blue)
            
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    Task {
                        await viewModel.performAdvancedSearch(searchText)
                    }
                }, onClearButtonClicked: {
                    searchText = ""
                    viewModel.searchOfferings("")
                })
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filters Bar
                if viewModel.filter.hasActiveFilters {
                    ActiveFiltersView(filter: viewModel.filter) {
                        viewModel.clearFilters()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Content
                if viewModel.isLoading && viewModel.offerings.isEmpty {
                    LoadingView {
                        // Handle loading completion if needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.offerings.isEmpty {
                    // Android-style empty state
                    VStack {
                        Spacer()
                        Text("No offerings available")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    offeringsContent
                }
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            await viewModel.refreshOfferings()
        }
        .sheet(isPresented: $showingAddOffering) {
            OfferingCategorySelectionView(offeringViewModel: viewModel)
        }
        .sheet(isPresented: $showingFilters) {
            OfferingFiltersView(
                filter: viewModel.filter,
                categories: viewModel.categories,
                supplierDefinedCategories: viewModel.supplierDefinedCategories
            ) { newFilter in
                viewModel.applyFilter(newFilter)
            }
        }
        .sheet(item: $selectedOffering) { offering in
            OfferingDetailView(offering: offering, viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.loadMyOfferings()
        }
    }
    
    private var offeringsContent: some View {
        List {
            if showOrganizedView {
                // Enhanced organization with headers (Android pattern)
                ForEach(viewModel.getOfferingsWithHeaders()) { item in
                    switch item {
                    case .header(let title):
                        CategoryHeaderView(title: title)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    case .offering(let offering):
                        OfferingRowView(offering: offering) {
                            selectedOffering = offering
                        }
                    }
                }
            } else if viewModel.categories.isEmpty {
                // Simple list when no categories
                ForEach(viewModel.offerings, id: \.gid) { offering in
                    OfferingRowView(offering: offering) {
                        selectedOffering = offering
                    }
                }
                .onDelete(perform: deleteOfferings)
            } else {
                // Traditional grouped by category
                ForEach(viewModel.offeringsByCategory.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(viewModel.offeringsByCategory[category] ?? [], id: \.gid) { offering in
                            OfferingRowView(offering: offering) {
                                selectedOffering = offering
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteOfferings(at offsets: IndexSet) {
        for index in offsets {
            let offering = viewModel.offerings[index]
            Task {
                await viewModel.deleteOffering(offering)
            }
        }
    }
}

// MARK: - Supporting Views

struct SearchBar: View {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    var onClearButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search offerings...", text: $text)
                    .onSubmit {
                        onSearchButtonClicked()
                    }
                
                if !text.isEmpty {
                    Button(action: onClearButtonClicked) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            if !text.isEmpty {
                Button("Search", action: onSearchButtonClicked)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ActiveFiltersView: View {
    let filter: OfferingFilter
    let onClear: () -> Void
    
    var body: some View {
        HStack {
            Text("Active Filters:")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if let category = filter.categoryId {
                        FilterChip(text: "Category: \(category)", onRemove: onClear)
                    }
                    
                    if let supplierCategory = filter.supplierDefinedCategory {
                        FilterChip(text: "Type: \(supplierCategory)", onRemove: onClear)
                    }
                    
                    if filter.isPublicOnly {
                        FilterChip(text: "Public Only", onRemove: onClear)
                    }
                    
                    if filter.hasVariantsOnly {
                        FilterChip(text: "Has Variants", onRemove: onClear)
                    }
                }
            }
            
            Spacer()
            
            Button("Clear All", action: onClear)
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(8)
    }
}

struct EmptyOfferingsView: View {
    let onAddOffering: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Offerings Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start building your catalog by adding your first offering")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Add First Offering") {
                onAddOffering()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct OfferingRowView: View {
    let offering: OfferingModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(offering.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let description = offering.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        if let currentPrice = offering.currentPrice {
                            VStack(alignment: .leading, spacing: 2) {
                                if currentPrice.hasPromotion {
                                    HStack(spacing: 4) {
                                        Text("₹\(currentPrice.sellPrice, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        
                                        Text("₹\(currentPrice.strikeThroughPrice, specifier: "%.2f")")
                                            .font(.caption)
                                            .strikethrough()
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Text("₹\(currentPrice.sellPrice, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            if offering.hasVariants {
                                Text("\(offering.variants.count) variants")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            if offering.isPublic {
                                Text("Public")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Header View
struct CategoryHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    OfferingsListView()
}
