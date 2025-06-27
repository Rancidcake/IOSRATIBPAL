import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    HeaderSection()
                    
                    // Quick Stats Cards
                    QuickStatsSection()
                    
                    // Quick Actions Grid
                    QuickActionsSection()
                    
                    // Recent Activity Feed
                    RecentActivitySection()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct HeaderSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        HStack {
            // App Logo
            Image(systemName: "truck.box")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Ratib Pal")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Mumbai, Maharashtra")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // User Profile
            Button(action: {
                // Handle profile tap
            }) {
                if let user = authViewModel.currentUser {
                    Text(String(user.fullName.prefix(1)))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            
            // Notification Bell
            Button(action: {
                // Handle notifications
            }) {
                ZStack {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    // Unread count badge
                    Text("3")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct QuickStatsSection: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Overview")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickStatCard(
                        title: "Today's Deliveries",
                        value: "12",
                        subtitle: "3 pending",
                        icon: "truck",
                        color: .blue
                    )
                    
                    QuickStatCard(
                        title: "Pending Orders",
                        value: "\(appViewModel.orders.filter { $0.status == .pending }.count)",
                        subtitle: "Needs attention",
                        icon: "clock",
                        color: .orange
                    )
                    
                    QuickStatCard(
                        title: "Revenue Today",
                        value: "₹5,240",
                        subtitle: "+12% from yesterday",
                        icon: "indianrupeesign",
                        color: .green
                    )
                    
                    QuickStatCard(
                        title: "Active Customers",
                        value: "\(appViewModel.customers.count)",
                        subtitle: "2 new this week",
                        icon: "person.3",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160, height: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                QuickActionCard(
                    title: "Add New Order",
                    subtitle: "Create customer order",
                    icon: "plus.circle",
                    color: .blue
                )
                
                QuickActionCard(
                    title: "Customer Management",
                    subtitle: "View all customers",
                    icon: "person.2",
                    color: .green
                )
                
                QuickActionCard(
                    title: "Delivery Routes",
                    subtitle: "Plan delivery routes",
                    icon: "map",
                    color: .orange
                )
                
                QuickActionCard(
                    title: "View Reports",
                    subtitle: "Analytics dashboard",
                    icon: "chart.bar",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Handle action
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ActivityItem(
                    icon: "plus.circle",
                    title: "New order received",
                    subtitle: "Order #ORD-001 from John Doe",
                    time: "2 min ago",
                    color: .green
                )
                
                ActivityItem(
                    icon: "truck",
                    title: "Delivery completed",
                    subtitle: "Order #ORD-002 delivered to Jane Smith",
                    time: "15 min ago",
                    color: .blue
                )
                
                ActivityItem(
                    icon: "indianrupeesign.circle",
                    title: "Payment received",
                    subtitle: "₹1,500 from ABC Corp",
                    time: "1 hour ago",
                    color: .green
                )
                
                ActivityItem(
                    icon: "person.badge.plus",
                    title: "New customer added",
                    subtitle: "Mike Johnson joined",
                    time: "2 hours ago",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppViewModel())
}