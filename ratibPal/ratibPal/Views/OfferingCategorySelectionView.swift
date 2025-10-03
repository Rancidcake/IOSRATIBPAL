//
//  OfferingCategorySelectionView.swift
//  ratibPal
//
//  Created by GitHub Copilot on October 3, 2025.
//

import SwiftUI

struct OfferingCategorySelectionView: View {
    let offeringViewModel: OfferingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    // Category data based on Android layout
    private let tabs = ["Goods", "Services", "Utilities"]
    
    private let goodsCategories = [
        CategorySection(title: "Periodicals", items: [
            CategoryItem(name: "Paper, Magazine", description: "National / regional / local daily, weekly, monthly..."),
            CategoryItem(name: "Library", description: "")
        ]),
        CategorySection(title: "Food", items: [
            CategoryItem(name: "Dairy, Bakery", description: "Milk, byproducts, sweets; Bread, khari, toast, cookies, cakes, chocolates..."),
            CategoryItem(name: "Meals, snacks", description: "Take-away(Tiffin, parcel), Dine-in(mess, restaurant, thela, dhaba)..."),
            CategoryItem(name: "Nutrition", description: "Fruits, fresh fruit juices, herbal juices..."),
            CategoryItem(name: "Vegetables", description: ""),
            CategoryItem(name: "Grocery", description: ""),
            CategoryItem(name: "Water", description: "Water bottle, chilled water jar, tanker..."),
            CategoryItem(name: "Hot beverages", description: ""),
            CategoryItem(name: "Cold delights", description: ""),
            CategoryItem(name: "Seasonal", description: ""),
            CategoryItem(name: "For event", description: "")
        ]),
        CategorySection(title: "Rituals", items: [
            CategoryItem(name: "Puja", description: "Daily, Ganpati, Navratri, Satynarayan – material, deity"),
            CategoryItem(name: "Festival", description: "Diwali, Christmas, Eid – decoration, delicacies, crackers"),
            CategoryItem(name: "Wedding", description: "Community style at home, hall, lawn, destination - items or packages")
        ])
    ]
    
    private let servicesCategories = [
        CategorySection(title: "House help", items: [
            CategoryItem(name: "Cook", description: "Bai, chef"),
            CategoryItem(name: "Maid", description: "Cleaning / washing - Maid / Butler"),
            CategoryItem(name: "Car, bike wash", description: "Car, bike washer"),
            CategoryItem(name: "Caregiver", description: "Baby sitter, baby bath/massage(Dai), nurse for elderly"),
            CategoryItem(name: "Driver", description: "Permanent, on contract, for a trip"),
            CategoryItem(name: "Gardener", description: "Permanent, weekends, on-demand")
        ]),
        CategorySection(title: "Training", items: [
            CategoryItem(name: "Sports", description: "Gym, cricket, skating..."),
            CategoryItem(name: "Academics", description: "School, tuition, pro courses, language..."),
            CategoryItem(name: "Arts", description: "Singing, instrument playing, dance, painting, cooking..."),
            CategoryItem(name: "Info nuggets", description: "Market analysis, inspirational quotes, zodiac predictions...")
        ])
    ]
    
    private let utilitiesCategories = [
        CategorySection(title: "Amenities", items: [
            CategoryItem(name: "Society", description: "Maintenance contribution, community hall booking"),
            CategoryItem(name: "TV cable", description: "TV cable subscription"),
            CategoryItem(name: "Broadband", description: "Broadband subscription")
        ]),
        CategorySection(title: "Rentals", items: [
            CategoryItem(name: "House, office", description: "House, office on rent"),
            CategoryItem(name: "Hostel", description: "Hostel room / cot basis"),
            CategoryItem(name: "Vehicle", description: "Vehicle on rent"),
            CategoryItem(name: "For event", description: "For event venue")
        ])
    ]
    
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
                    ForEach(tabs.indices, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabs[index])
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedTab == index ? .black : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == index ? Color.white : Color.gray.opacity(0.3))
                        }
                    }
                }
                .background(Color.gray.opacity(0.3))
                
                // Content
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        let categories = getCurrentCategories()
                        ForEach(categories.indices, id: \.self) { sectionIndex in
                            let section = categories[sectionIndex]
                            
                            // Section Header
                            VStack(alignment: .leading, spacing: 0) {
                                Text(section.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    .padding(.bottom, 8)
                                
                                // Section Items
                                ForEach(section.items.indices, id: \.self) { itemIndex in
                                    let item = section.items[itemIndex]
                                    
                                    NavigationLink(destination: AddEditOfferingView(categoryName: item.name, offeringViewModel: offeringViewModel)) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(item.name)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.blue)
                                                
                                                Spacer()
                                            }
                                            
                                            if !item.description.isEmpty {
                                                Text(item.description)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Divider
                                    if itemIndex < section.items.count - 1 {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 1)
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getCurrentCategories() -> [CategorySection] {
        switch selectedTab {
        case 0: return goodsCategories
        case 1: return servicesCategories
        case 2: return utilitiesCategories
        default: return goodsCategories
        }
    }
}

struct CategorySection {
    let title: String
    let items: [CategoryItem]
}

struct CategoryItem {
    let name: String
    let description: String
}

#Preview {
    OfferingCategorySelectionView(offeringViewModel: OfferingViewModel())
}