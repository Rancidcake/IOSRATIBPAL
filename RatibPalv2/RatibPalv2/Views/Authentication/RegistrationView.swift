import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Indicator
                ProgressView(value: Double(authViewModel.registrationStep), total: 3.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                
                // Registration Steps
                switch authViewModel.registrationStep {
                case 1:
                    RegistrationStep1View()
                case 2:
                    RegistrationStep2View()
                case 3:
                    RegistrationStep3View()
                default:
                    RegistrationStep1View()
                }
                
                Spacer()
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if authViewModel.registrationStep > 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Back") {
                            authViewModel.previousRegistrationStep()
                        }
                    }
                }
            }
        }
    }
}

struct RegistrationStep1View: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showPasswordRequirements = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Step 1 of 3")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Basic Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        title: "Full Name",
                        placeholder: "Enter your full name",
                        text: $authViewModel.registrationData.fullName
                    )
                    
                    CustomTextField(
                        title: "Phone Number",
                        placeholder: "Enter mobile number",
                        text: $authViewModel.registrationData.phoneNumber
                    )
                    .keyboardType(.phonePad)
                    
                    CustomTextField(
                        title: "Email Address",
                        placeholder: "Enter email address",
                        text: $authViewModel.registrationData.email
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        
                        SecureField("Create password", text: $authViewModel.registrationData.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onTapGesture {
                                showPasswordRequirements = true
                            }
                        
                        if showPasswordRequirements {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password Requirements:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("• At least 8 characters")
                                    .font(.caption)
                                Text("• Include uppercase and lowercase letters")
                                    .font(.caption)
                                Text("• Include at least one number")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    CustomTextField(
                        title: "Confirm Password",
                        placeholder: "Confirm password",
                        text: $authViewModel.registrationData.confirmPassword,
                        isSecure: true
                    )
                }
                .padding(.horizontal)
                
                Button(action: {
                    authViewModel.nextRegistrationStep()
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .padding(.horizontal)
                
                Button("Already have account? Sign in") {
                    // Handle sign in
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
    }
    
    private var isFormValid: Bool {
        !authViewModel.registrationData.fullName.isEmpty &&
        !authViewModel.registrationData.phoneNumber.isEmpty &&
        !authViewModel.registrationData.email.isEmpty &&
        authViewModel.registrationData.password.count >= 8 &&
        authViewModel.registrationData.password == authViewModel.registrationData.confirmPassword
    }
}

struct RegistrationStep2View: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Step 2 of 3")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Business or Personal?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    // Business Type Selection
                    VStack(spacing: 12) {
                        Button(action: {
                            authViewModel.registrationData.isBusinessUser = true
                        }) {
                            HStack {
                                Image(systemName: "building.2")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Business Account")
                                        .fontWeight(.semibold)
                                    Text("For businesses and organizations")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if authViewModel.registrationData.isBusinessUser {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(authViewModel.registrationData.isBusinessUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            authViewModel.registrationData.isBusinessUser = false
                        }) {
                            HStack {
                                Image(systemName: "person")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Personal Account")
                                        .fontWeight(.semibold)
                                    Text("For individual use")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if !authViewModel.registrationData.isBusinessUser {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(!authViewModel.registrationData.isBusinessUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if authViewModel.registrationData.isBusinessUser {
                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "Business Name",
                                placeholder: "Enter business name",
                                text: $authViewModel.registrationData.businessName
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Business Type")
                                    .font(.headline)
                                
                                Picker("Business Type", selection: $authViewModel.registrationData.businessType) {
                                    Text("Select Type").tag("")
                                    Text("Retail").tag("Retail")
                                    Text("Restaurant").tag("Restaurant")
                                    Text("Services").tag("Services")
                                    Text("Manufacturing").tag("Manufacturing")
                                    Text("Other").tag("Other")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(height: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    authViewModel.nextRegistrationStep()
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct RegistrationStep3View: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Step 3 of 3")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Review & Complete")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Summary Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Review Your Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(title: "Name", value: authViewModel.registrationData.fullName)
                        InfoRow(title: "Email", value: authViewModel.registrationData.email)
                        InfoRow(title: "Phone", value: authViewModel.registrationData.phoneNumber)
                        
                        if authViewModel.registrationData.isBusinessUser {
                            InfoRow(title: "Business", value: authViewModel.registrationData.businessName)
                            InfoRow(title: "Type", value: authViewModel.registrationData.businessType)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Terms and Conditions
                VStack(spacing: 12) {
                    Toggle(isOn: $authViewModel.registrationData.acceptTerms) {
                        Text("I accept the Terms and Conditions")
                            .font(.caption)
                    }
                    
                    Toggle(isOn: $authViewModel.registrationData.acceptPrivacy) {
                        Text("I accept the Privacy Policy")
                            .font(.caption)
                    }
                    
                    Toggle(isOn: $authViewModel.registrationData.acceptMarketing) {
                        Text("I want to receive marketing communications")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await authViewModel.register()
                        dismiss()
                    }
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canCreateAccount ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!canCreateAccount)
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private var canCreateAccount: Bool {
        authViewModel.registrationData.acceptTerms &&
        authViewModel.registrationData.acceptPrivacy &&
        !authViewModel.isLoading
    }
}

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}