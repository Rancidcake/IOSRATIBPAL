import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header Section
                VStack(spacing: 16) {
                    Image(systemName: "truck.box")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Ratib Pal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Manage your business efficiently")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email or Username")
                            .font(.headline)
                        
                        TextField("Enter email or username", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        
                        HStack {
                            if showPassword {
                                TextField("Enter password", text: $password)
                            } else {
                                SecureField("Enter password", text: $password)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                
                // Login Button
                Button(action: {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                .padding(.horizontal)
                
                // Register Link
                Button("New user? Create account") {
                    showRegistration = true
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .alert("Login Error", isPresented: $authViewModel.showError) {
                Button("OK") { }
            } message: {
                Text(authViewModel.errorMessage)
            }
            .sheet(isPresented: $showRegistration) {
                RegistrationView()
                    .environmentObject(authViewModel)
            }
        }
        .environmentObject(authViewModel)
    }
}

#Preview {
    LoginView()
}