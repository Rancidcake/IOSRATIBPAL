import Foundation
import UIKit

class OfferingAPIService {
    static let shared = OfferingAPIService()
    private init() {}
    
    // MARK: - Configuration
    private struct APIConfig {
        #if DEBUG
        static let debugBaseURL = "http://devapi.ratibpal.com/"
        static let baseURL = debugBaseURL
        #else
        static let releaseBaseURL = "https://api.ratibpal.com/"
        static let baseURL = releaseBaseURL
        #endif
    }
    
    // MARK: - Headers
    private func getAuthHeaders() -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = SessionManager.shared.getApiSessionKey() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    // MARK: - URL Builder
    private func buildURL(endpoint: String, queryParams: [String: Any] = [:]) -> URL? {
        guard let baseURL = URL(string: APIConfig.baseURL) else { return nil }
        let fullURL = baseURL.appendingPathComponent(endpoint)
        
        if queryParams.isEmpty {
            return fullURL
        }
        
        var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false)
        components?.queryItems = queryParams.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        return components?.url
    }
    
    // MARK: - HTTP Methods
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    // MARK: - Generic Request Method
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Codable? = nil,
        queryParams: [String: Any] = [:],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = buildURL(endpoint: endpoint, queryParams: queryParams) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                // Check for HTTP status codes
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    
                    // Handle session expiry (401 Unauthorized)
                    if httpResponse.statusCode == 401 {
                        print("❌ Session expired. Notifying AuthenticationManager.")
                        AuthenticationManager.notifySessionExpired()
                        completion(.failure(APIError.sessionExpired))
                        return
                    }
                }
                
                // Debug: Print the actual response data
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(responseString)")
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    print("Decoding error: \(error)")
                    
                    // Try to decode as error response
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        let errorMessage = errorResponse.general?.first?.message ?? "Unknown error"
                        completion(.failure(APIError.serverError(errorMessage)))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Set/Update My Offerings
    func setMyOfferings(offerings: [GSUResponse], completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings"
        let headers = getAuthHeaders()
        
        performRequest(
            endpoint: endpoint,
            method: .POST,
            headers: headers,
            body: offerings
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.success ?? false))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Save My Offering
    func saveMyOffering(_ offering: GSUResponse, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/save"
        let headers = getAuthHeaders()
        
        performRequest(
            endpoint: endpoint,
            method: .POST,
            headers: headers,
            body: offering
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.success ?? false))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sync My Offerings
    func syncMyOfferings(lastSyncTime: Int64? = nil, limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings"
        let headers = getAuthHeaders()
        
        var queryParams: [String: Any] = [
            "limit": limit,
            "offset": offset
        ]
        
        if let userId = SessionManager.shared.getUserId() {
            queryParams["userId"] = userId
        }
        
        if let lastSync = lastSyncTime {
            queryParams["lsc"] = lastSync
        }
        
        // Debug logging for offering API call
        print("🌐 Making request to: \(APIConfig.baseURL)\(endpoint)")
        print("🔧 HTTP Method: GET")
        print("📋 Query Parameters: \(queryParams)")
        print("🔑 Headers: \(headers.keys.joined(separator: ", "))")
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            queryParams: queryParams
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                // Handle both standard and direct array responses
                let offerings = response.data ?? []
                print("✅ Offering API success: received \(offerings.count) offerings")
                completion(.success(offerings))
            case .failure(let error):
                print("❌ Offering API failed with error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Delete My Offering
    func deleteMyOffering(gid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/delete"
        let headers = getAuthHeaders()
        let queryParams = ["gid": gid]
        
        performRequest(
            endpoint: endpoint,
            method: .DELETE,
            headers: headers,
            queryParams: queryParams
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.success ?? false))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sync Linked Offerings
    func syncLinkedOfferings(lastSyncTime: Int64? = nil, completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/linked"
        let headers = getAuthHeaders()
        
        var queryParams: [String: Any] = [:]
        if let lastSync = lastSyncTime {
            queryParams["lsc"] = lastSync
        }
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            queryParams: queryParams
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Search Offerings by Source
    func searchOfferingsBySource(sourceId: String, searchText: String? = nil, limit: Int = 50, offset: Int = 0, completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/source"
        let headers = getAuthHeaders()
        
        var queryParams: [String: Any] = [
            "sourceId": sourceId,
            "limit": limit,
            "offset": offset
        ]
        
        if let search = searchText {
            queryParams["search"] = search
        }
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            queryParams: queryParams
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Dirty Offerings
    func getDirtyOfferings(completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/getdirty"
        let headers = getAuthHeaders()
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get My Offerings
    func getMyOfferings(completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/getmy"
        let headers = getAuthHeaders()
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Search My Offerings
    func searchMyOfferings(searchText: String, categoryId: String? = nil, city: String? = nil, limit: Int = 10, offset: Int = 0, completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/search"
        let headers = getAuthHeaders()
        
        var queryParams: [String: Any] = [
            "search": searchText,
            "limit": limit,
            "offset": offset
        ]
        
        if let userId = SessionManager.shared.getUserId() {
            queryParams["userId"] = userId
            queryParams["userSupplierChainLevel"] = SessionManager.shared.getUserSupplierChainLevel() ?? 1
        }
        
        if let catId = categoryId {
            queryParams["categoryId"] = catId
        }
        
        if let cityName = city {
            queryParams["city"] = cityName
        }
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            queryParams: queryParams
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sync Categories
    func syncCategories(completion: @escaping (Result<[CategoryResponse], Error>) -> Void) {
        getCategories(completion: completion)
    }
    
    // MARK: - Get Categories
    func getCategories(completion: @escaping (Result<[CategoryResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/categories"
        let headers = getAuthHeaders()
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers
        ) { (result: Result<[CategoryResponse], Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Offerings of Source
    func fetchOfferingsOfSource(sourceId: String, searchText: String? = nil, limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[GSUResponse], Error>) -> Void) {
        let endpoint = "api2/v1/secure/offerings/source"
        let headers = getAuthHeaders()
        
        var queryParams: [String: Any] = [
            "sourceId": sourceId,
            "limit": limit,
            "offset": offset
        ]
        
        if let userId = SessionManager.shared.getUserId() {
            queryParams["userId"] = userId
        }
        
        if let search = searchText {
            queryParams["search"] = search
        }
        
        performRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            queryParams: queryParams
        ) { (result: Result<OfferingAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Upload Offering Image
    func uploadOfferingImage(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = UIImage(data: imageData) else {
            completion(.failure(APIError.invalidResponse))
            return
        }
        uploadImage(image, completion: completion)
    }
    
    // MARK: - Image Upload 
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "api2/v1/secure/image/upload"
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(APIError.invalidImageData))
            return
        }
        
        guard let url = buildURL(endpoint: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        if let token = SessionManager.shared.getApiSessionKey() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
                    if let imageId = result.fId {
                        completion(.success(imageId))
                    } else {
                        completion(.failure(APIError.invalidResponse))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - API Errors
enum APIError: Error {
    case invalidURL
    case noData
    case invalidImageData
    case invalidResponse
    case networkError(String)
    case sessionExpired
    case serverError(String)
}

// MARK: - Error Response Models
struct ErrorResponse: Codable {
    let general: [ErrorDetail]?
}

struct ErrorDetail: Codable {
    let messageCode: String?
    let message: String?
}