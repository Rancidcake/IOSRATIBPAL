import SwiftUI

struct OTPVerificationView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    @FocusState private var focusedIndex: Int?
    @State private var otpFields = ["", "", "", ""]
    @State private var resendTimer = 30
    @State private var canResend = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo
            Image("RatibPalLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 100)
                .padding(.top, 30)
            
            // App name
//            Text("ratibpal")
//                .font(.largeTitle)
//                .bold()
//                .foregroundColor(.blue)
            
            // Title
            Text("Verification Code")
                .font(.title3)
                .bold()
            
            Text("Enter 4 digit code sent on mobile number")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Phone number with edit option
            HStack(spacing: 10) {
                Text("+91 \(registrationManager.mobileNumber)")
                    .font(.headline)
                    .bold()
                
                Button(action: {
                    registrationManager.previousStep()
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 10)
            
            // OTP input fields
            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    ForEach(0..<4) { index in
                        TextField("", text: $otpFields[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedIndex, equals: index)
                            .onChange(of: otpFields[index]) { _, newValue in
                                handleOTPInput(index: index, value: newValue)
                            }
                    }
                }
                
                if !registrationManager.otpCode.isEmpty && !registrationManager.isOTPValid {
                    Text("Please enter a valid 4-digit OTP")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 20)
            
            // Submit button
            Button(action: {
                Task {
                    await registrationManager.verifyOTP()
                }
            }) {
                HStack {
                    if registrationManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Verifying...")
                            .foregroundColor(.white)
                    } else {
                        Text("Submit")
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(registrationManager.isOTPValid ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(registrationManager.isLoading || !registrationManager.isOTPValid)
            .padding(.horizontal, 30)
            
            // Resend OTP
            VStack(spacing: 10) {
                if canResend {
                    Button(action: {
                        Task {
                            await resendOTP()
                        }
                    }) {
                        Text("Resend OTP")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .disabled(registrationManager.isLoading)
                } else {
                    Text("Resend OTP in \(resendTimer) seconds")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 20)
            
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
        .onAppear {
            startResendTimer()
            focusedIndex = 0
        }
    }
    
    private func handleOTPInput(index: Int, value: String) {
        // Only allow single digit
        if value.count > 1 {
            otpFields[index] = String(value.last ?? Character(""))
        } else if value.count == 1 && value.first?.isNumber == true {
            otpFields[index] = value
            // Move to next field
            if index < 3 {
                focusedIndex = index + 1
            } else {
                focusedIndex = nil
            }
        } else if value.isEmpty {
            otpFields[index] = ""
            // Move to previous field if deleting
            if index > 0 {
                focusedIndex = index - 1
            }
        }
        
        // Update the combined OTP code
        registrationManager.otpCode = otpFields.joined()
    }
    
    private func resendOTP() async {
        // Reset fields
        otpFields = ["", "", "", ""]
        registrationManager.otpCode = ""
        focusedIndex = 0
        
        // Send new OTP
        await registrationManager.sendOTP()
        
        // Reset timer
        canResend = false
        resendTimer = 30
        startResendTimer()
    }
    
    private func startResendTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                canResend = true
                timer.invalidate()
            }
        }
    }
}

#Preview {
    OTPVerificationView(registrationManager: RegistrationFlowManager())
}
