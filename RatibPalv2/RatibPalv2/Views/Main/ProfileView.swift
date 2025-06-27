import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingSettings = false
    @State private var showingLocationManager = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderSection()
                    
                    Divider()
                    
                    // Personal Details Section
                    PersonalDetailsSection()
                    
                    Divider()
                    
                    // Business Details Section (if business user)
                    if authViewModel.currentUser?.isBusinessUser == true {
                        BusinessDetailsSection()
                        Divider()
                    }
                    
                    // Management Sections
                    ManagementSection()
                    
                    Divider()
                    
                    // Settings and Logout
                    SettingsSection()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Picture
            Button(action: {
                // Handle profile picture change
            }) {
                if let user = authViewModel.currentUser {
                    Text(String(user.fullName.prefix(2)))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                }
            }
            
            // User Info
            if let user = authViewModel.currentUser {
                VStack(spacing: 4) {
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let businessName = user.businessName {
                        Text(businessName)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            Button("Edit Profile") {
                // Handle edit profile
            }
            .font(.subheadline)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
    }
}

struct PersonalDetailsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let user = authViewModel.currentUser {
                ProfileInfoCard {
                    VStack(alignment: .leading, spacing: 12) {
                        ProfileInfoRow(label: "Full Name", value: user.fullName, icon: "person")
                        ProfileInfoRow(label: "Email", value: user.email, icon: "envelope")
                        ProfileInfoRow(label: "Phone", value: user.phoneNumber, icon: "phone")
                        ProfileInfoRow(label: "Member Since", value: user.createdAt.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                    }
                }
            }
        }
    }
}

struct BusinessDetailsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Business Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let user = authViewModel.currentUser {
                ProfileInfoCard {
                    VStack(alignment: .leading, spacing: 12) {
                        if let businessName = user.businessName {
                            ProfileInfoRow(label: "Business Name", value: businessName, icon: "building.2")
                        }
                        
                        if let businessType = user.businessType {
                            ProfileInfoRow(label: "Business Type", value: businessType, icon: "briefcase")
                        }
                        
                        ProfileInfoRow(label: "Account Type", value: "Business Account", icon: "checkmark.seal")
                    }
                }
            }
        }
    }
}

struct ManagementSection: View {
    @State private var showingLocationManager = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Management")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ManagementButton(
                    title: "Manage Locations",
                    subtitle: "Personal and business locations",
                    icon: "location",
                    action: { showingLocationManager = true }
                )
                
                ManagementButton(
                    title: "Customer Management",
                    subtitle: "View and manage customers",
                    icon: "person.2",
                    action: { }
                )
                
                ManagementButton(
                    title: "Inventory Management",
                    subtitle: "Stock levels and products",
                    icon: "cube.box",
                    action: { }
                )
                
                ManagementButton(
                    title: "Reports & Analytics",
                    subtitle: "Business performance insights",
                    icon: "chart.bar",
                    action: { }
                )
            }
        }
        .sheet(isPresented: $showingLocationManager) {
            LocationManagerView()
        }
    }
}

struct SettingsSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings & Support")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                SettingsButton(
                    title: "App Settings",
                    subtitle: "Preferences and notifications",
                    icon: "gear",
                    action: { showingSettings = true }
                )
                
                SettingsButton(
                    title: "Help & Support",
                    subtitle: "Get help and contact support",
                    icon: "questionmark.circle",
                    action: { }
                )
                
                SettingsButton(
                    title: "Privacy & Security",
                    subtitle: "Account security settings",
                    icon: "lock.shield",
                    action: { }
                )
                
                Button(action: { showingLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "power")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sign Out")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Text("Sign out of your account")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.red.opacity(0.05))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct ProfileInfoCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct ManagementButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var locations: [Location] = []
    @State private var showingAddLocation = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Personal Locations") {
                    ForEach(locations.filter { !$0.name.contains("Business") }) { location in
                        LocationRow(location: location)
                    }
                }
                
                Section("Business Locations") {
                    ForEach(locations.filter { $0.name.contains("Business") }) { location in
                        LocationRow(location: location)
                    }
                }
            }
            .navigationTitle("Manage Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddLocation = true
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView { location in
                    locations.append(location)
                }
            }
        }
        .onAppear {
            loadSampleLocations()
        }
    }
    
    private func loadSampleLocations() {
        locations = [
            Location(name: "Home", address: "123 Main St", city: "Mumbai", state: "Maharashtra", pinCode: "400001", landmark: "Near Central Park", isDefault: true),
            Location(name: "Business Office", address: "456 Business Ave", city: "Mumbai", state: "Maharashtra", pinCode: "400002", landmark: "Commercial Complex")
        ]
    }
}

struct LocationRow: View {
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(location.name)
                    .font(.headline)
                
                if location.isDefault {
                    Text("Default")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
            
            Text(location.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(location.city), \(location.state) - \(location.pinCode)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let landmark = location.landmark {
                Text("Near: \(landmark)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Location) -> Void
    
    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var pinCode = ""
    @State private var landmark = ""
    @State private var isDefault = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Location Details") {
                    TextField("Location Name", text: $name)
                    TextField("Address", text: $address)
                    TextField("Landmark (Optional)", text: $landmark)
                }
                
                Section("Area Information") {
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("PIN Code", text: $pinCode)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Toggle("Set as Default Location", isOn: $isDefault)
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let location = Location(
                            name: name,
                            address: address,
                            city: city,
                            state: state,
                            pinCode: pinCode,
                            landmark: landmark.isEmpty ? nil : landmark,
                            isDefault: isDefault
                        )
                        onSave(location)
                        dismiss()
                    }
                    .disabled(name.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty || pinCode.isEmpty)
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Email Notifications", isOn: $notificationsEnabled)
                    Toggle("SMS Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Privacy") {
                    Toggle("Location Services", isOn: $locationEnabled)
                    Toggle("Analytics", isOn: $notificationsEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag("English")
                        Text("Hindi").tag("Hindi")
                        Text("Marathi").tag("Marathi")
                    }
                }
                
                Section("Data") {
                    Button("Export Data") { }
                    Button("Clear Cache") { }
                    Button("Reset App") { }
                        .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Terms of Service") { }
                    Button("Privacy Policy") { }
                    Button("Contact Support") { }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppViewModel())
}