//
//  RegistrationAPIManager.swift
//  ratibPal
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation
import UIKit

class RegistrationAPIManager {
    static let shared = RegistrationAPIManager()
    
    // Use only the HTTP endpoints specified by user
    private let debugBaseURL = "http://devapi.ratibpal.com/"
    private let productionBaseURL = "http://devapi.ratibpal.com/"  // Use same for both debug and production for now
    private let apiVersion = "api2/v1/"
    
    private var baseURL: String {
        // Always use the HTTP debug endpoint for now
        return debugBaseURL + apiVersion
    }
    
    private let session = URLSession.shared
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - Private Helper Methods
    
    private func createRequest(endpoint: String, method: String = "GET", body: Data? = nil, requiresAuth: Bool = false) -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add language header
        let language = UserDefaults.standard.selectedLanguage
        request.setValue(language, forHTTPHeaderField: "Accept-Language")
        
        // Add authentication if required
        if requiresAuth {
            let apiKey = UserDefaults.standard.currentAPIKey ?? ""
            request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        // Add debugging information
        print("🌐 Making request to: \(request.url?.absoluteString ?? "unknown URL")")
        print("🔧 HTTP Method: \(request.httpMethod ?? "GET")")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RegistrationAPIError.invalidResponse
            }
            
            print("📡 Response Status Code: \(httpResponse.statusCode)")
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                return try decoder.decode(T.self, from: data)
            case 401:
                throw RegistrationAPIError.sessionExpired
            case 501:
                throw RegistrationAPIError.logoutRequired
            default:
                // Try to decode error response
                if let errorResponse = try? decoder.decode(Errors.self, from: data),
                   let firstError = errorResponse.general?.first {
                    throw RegistrationAPIError.apiError(firstError.message, firstError.messageCode)
                } else {
                    throw RegistrationAPIError.serverError(httpResponse.statusCode)
                }
            }
        } catch {
            print("❌ Network Error: \(error)")
            print("❌ Error Type: \(type(of: error))")
            
            if let urlError = error as? URLError {
                print("❌ URL Error Code: \(urlError.code)")
                print("❌ URL Error Description: \(urlError.localizedDescription)")
                
                // Provide more specific error messages
                switch urlError.code {
                case .notConnectedToInternet:
                    throw RegistrationAPIError.networkError("No internet connection. Please check your network settings.")
                case .cannotFindHost:
                    throw RegistrationAPIError.networkError("Server not found. Please try again later.")
                case .timedOut:
                    throw RegistrationAPIError.networkError("Request timed out. Please try again.")
                case .cannotConnectToHost:
                    throw RegistrationAPIError.networkError("Cannot connect to server. Please check your connection.")
                case .secureConnectionFailed:
                    throw RegistrationAPIError.networkError("Secure connection failed. Please try again.")
                default:
                    throw RegistrationAPIError.networkError("Connection failed: \(urlError.localizedDescription)")
                }
            }
            
            if error is RegistrationAPIError {
                throw error
            } else if error is DecodingError {
                throw RegistrationAPIError.decodingError
            } else {
                throw RegistrationAPIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - API Methods
    
    func sendOTP(mobileNumber: String) async throws -> LoginResponse {
        let request = LoginRequest(mobileNo: mobileNumber, appType: "omni")
        let body = try encoder.encode(request)
        
        guard let urlRequest = createRequest(endpoint: "otp/send", method: "POST", body: body) else {
            throw RegistrationAPIError.invalidURL
        }
        
        return try await performRequest(urlRequest, responseType: LoginResponse.self)
    }
    
    func verifyOTP(mobileNumber: String, otp: String) async throws -> Profile {
        let otpModel = OtpModel(
            mobileNo: mobileNumber,
            otp: otp,
            deviceDetails: DeviceDetails.current
        )
        let body = try encoder.encode(otpModel)
        
        guard let urlRequest = createRequest(endpoint: "otp/verify", method: "POST", body: body) else {
            throw RegistrationAPIError.invalidURL
        }
        
        let profile = try await performRequest(urlRequest, responseType: Profile.self)
        
        // Save session data
        UserDefaults.standard.set(profile.uid, forKey: UserDefaultsKeys.userId)
        UserDefaults.standard.set(profile.stk, forKey: UserDefaultsKeys.apiSessionKey)
        UserDefaults.standard.set(profile.pns, forKey: UserDefaultsKeys.notificationSettingStatus)
        
        return profile
    }
    
    func updateProfile(_ profile: Profile) async throws -> LoginResponse {
        let body = try encoder.encode(profile)
        
        guard let urlRequest = createRequest(endpoint: "secure/users", method: "POST", body: body, requiresAuth: true) else {
            throw RegistrationAPIError.invalidURL
        }
        
        return try await performRequest(urlRequest, responseType: LoginResponse.self)
    }
    
    func uploadPhotoID(imageData: Data) async throws -> ImageUploadResponseModel {
        guard let url = URL(string: baseURL + "secure/file/upload/aadhaar") else {
            throw RegistrationAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add authentication
        let apiKey = UserDefaults.standard.currentAPIKey ?? ""
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()
        httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
        httpBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo_id.jpg\"\r\n".data(using: .utf8)!)
        httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        httpBody.append(imageData)
        httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = httpBody as Data
        
        return try await performRequest(request, responseType: ImageUploadResponseModel.self)
    }
    
    func getUserProfile(userId: String) async throws -> Profile {
        guard let urlRequest = createRequest(endpoint: "secure/users?uid=\(userId)", requiresAuth: true) else {
            throw RegistrationAPIError.invalidURL
        }
        
        return try await performRequest(urlRequest, responseType: Profile.self)
    }
}

// MARK: - Error Types
enum RegistrationAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(String)
    case decodingError
    case sessionExpired
    case logoutRequired
    case serverError(Int)
    case apiError(String, String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        case .sessionExpired:
            return "Session expired. Please login again."
        case .logoutRequired:
            return "Logout required"
        case .serverError(let code):
            return "Server error: \(code)"
        case .apiError(let message, _):
            return message
        }
    }
}
