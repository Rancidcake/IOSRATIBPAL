import SwiftUI

struct HomeView: View {
    @State private var showFAB = false
    @State private var showAffiliatePopup = false
    @State private var showAddGroupSheet = false
    @State private var showAddCustomerSheet = false
    @State private var showDeliveryLines = false
    @State private var showSideMenu = false
    @State private var selectedFilter: FilterOption = .all
    @State private var isDefaultLineExpanded = false
    
    // SideMenu sheet states
    @State private var showSettings = false
    @State private var showPointOfSale = false
    @State private var showFieldTeamTracker = false
    
    @State private var groups: [String] = ["Default"]
    @State private var affiliates: [String] = ["Affiliate A", "Affiliate B"]
    
    private let welcomeSteps = [
        WelcomeStep(id: 1, title: "Registration", subtitle: "", isCompleted: true, isActive: false),
        WelcomeStep(id: 2, title: "List offerings", subtitle: "Tap on 'Profile' above & then 'Offerings list'", isCompleted: false, isActive: true),
        WelcomeStep(id: 3, title: "Create lines", subtitle: "Tap on '+' below & then 'Delivery Lines'", isCompleted: false, isActive: false),
        WelcomeStep(id: 4, title: "List customers", subtitle: "Tap on '+' below & then 'Add Customer'", isCompleted: false, isActive: false)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Custom Navigation Header
                HStack {
                    Button(action: {
                        showSideMenu = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Text("Line, Customers")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Main Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Filter Dropdown
                        HStack {
                            HStack {
                                Image(systemName: "arrow.down")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Menu {
                                    ForEach(FilterOption.allCases, id: \.self) { option in
                                        Button(option.title) {
                                            selectedFilter = option
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedFilter.title)
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Image(systemName: "arrow.down.doc")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: {
                                    showAffiliatePopup = true
                                }) {
                                    Image(systemName: "person.badge.plus")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Default Line Section
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation {
                                    isDefaultLineExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: isDefaultLineExpanded ? "chevron.down" : "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text("Default line")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                            }
                            
                            if isDefaultLineExpanded {
                                VStack {
                                    // Expanded content can be added here
                                    Text("Line content goes here")
                                        .padding()
                                        .foregroundColor(.secondary)
                                }
                                .background(Color.white)
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                        // Welcome Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Welcome")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            VStack(spacing: 16) {
                                ForEach(welcomeSteps, id: \.id) { step in
                                    HStack(alignment: .top, spacing: 12) {
                                        if step.isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                                .frame(width: 16, height: 16)
                                        } else if step.isActive {
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                                .frame(width: 16, height: 16)
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(width: 16, height: 16)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(step.id). \(step.title)")
                                                .font(.body)
                                                .fontWeight(step.isActive ? .medium : .regular)
                                                .foregroundColor(step.isCompleted ? .green : (step.isActive ? .blue : .primary))
                                            
                                            if !step.subtitle.isEmpty {
                                                Text(step.subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showFAB.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            
            // Side Menu Overlay
            if showSideMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showSideMenu = false
                    }
                
                HStack {
                    SideMenuView(
                        showSideMenu: $showSideMenu,
                        showSettings: $showSettings,
                        showPointOfSale: $showPointOfSale,
                        showFieldTeamTracker: $showFieldTeamTracker
                    )
                        .frame(width: 280)
                        .transition(.move(edge: .leading))
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        // Sheets & Popups
        .sheet(isPresented: $showAffiliatePopup) {
            AffiliatePopupView(affiliates: affiliates) { _ in }
        }
        .sheet(isPresented: $showAddGroupSheet) {
            AddGroupView { newGroup in groups.append(newGroup) }
        }
        .sheet(isPresented: $showAddCustomerSheet) {
            AddCustomerView(groups: groups, affiliates: affiliates) { _ in }
        }
        .sheet(isPresented: $showDeliveryLines) {
            DeliveryLinesView()
        }
        .sheet(isPresented: $showFAB) {
            FABActionsView(
                showAffiliatePopup: $showAffiliatePopup,
                showAddGroupSheet: $showAddGroupSheet,
                showAddCustomerSheet: $showAddCustomerSheet,
                showDeliveryLines: $showDeliveryLines,
                showFAB: $showFAB
            )
        }
        // SideMenu sheets
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showPointOfSale) {
            PointOfSaleView()
        }
        .sheet(isPresented: $showFieldTeamTracker) {
            FieldTeamTrackerView()
        }
    }
}

// MARK: - FAB Actions View
struct FABActionsView: View {
    @Binding var showAffiliatePopup: Bool
    @Binding var showAddGroupSheet: Bool
    @Binding var showAddCustomerSheet: Bool
    @Binding var showDeliveryLines: Bool
    @Binding var showFAB: Bool
    
    private let actions = [
        ("Group", "rectangle.stack.badge.plus"),
        ("Customer", "person.badge.plus"),
        ("Delivery Lines", "list.bullet")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    Button(action: {
                        switch index {
                        case 0:
                            showAddGroupSheet = true
                        case 1:
                            showAddCustomerSheet = true
                        case 2:
                            showDeliveryLines = true
                        default:
                            break
                        }
                        showFAB = false
                    }) {
                        HStack {
                            Image(systemName: action.1)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text(action.0)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                showFAB = false
            })
        }
    }
}
#Preview {
    HomeView()
}
