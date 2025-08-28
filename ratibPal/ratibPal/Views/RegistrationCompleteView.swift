//
//  RegistrationCompleteView.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI

struct RegistrationCompleteView: View {
    let onComplete: () -> Void
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success animation/icon
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .scaleEffect(showConfetti ? 1.2 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showConfetti)
                }
                
                Text("🎉")
                    .font(.system(size: 40))
                    .scaleEffect(showConfetti ? 1.5 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showConfetti)
            }
            
            // Success message
            VStack(spacing: 15) {
                Text("Welcome to RatibPal!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Congratulations! Your account has been successfully created and verified.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Text("You can now start using RatibPal to manage your business operations efficiently.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 30)
            
            // Features preview
            VStack(spacing: 15) {
                Text("What you can do now:")
                    .font(.headline)
                    .bold()
                
                VStack(spacing: 12) {
                    FeatureRow(icon: "house.fill", title: "Manage your business from home")
                    FeatureRow(icon: "cart.fill", title: "Track purchases and inventory")
                    FeatureRow(icon: "box.truck.fill", title: "Handle deliveries efficiently")
                    FeatureRow(icon: "doc.text.fill", title: "Generate bills and invoices")
                    FeatureRow(icon: "person.3.fill", title: "Connect with suppliers and customers")
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Get started button
            Button(action: {
                onComplete()
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Get Started")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                colors: [Color.white, Color.blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            // Trigger success animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showConfetti = true
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    RegistrationCompleteView {
        print("Registration completed!")
    }
}
