//
//  OTPVeri.swift
//  ratibPal
//
//  Created by Malhar Borse on 20/07/25.
//

import SwiftUI

struct LegacyOTPVerificationView: View {
    @State private var otpFields = ["", "", "", ""]
    @FocusState private var focusedIndex: Int?
    @State private var isLoading = false
    
    var onOTPComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App logo
            Image(systemName: "shield.checkerboard") // Replace with your logo if needed
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.bottom, 20)
            
            // App name
            Text("ratibpal")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.blue)
            
            // Subtitle
            Text("Verification Code")
                .font(.title3)
                .bold()
            
            Text("Enter 4 digit code sent on mobile number")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Phone number + edit icon
            HStack(spacing: 5) {
                Text("9356763651")
                    .font(.headline)

                Button(action: {
                    print("Edit Number tapped")
                    // You can add navigation back to MobileLoginView here if needed
                }) {
                    Image(systemName: "square.and.pencil") // More abstract, minimal icon
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 4)

            // OTP fields
            HStack(spacing: 15) {
                ForEach(0..<4) { index in
                    TextField("", text: $otpFields[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($focusedIndex, equals: index)
                        .onChange(of: otpFields[index]) { newValue in
                            if newValue.count == 1 && index < 3 {
                                focusedIndex = index + 1
                            }
                        }
                }
            }
            .padding(.top, 20)
            
            // Submit button
            Button(action: {
                isLoading = true
                print("OTP Submitted: \(otpFields.joined())")
                // Simulate API call
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isLoading = false
                    onOTPComplete()
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                        Text("Verifying...")
                    } else {
                        Text("Submit")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .foregroundColor(.blue)
            }
            .disabled(isLoading)
            .padding(.top, 30)
            .padding(.horizontal, 40)
            
            // Resend OTP
            Text("If you do not receive OTP in 180 seconds, click on")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 15)
            
            Button(action: {
                print("Resend OTP tapped")
            }) {
                Text("Resend OTP")
                    .foregroundColor(.blue)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
    }
}

// Preview
struct LegacyOTPVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyOTPVerificationView {
            print("OTP verification complete")
        }
    }
}
