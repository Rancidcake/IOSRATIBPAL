//
//  RegistrationFlowView.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI

struct RegistrationFlowView: View {
    @ObservedObject var registrationManager: RegistrationFlowManager
    let onRegistrationComplete: () -> Void
    
    var body: some View {
        NavigationView {
            Group {
                switch registrationManager.currentStep {
                case .mobileEntry:
                    MobileEntryView(registrationManager: registrationManager)
                    
                case .otpVerification:
                    OTPVerificationView(registrationManager: registrationManager)
                    
                case .nameEntry:
                    NameEntryView(registrationManager: registrationManager)
                    
                case .photoUpload:
                    PhotoUploadView(registrationManager: registrationManager)
                    
                case .locationSetup:
                    LocationSetupView(registrationManager: registrationManager)
                    
                case .completed:
                    // Registration completed - this will be handled by onChange
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            registrationManager.loadProfileFromLocal()
        }
        .onChange(of: registrationManager.currentStep) { _, step in
            if step == .completed {
                Task {
                    await registrationManager.completeRegistration()
                    onRegistrationComplete()
                }
            }
        }
        .alert("Error", isPresented: .constant(registrationManager.errorMessage != nil)) {
            Button("OK") {
                registrationManager.errorMessage = nil
            }
        } message: {
            Text(registrationManager.errorMessage ?? "")
        }
    }
}

#Preview {
    RegistrationFlowView(
        registrationManager: RegistrationFlowManager(),
        onRegistrationComplete: {}
    )
}
