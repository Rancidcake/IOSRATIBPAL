import SwiftUI
import Combine

enum AuthenticationState {
    case loading
    case registration
    case authenticated
}

class AuthenticationManager: ObservableObject {
    @Published var authenticationState: AuthenticationState = .loading
    @Published var allowSkip: Bool = true // Allow skipping authentication for development
    
    @StateObject var registrationManager = RegistrationFlowManager()
    
    init() {
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        // Check if user is already logged in
        let userId = UserDefaults.standard.currentUserId
        let apiKey = UserDefaults.standard.currentAPIKey
        let firstTimeLogin = UserDefaults.standard.isFirstTimeLogin
        
        if let _ = userId, let _ = apiKey, !firstTimeLogin {
            // User is authenticated and has completed registration
            authenticationState = .authenticated
        } else {
            // User needs to go through registration
            authenticationState = .registration
        }
    }
    
    func moveToRegistration() {
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .registration
        }
    }
    
    func completeAuthentication() {
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .authenticated
        }
    }
    
    func resetToLoading() {
        authenticationState = .loading
        checkAuthenticationStatus()
    }
    
    func logout() {
        // Clear all stored data
        UserDefaults.standard.clearUserData()
        
        // Reset registration manager
        registrationManager.resetRegistration()
        
        // Move to registration
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .registration
        }
    }
}
