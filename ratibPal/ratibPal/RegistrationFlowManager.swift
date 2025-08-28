//
//  RegistrationFlowManager.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation
import SwiftUI
import Combine

class RegistrationFlowManager: ObservableObject {
    @Published var currentStep: RegistrationStep = .mobileEntry
    @Published var userProfile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var mobileNumber: String = ""
    @Published var otpCode: String = ""
    @Published var fullName: String = ""
    @Published var businessName: String = ""
    @Published var isSupplier: Bool = false
    @Published var photoIDImage: UIImage?
    @Published var shouldSkipPhotoID: Bool = false
    
    private let apiManager = RegistrationAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Step Navigation
    
    func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .mobileEntry:
                currentStep = .otpVerification
            case .otpVerification:
                determineNextStepAfterOTP()
            case .nameEntry:
                if isSupplier {
                    currentStep = .photoUpload
                } else {
                    currentStep = .locationSetup
                }
            case .photoUpload:
                currentStep = .locationSetup
            case .locationSetup:
                currentStep = .completed
            case .completed:
                break
            }
        }
    }
    
    func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .mobileEntry:
                break
            case .otpVerification:
                currentStep = .mobileEntry
            case .nameEntry:
                currentStep = .otpVerification
            case .photoUpload:
                currentStep = .nameEntry
            case .locationSetup:
                if isSupplier {
                    currentStep = .photoUpload
                } else {
                    currentStep = .nameEntry
                }
            case .completed:
                currentStep = .locationSetup
            }
        }
    }
    
    private func determineNextStepAfterOTP() {
        guard let profile = userProfile else {
            currentStep = .nameEntry
            return
        }
        
        // Check if name is empty
        if profile.nam?.isEmpty ?? true {
            currentStep = .nameEntry
            return
        }
        
        // Check if user is supplier and photo ID is missing
        if let supplier = profile.sup, profile.pid?.isEmpty ?? true {
            isSupplier = true
            currentStep = .photoUpload
            return
        }
        
        // Check if locations are missing
        if profile.lcs?.isEmpty ?? true {
            currentStep = .locationSetup
            return
        }
        
        // Registration complete
        currentStep = .completed
    }
    
    // MARK: - API Methods
    
    @MainActor
    func sendOTP() async {
        guard !mobileNumber.isEmpty, mobileNumber.count == 10 else {
            errorMessage = "Please enter a valid 10-digit mobile number"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiManager.sendOTP(mobileNumber: mobileNumber)
            print("OTP sent: \(response.message)")
            nextStep()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func verifyOTP() async {
        guard !otpCode.isEmpty, otpCode.count == 4 else {
            errorMessage = "Please enter a valid 4-digit OTP"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let profile = try await apiManager.verifyOTP(mobileNumber: mobileNumber, otp: otpCode)
            userProfile = profile
            
            // Pre-populate fields if available
            if let name = profile.nam, !name.isEmpty {
                fullName = name
            }
            
            if let supplier = profile.sup, let businessName = supplier.bnm, !businessName.isEmpty {
                self.businessName = businessName
                isSupplier = true
            }
            
            // Save profile locally
            saveProfileLocally(profile)
            
            nextStep()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateProfile() async {
        guard !fullName.isEmpty else {
            errorMessage = "Please enter your full name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var updatedProfile = userProfile ?? createEmptyProfile()
            updatedProfile = Profile(
                uid: updatedProfile.uid,
                mno: updatedProfile.mno,
                nam: fullName,
                eml: updatedProfile.eml,
                img: updatedProfile.img,
                irl: updatedProfile.irl,
                pid: updatedProfile.pid,
                stk: updatedProfile.stk,
                plc: updatedProfile.plc,
                pns: updatedProfile.pns,
                blk: updatedProfile.blk,
                off: updatedProfile.off,
                sup: isSupplier ? createSupplierProfile() : nil,
                lcs: updatedProfile.lcs,
                ca: updatedProfile.ca,
                cb: updatedProfile.cb,
                ua: Int64(Date().timeIntervalSince1970),
                ub: updatedProfile.uid,
                d: updatedProfile.d
            )
            
            let response = try await apiManager.updateProfile(updatedProfile)
            userProfile = updatedProfile
            saveProfileLocally(updatedProfile)
            
            print("Profile updated: \(response.message)")
            nextStep()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func uploadPhotoID() async {
        guard let image = photoIDImage else {
            errorMessage = "Please select an image first"
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiManager.uploadPhotoID(imageData: imageData)
            
            // Update profile with photo ID
            if var profile = userProfile {
                profile = Profile(
                    uid: profile.uid,
                    mno: profile.mno,
                    nam: profile.nam,
                    eml: profile.eml,
                    img: profile.img,
                    irl: profile.irl,
                    pid: response.imageId,
                    stk: profile.stk,
                    plc: profile.plc,
                    pns: profile.pns,
                    blk: profile.blk,
                    off: profile.off,
                    sup: profile.sup,
                    lcs: profile.lcs,
                    ca: profile.ca,
                    cb: profile.cb,
                    ua: Int64(Date().timeIntervalSince1970),
                    ub: profile.uid,
                    d: profile.d
                )
                
                // Update profile on server
                let _ = try await apiManager.updateProfile(profile)
                userProfile = profile
                saveProfileLocally(profile)
            }
            
            nextStep()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func skipPhotoID() async {
        shouldSkipPhotoID = true
        nextStep()
    }
    
    @MainActor
    func completeRegistration() async {
        // Mark first time login as complete
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.firstTimeLogin)
        
        // Final step completed
        currentStep = .completed
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyProfile() -> Profile {
        let userId = UserDefaults.standard.currentUserId ?? UUID().uuidString
        let apiKey = UserDefaults.standard.currentAPIKey ?? ""
        
        return Profile(
            uid: userId,
            mno: mobileNumber,
            nam: nil,
            eml: nil,
            img: nil,
            irl: nil,
            pid: nil,
            stk: apiKey,
            plc: "en",
            pns: true,
            blk: false,
            off: false,
            sup: nil,
            lcs: nil,
            ca: Int64(Date().timeIntervalSince1970),
            cb: userId,
            ua: Int64(Date().timeIntervalSince1970),
            ub: userId,
            d: false
        )
    }
    
    private func createSupplierProfile() -> Supplier {
        let userId = UserDefaults.standard.currentUserId ?? UUID().uuidString
        return Supplier(
            uid: userId,
            bnm: businessName.isEmpty ? nil : businessName,
            bpr: nil,
            scl: 1,
            dcn: nil,
            ucn: nil,
            sdc: nil
        )
    }
    
    private func saveProfileLocally(_ profile: Profile) {
        UserDefaults.standard.setUserProfile(profile)
    }
    
    func loadProfileFromLocal() {
        userProfile = UserDefaults.standard.getUserProfile()
    }
    
    // MARK: - Validation
    
    var isMobileValid: Bool {
        mobileNumber.count == 10 && mobileNumber.allSatisfy { $0.isNumber }
    }
    
    var isOTPValid: Bool {
        otpCode.count == 4 && otpCode.allSatisfy { $0.isNumber }
    }
    
    var isNameValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Reset
    
    func resetRegistration() {
        currentStep = .mobileEntry
        userProfile = nil
        mobileNumber = ""
        otpCode = ""
        fullName = ""
        businessName = ""
        isSupplier = false
        photoIDImage = nil
        shouldSkipPhotoID = false
        errorMessage = nil
        isLoading = false
    }
}
