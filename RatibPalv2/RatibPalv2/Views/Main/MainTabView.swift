import SwiftUI

struct MainTabView: View {
    @StateObject private var appViewModel = AppViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            TabView(selection: $appViewModel.selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                
                PurchaseView()
                    .tabItem {
                        Image(systemName: "cart")
                        Text("Purchase")
                    }
                    .tag(1)
                
                DeliveryView()
                    .tabItem {
                        Image(systemName: "truck")
                        Text("Delivery")
                    }
                    .tag(2)
                
                BillingView()
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Billing")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .accentColor(.blue)
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton()
                        .environmentObject(appViewModel)
                        .padding(.trailing, 16)
                        .padding(.bottom, 90) // Above tab bar
                }
            }
        }
        .environmentObject(appViewModel)
    }
}

struct FloatingActionButton: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Sub-menu items (shown when FAB is expanded)
            if appViewModel.showFABMenu {
                VStack(spacing: 12) {
                    FABMenuItem(
                        icon: "person.badge.plus",
                        label: "Add Customer",
                        action: {
                            // Handle add customer
                            appViewModel.toggleFABMenu()
                        }
                    )
                    
                    FABMenuItem(
                        icon: "point.3.connected.trianglepath.dotted",
                        label: "Delivery Lines",
                        action: {
                            // Handle delivery lines
                            appViewModel.toggleFABMenu()
                        }
                    )
                    
                    FABMenuItem(
                        icon: "person.3",
                        label: "Add Group",
                        action: {
                            // Handle add group
                            appViewModel.toggleFABMenu()
                        }
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Main FAB button
            Button(action: {
                appViewModel.toggleFABMenu()
            }) {
                Image(systemName: appViewModel.showFABMenu ? "xmark" : "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .rotationEffect(.degrees(appViewModel.showFABMenu ? 45 : 0))
        }
    }
}

struct FABMenuItem: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Circle())
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}