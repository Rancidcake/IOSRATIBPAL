import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            switch authManager.authenticationState {
            case .loading:
                LoadingView {
                    authManager.moveToRegistration()
                }
                
            case .registration:
                RegistrationFlowView(registrationManager: authManager.registrationManager) {
                    authManager.completeAuthentication()
                }
                
            case .authenticated:
                MainTabView()
                    .environmentObject(authManager)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authManager.authenticationState)
    }
}

#Preview {
    AuthenticationView()
}
