//
//  AddOfferingView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 17/07/25.
//

import SwiftUI

struct AddOfferingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var showAddOfferingDetails = false
    @State private var selectedCategoryName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Select offering category")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible placeholder to center the title
                    Image(systemName: "arrow.left")
                        .opacity(0)
                        .font(.title2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                
                // Tab Bar
                HStack(spacing: 0) {
                    TabButton(title: "Goods", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "Services", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabButton(title: "Utilities", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .background(Color.white)
                
                // Content
                TabView(selection: $selectedTab) {
                    GoodsTabView(showAddOfferingDetails: $showAddOfferingDetails, selectedCategoryName: $selectedCategoryName)
                        .tag(0)
                    
                    ServicesTabView(showAddOfferingDetails: $showAddOfferingDetails, selectedCategoryName: $selectedCategoryName)
                        .tag(1)
                    
                    UtilitiesTabView(showAddOfferingDetails: $showAddOfferingDetails, selectedCategoryName: $selectedCategoryName)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddOfferingDetails) {
                AddOfferingDetailsView(categoryName: selectedCategoryName)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goods Tab
struct GoodsTabView: View {
    @Binding var showAddOfferingDetails: Bool
    @Binding var selectedCategoryName: String
    
    struct CategoryItem {
        let name: String
        let color: Color
    }
    
    struct Category {
        let title: String
        let items: [CategoryItem]
    }
    
    let goodsCategories = [
        Category(title: "Periodicals", items: [
            CategoryItem(name: "Newspaper, Magazine", color: .blue),
            CategoryItem(name: "Library", color: .blue)
        ]),
        Category(title: "Food", items: [
            CategoryItem(name: "Dairy, Bakery", color: .blue),
            CategoryItem(name: "Water", color: .blue),
            CategoryItem(name: "Meals, snacks", color: .blue),
            CategoryItem(name: "Hot beverages", color: .blue),
            CategoryItem(name: "Nutrition", color: .blue),
            CategoryItem(name: "Cold delights", color: .blue),
            CategoryItem(name: "Vegetables", color: .blue),
            CategoryItem(name: "Seasonal", color: .blue),
            CategoryItem(name: "Grocery", color: .blue),
            CategoryItem(name: "For event", color: .blue)
        ])
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(goodsCategories.indices, id: \.self) { categoryIndex in
                    let category = goodsCategories[categoryIndex]
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(category.items.indices, id: \.self) { itemIndex in
                                let item = category.items[itemIndex]
                                
                                Button(action: {
                                    selectedCategoryName = item.name
                                    showAddOfferingDetails = true
                                }) {
                                    HStack {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(item.color)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Services Tab
struct ServicesTabView: View {
    @Binding var showAddOfferingDetails: Bool
    @Binding var selectedCategoryName: String
    
    struct CategoryItem {
        let name: String
        let color: Color
    }
    
    struct Category {
        let title: String
        let items: [CategoryItem]
    }
    
    let servicesCategories = [
        Category(title: "House help", items: [
            CategoryItem(name: "Cook", color: .blue),
            CategoryItem(name: "Caregiver", color: .blue),
            CategoryItem(name: "Car bike wash", color: .blue),
            CategoryItem(name: "Gardiner", color: .blue)
        ]),
        Category(title: "Training", items: [
            CategoryItem(name: "Sports", color: .blue),
            CategoryItem(name: "Arts", color: .blue),
            CategoryItem(name: "Academics", color: .blue),
            CategoryItem(name: "Info nuggets", color: .blue)
        ])
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(servicesCategories.indices, id: \.self) { categoryIndex in
                    let category = servicesCategories[categoryIndex]
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(category.items.indices, id: \.self) { itemIndex in
                                let item = category.items[itemIndex]
                                
                                Button(action: {
                                    selectedCategoryName = item.name
                                    showAddOfferingDetails = true
                                }) {
                                    HStack {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(item.color)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Utilities Tab
struct UtilitiesTabView: View {
    @Binding var showAddOfferingDetails: Bool
    @Binding var selectedCategoryName: String
    
    struct CategoryItem {
        let name: String
        let color: Color
    }
    
    struct Category {
        let title: String
        let items: [CategoryItem]
    }
    
    let utilitiesCategories = [
        Category(title: "Amenities", items: [
            CategoryItem(name: "Society amenities", color: .blue),
            CategoryItem(name: "Broadband", color: .blue),
            CategoryItem(name: "TV cable", color: .blue)
        ]),
        Category(title: "Rental", items: [
            CategoryItem(name: "Review, office", color: .blue),
            CategoryItem(name: "Vehicles", color: .blue),
            CategoryItem(name: "Hostel", color: .blue),
            CategoryItem(name: "For event", color: .blue)
        ])
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(utilitiesCategories.indices, id: \.self) { categoryIndex in
                    let category = utilitiesCategories[categoryIndex]
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(category.items.indices, id: \.self) { itemIndex in
                                let item = category.items[itemIndex]
                                
                                Button(action: {
                                    selectedCategoryName = item.name
                                    showAddOfferingDetails = true
                                }) {
                                    HStack {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(item.color)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    AddOfferingView()
}
