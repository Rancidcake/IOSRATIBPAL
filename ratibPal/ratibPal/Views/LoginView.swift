//
//  LoginView.swift
//  ratibPal
//
//  Created by Malhar Borse on 20/07/25.
//

import SwiftUI

struct MobileLoginView: View {
    @State private var mobileNumber: String = ""
    @State private var navigateToOTP = false

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
                
                Button(action: {
                    // Navigate to OTP page
                    navigateToOTP = true
                }) {
                    Text("Agree and Continue")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                // Hidden NavigationLink
                NavigationLink(
                    destination: OTPVerificationView(),
                    isActive: $navigateToOTP
                ) {
                    EmptyView()
                }

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
    MobileLoginView()
}
