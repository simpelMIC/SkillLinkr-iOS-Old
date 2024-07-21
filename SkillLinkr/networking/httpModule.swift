//
//  httpModule.swift
//  SkillLinkr
//
//  Created by Christian on 13.07.24.
//

import Foundation
import SwiftUI

class HTTPModule: ObservableObject {
    @Binding var settings: AppData
    @State var appDataModule: AppDataModule
    
    init(settings: Binding<AppData>, appDataModule: AppDataModule) {
        self._settings = settings
        self.appDataModule = appDataModule
    }
    
    func login(mail: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = URL(string: "\(settings.apiURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "mail": mail,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.settings.userToken = loginResponse.message.token
                        self.appDataModule.save()
                    }
                    completion(.success(loginResponse))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func register(mail: String, firstname: String, lastname: String, password: String, passwordConfirm: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        let url = URL(string: "\(settings.apiURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "mail": mail,
            "firstname": firstname,
            "lastname": lastname,
            "password": password,
            "passwordConfirm": passwordConfirm
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 201 {
                do {
                    let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.settings.userToken = registerResponse.message.token
                        self.appDataModule.save()
                    }
                    completion(.success(registerResponse))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    completion(.failure(decodeError))
                }
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getUser(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(userResponse))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func patchUser(token: String, patchUserId: String, mail: String? = nil, firstname: String? = nil, lastname: String? = nil, password: String? = nil, roleId: Int? = nil, released: Bool? = nil, completion: @escaping (Result<PatchUserResponse, Error>) -> Void) {
        let url = URL(string: "\(settings.apiURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId
        ]
        
        if let mail = mail {
            parameters["mail"] = mail
        }
        
        if let firstname = firstname {
            parameters["firstname"] = firstname
        }
        
        if let lastname = lastname {
            parameters["lastname"] = lastname
        }
        
        if let password = password {
            parameters["password"] = password
        }
        
        if let roleId = roleId {
            parameters["roleId"] = roleId
        }
        
        if let released = released {
            parameters["released"] = released
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let patchUserResponse = try JSONDecoder().decode(PatchUserResponse.self, from: data)
                    completion(.success(patchUserResponse))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func getSocialmedia(completion: @escaping (Result<GetSocialmediaResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/user/socialmedia")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let socialmediaResponse = try JSONDecoder().decode(GetSocialmediaResponse.self, from: data)
                    completion(.success(socialmediaResponse))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func patchSocialmedia(patchUserId: String, xName: String?, instagramName: String?, discordName: String?, facebookName: String?, completion: @escaping (Result<PatchSocialmediaResponse, Error>) -> Void) {
        let url = URL(string: "\(settings.apiURL)/user/socialmedia")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \($settings.userToken.wrappedValue ?? "")", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId
        ]
        
        if let xName = xName {
            parameters["xName"] = xName
        }
        
        if let instagramName = instagramName {
            parameters["instagramName"] = instagramName
        }
        
        if let discordName = discordName {
            parameters["discordName"] = discordName
        }
        
        if let facebookName = facebookName {
            parameters["facebookName"] = facebookName
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let patchSocialmediaResponse = try JSONDecoder().decode(PatchSocialmediaResponse.self, from: data)
                    completion(.success(patchSocialmediaResponse))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getTeachingInformation(completion: @escaping (Result<GetTeachinginformationResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/user/teachinginformation")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let teachinginformationResponse = try JSONDecoder().decode(GetTeachinginformationResponse.self, from: data)
                    completion(.success(teachinginformationResponse))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func patchTeachingInformation(patchUserId: String, teachesOnline: Bool, teachesInPerson: Bool, teachingCity: String?, teachingCountry: String?, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        let url = URL(string: "\(settings.apiURL)/user/teachinginformation")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \($settings.userToken.wrappedValue ?? "")", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId,
            "teachesOnline": teachesOnline,
            "teachesInPerson": teachesInPerson
        ]
        
        if let teachingCity = teachingCity {
            parameters["teachingCity"] = teachingCity
        }
        
        if let teachingCountry = teachingCountry {
            parameters["teachingCountry"] = teachingCountry
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let patchResponse = try JSONDecoder().decode(PatchResponse.self, from: data)
                    completion(.success(patchResponse))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.failure(error))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.failure(error))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getUserRelease(completion: @escaping (Result<GetUserReleaseResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/user/released")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.success(GetUserReleaseResponse(status: "error", message: "\(error.localizedDescription)")))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(GetUserReleaseResponse(status: "success", message: "The account is released")))
                self.settings.user = User(id: "", firstname: "", lastname: "", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
            } else if httpResponse.statusCode == 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                    completion(.success(GetUserReleaseResponse(status: "error", message: "\(error.localizedDescription)")))
                } catch let decodeError {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode error response: \(decodeError). Response: \(responseString)"])
                    completion(.success(GetUserReleaseResponse(status: "error", message: "\(error.localizedDescription)")))
                }
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response"
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response status code: \(httpResponse.statusCode). Response: \(responseString)"])
                completion(.success(GetUserReleaseResponse(status: "error", message: "\(error.localizedDescription)")))
            }
        }
        
        task.resume()
    }
    
    
    
    //IMAGE HANDLER
    
    func uploadImage(imageData: Data, to url: URL, withAccessKey accessKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Append the access key as a query parameter
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "access_key", value: accessKey)]
        guard let fullURL = components.url else {
            let error = NSError(domain: url.absoluteString, code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: url.absoluteString, code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                let responseString = String(data: data ?? Data(), encoding: .utf8) ?? "No response data"
                DispatchQueue.main.async {
                    completion(.success(responseString))
                }
            } else {
                let error = NSError(domain: url.absoluteString, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }

}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
