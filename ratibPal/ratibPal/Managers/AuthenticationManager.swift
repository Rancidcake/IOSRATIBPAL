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
    @Published var shouldShowLogin = false
    
    let registrationManager = RegistrationFlowManager()
    
    private let sessionManager = SessionManager.shared
    private let coreDataManager = CoreDataManager.shared
    private let dataSyncManager = DataSyncManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthenticationStatus()
        setupSessionExpiryMonitoring()
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
    
    private func setupSessionExpiryMonitoring() {
        // Monitor for session expiry notifications
        NotificationCenter.default.publisher(for: .sessionExpired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleSessionExpiry()
            }
            .store(in: &cancellables)
    }
    
    func handleSessionExpiry() {
        // Clear session data
        sessionManager.clearAllUserData()
        
        // Reset authentication state to force login
        withAnimation(.easeInOut(duration: 0.5)) {
            authenticationState = .registration
            shouldShowLogin = true
        }
        
        print("Session expired. Redirecting to login screen.")
    }
    
    // Call this method when API returns 401/session expired
    static func notifySessionExpired() {
        NotificationCenter.default.post(name: .sessionExpired, object: nil)
    }
}

// Notification extension
extension Notification.Name {
    static let sessionExpired = Notification.Name("SessionExpired")
}
