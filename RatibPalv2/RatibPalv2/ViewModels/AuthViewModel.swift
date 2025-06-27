import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // Registration flow state
    @Published var registrationStep = 1
    @Published var registrationData = RegistrationData()
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        await Task.sleep(2_000_000_000) // 2 seconds
        
        // For demo purposes, accept any login
        if !email.isEmpty && !password.isEmpty {
            let user = User(
                fullName: "Demo User",
                email: email,
                phoneNumber: "+91 9876543210",
                businessName: "Demo Business",
                businessType: "Retail",
                isBusinessUser: true
            )
            currentUser = user
            isAuthenticated = true
        } else {
            errorMessage = "Please enter valid credentials"
            showError = true
        }
        
        isLoading = false
    }
    
    func register() async {
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        await Task.sleep(2_000_000_000) // 2 seconds
        
        let user = User(
            fullName: registrationData.fullName,
            email: registrationData.email,
            phoneNumber: registrationData.phoneNumber,
            businessName: registrationData.businessName,
            businessType: registrationData.businessType,
            isBusinessUser: registrationData.isBusinessUser
        )
        
        currentUser = user
        isAuthenticated = true
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        registrationData = RegistrationData()
        registrationStep = 1
    }
    
    func nextRegistrationStep() {
        if registrationStep < 3 {
            registrationStep += 1
        }
    }
    
    func previousRegistrationStep() {
        if registrationStep > 1 {
            registrationStep -= 1
        }
    }
}

struct RegistrationData {
    var fullName = ""
    var email = ""
    var phoneNumber = ""
    var password = ""
    var confirmPassword = ""
    var isBusinessUser = false
    var businessName = ""
    var businessType = ""
    var businessCategory = ""
    var dateOfBirth = Date()
    var gender = ""
    var address = ""
    var acceptTerms = false
    var acceptPrivacy = false
    var acceptMarketing = false
}