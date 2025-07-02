//
//  MainTabView.swift
//  ratibPal
//
//  Created by Faheemuddin Sayyed on 11/06/25.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showSideMenu = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: TabItem.home.icon)
                        Text(TabItem.home.rawValue)
                    }
                    .tag(TabItem.home)

                PurchaseView()
                    .tabItem {
                        Image(systemName: TabItem.purchase.icon)
                        Text(TabItem.purchase.rawValue)
                    }
                    .tag(TabItem.purchase)

                DeliverView()
                    .tabItem {
                        Image(systemName: TabItem.deliver.icon)
                        Text(TabItem.deliver.rawValue)
                    }
                    .tag(TabItem.deliver)

                BillingView()
                    .tabItem {
                        Image(systemName: TabItem.billing.icon)
                        Text(TabItem.billing.rawValue)
                    }
                    .tag(TabItem.billing)

                MyDetailsView(showSideMenu: $showSideMenu)
                    .tabItem {
                        Image(systemName: TabItem.profile.icon)
                        Text(TabItem.profile.rawValue)
                    }
                    .tag(TabItem.profile)
            }
            .accentColor(.blue)

            if showSideMenu {
                SideMenuView(showSideMenu: $showSideMenu)
            }
        }
    }
}
struct DeliverView: View {
    var body: some View {
        NavigationView {
            InDeliveriesView()
                .navigationTitle("Deliver")
        }
    }
}
