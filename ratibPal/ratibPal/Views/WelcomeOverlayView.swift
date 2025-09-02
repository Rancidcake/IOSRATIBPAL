//
//  WelcomeOverlayView.swift
//  ratibPal
//
//  Created by AI Assistant on 31/08/25.
//

import SwiftUI

struct WelcomeOverlayView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea(.all)
            
            // Main content
            VStack(spacing: 30) {
                Spacer()
                
                // Main title
                VStack(spacing: 10) {
                    Text("BE A NEW INDIA CHAMPION")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("by helping your existing consumers to use RatibPal Consumer app. It is important to have a connected customer base to provide them best customer service which in turn comes back to you as loyalty and business growth.")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(nil)
                }
                
//                Spacer()
                
                // Description text
                Text("Simply add your existing customers here. A SMS is sent to them to start using Consumer app. Until they join, you can anyways track the deliveries for yourself.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
                
                Spacer()
                
                // Got It button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Got It")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    WelcomeOverlayView(isPresented: .constant(true))
}
