//
//  LoginView.swift
//  ratibPal
//
//  Created by Malhar Borse on 20/07/25.
//

import SwiftUI

struct MobileLoginView: View {
    @State private var mobileNumber: String = ""
    @State private var isLoading = false
    
    var onLoginComplete: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Image("RatibPalLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)

                Text("Signup / login with number")
                    .font(.title3)
                    .bold()
                    .padding(.top, 10)

                Text("We will send you OTP by SMS")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                HStack {
                    Text("+91")
                        .bold()
                    TextField("Mobile Number", text: $mobileNumber)
                        .keyboardType(.numberPad)
                        .padding(10)
                }
                .padding()
                .overlay(Rectangle().frame(height: 1).padding(.top, 45), alignment: .bottom)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                
                // Continue button
                    Button(action: {
                        isLoading = true
                        // Simulate API call
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLoading = false
                            onLoginComplete()
                        }
                    }) {
                        HStack {
                            if isLoading {
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
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    

                Text("Terms and conditions")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                
                Spacer()
                
                VStack {
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
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true) // Optional: Hide navigation bar
        }
    }
}
#Preview {
    MobileLoginView {
        print("Login complete")
    }
}
