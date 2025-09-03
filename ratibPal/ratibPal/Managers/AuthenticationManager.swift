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
    
    let registrationManager = RegistrationFlowManager()
    
    private let sessionManager = SessionManager.shared
    private let coreDataManager = CoreDataManager.shared
    private let dataSyncManager = DataSyncManager.shared
    
    init() {
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        // Check if user is already logged in using SessionManager
        let isLoggedIn = sessionManager.isUserLoggedIn()
        let firstTimeLogin = sessionManager.getFirstTimeLogin()
        
        if isLoggedIn && !firstTimeLogin {
            // User is authenticated and has completed registration
            authenticationState = .authenticated
            
            // Load user profile from local storage
            registrationManager.loadProfileFromLocal()
            
            // Start background sync if needed
            Task {
                if dataSyncManager.shouldPerformSync() {
                    await dataSyncManager.performIncrementalSync()
                }
            }
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
        // Mark first time login as complete
        sessionManager.setFirstTimeLogin(false)
        
        // Perform initial data sync
        Task {
            await dataSyncManager.performFullSync()
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .authenticated
        }
    }
    
    func resetToLoading() {
        authenticationState = .loading
        checkAuthenticationStatus()
    }
    
    func logout() {
        // Step 1: Clear all stored data from SessionManager
        sessionManager.clearAllUserData()
        
        // Step 2: Clear Core Data synchronously
        coreDataManager.clearAllData()
        
        // Step 3: Shutdown Core Data connections properly
        coreDataManager.shutdownDatabase()
        
        // Step 4: Clear sync data
        dataSyncManager.clearSyncData()
        
        // Step 5: Reset registration manager
        registrationManager.resetRegistration()
        
        // Step 6: Move to registration
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .registration
        }
    }
}
