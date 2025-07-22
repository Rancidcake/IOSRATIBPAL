import SwiftUI
import Combine

enum AuthenticationState {
    case loading
    case login
    case otpVerification
    case authenticated
}

class AuthenticationManager: ObservableObject {
    @Published var authenticationState: AuthenticationState = .loading
    @Published var allowSkip: Bool = true // Allow skipping authentication for development
    
    func moveToLogin() {
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .login
        }
    }
    
    func moveToOTPVerification() {
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .otpVerification
        }
    }
    
    func completeAuthentication() {
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .authenticated
        }
    }
    
    func resetToLoading() {
        authenticationState = .loading
    }
}
