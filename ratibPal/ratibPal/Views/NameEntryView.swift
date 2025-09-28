import SwiftUI

struct NameEntryView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    @FocusState private var isNameFocused: Bool
    @FocusState private var isBusinessNameFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        registrationManager.previousStep()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Profile Setup")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    // Invisible button for alignment
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                    .disabled(true)
                }
                
                // Progress indicator
                ProgressView(value: 0.6)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 4)
            }
            .padding()
            
            Spacer()
            
            // Logo
            Image("RatibPalLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
            
            // Title
            Text("Let's get to know you better")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Please provide your details to continue")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            // Form fields
            VStack(spacing: 25) {
                // Full name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name *")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your full name", text: $registrationManager.fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isNameFocused)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    if !registrationManager.fullName.isEmpty && !registrationManager.isNameValid {
                        Text("Please enter a valid name")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Business name field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Business Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("(Optional)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Enter your business name", text: $registrationManager.businessName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isBusinessNameFocused)
                        .textContentType(.organizationName)
                        .autocapitalization(.words)
                        .onChange(of: registrationManager.businessName) { _, value in
                            registrationManager.isSupplier = !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        }
                    
                    if !registrationManager.businessName.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("Adding a business name will make you a supplier on RatibPal")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 5)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Continue button
            Button(action: {
                Task {
                    await registrationManager.updateProfile()
                }
            }) {
                HStack {
                    if registrationManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Saving...")
                            .foregroundColor(.white)
                    } else {
                        Text("Continue")
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(registrationManager.isNameValid ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(registrationManager.isLoading || !registrationManager.isNameValid)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .onAppear {
            isNameFocused = true
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationView {
        NameEntryView(registrationManager: RegistrationFlowManager())
    }
}
