import SwiftUI

struct MobileEntryView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    @State private var showTerms = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo
            Image("RatibPalLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)
            
            // Title
            Text("Signup / login with number")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("We will send you OTP by SMS")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 30)
            
            // Mobile number input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("+91")
                        .font(.headline)
                        .bold()
                    
                    TextField("Mobile Number", text: $registrationManager.mobileNumber)
                        .keyboardType(.numberPad)
                        .font(.headline)
                        .onChange(of: registrationManager.mobileNumber) { _, newValue in
                            // Limit to 10 digits
                            if newValue.count > 10 {
                                registrationManager.mobileNumber = String(newValue.prefix(10))
                            }
                            // Only allow numbers
                            registrationManager.mobileNumber = newValue.filter { $0.isNumber }
                        }
                }
                .padding()
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 45),
                    alignment: .bottom
                )
                
                if !registrationManager.mobileNumber.isEmpty && !registrationManager.isMobileValid {
                    Text("Please enter a valid 10-digit mobile number")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
            
            // Continue button
            Button(action: {
                Task {
                    await registrationManager.sendOTP()
                }
            }) {
                HStack {
                    if registrationManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                        Text("Processing...")
                    } else {
                        Text("Agree and Continue")
                    }
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
            .disabled(registrationManager.isLoading || !registrationManager.isMobileValid)
            .opacity(registrationManager.isMobileValid ? 1.0 : 0.6)
            .padding(.horizontal, 30)
            
            // Terms and conditions
            Button(action: {
                showTerms = true
            }) {
                Text("Terms and conditions")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.top, 10)
            
            Spacer()
            
            // Support information
            VStack(spacing: 5) {
                Text("For any assistance/query")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Button(action: {
                    if let url = URL(string: "tel://9850865586") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("(9850865586)")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showTerms) {
            TermsAndConditionsView()
        }
    }
}

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms and Conditions")
                        .font(.title2)
                        .bold()
                        .padding(.bottom)
                    
                    Text("Welcome to RatibPal. By using our service, you agree to the following terms and conditions:")
                    
                    Group {
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                        Text("By accessing and using RatibPal, you accept and agree to be bound by the terms and provision of this agreement.")
                        
                        Text("2. Use License")
                            .font(.headline)
                        Text("Permission is granted to temporarily use RatibPal for personal, non-commercial transitory viewing only.")
                        
                        Text("3. Privacy Policy")
                            .font(.headline)
                        Text("Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service.")
                        
                        Text("4. User Accounts")
                            .font(.headline)
                        Text("You are responsible for safeguarding the password and for your activities that occur under your account.")
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Terms & Conditions")
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
    MobileEntryView(registrationManager: RegistrationFlowManager())
}
