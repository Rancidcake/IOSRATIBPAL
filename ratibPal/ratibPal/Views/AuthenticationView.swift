import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            switch authManager.authenticationState {
            case .loading:
                LoadingView {
                    authManager.moveToLogin()
                }
                
            case .login:
                MobileLoginView(
                    onLoginComplete: {
                        authManager.moveToOTPVerification()
                    },
                )
                
            case .otpVerification:
                OTPVerificationView(
                    onOTPComplete: {
                        authManager.completeAuthentication()
                    },
                )
                
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authManager.authenticationState)
    }
}

#Preview {
    AuthenticationView()
}
