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
                        Task {
                            await self.appDataModule.save()
                        }
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
                        Task {
                            await self.appDataModule.save()
                        }
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
    
    func getUser(_ user: User, completion: @escaping (Result<UserResponse, Error>) -> Void) {
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
    
    func patchUser(token: String, patchUserId: String, firstname: String? = nil, lastname: String? = nil, password: String? = nil, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        let url = URL(string: "\(settings.apiURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId
        ]
        
        if let firstname = firstname {
            parameters["firstname"] = firstname
        }
        
        if let lastname = lastname {
            parameters["lastname"] = lastname
        }
        
        if let password = password {
            parameters["password"] = password
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
                    let patchUserResponse = try JSONDecoder().decode(PatchResponse.self, from: data)
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
    
    func patchSocialmedia(patchUserId: String, xName: String?, instagramName: String?, discordName: String?, facebookName: String?, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
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
                    let patchSocialmediaResponse = try JSONDecoder().decode(PatchResponse.self, from: data)
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
    
    func getSkillCategories(completion: @escaping (Result<GetSkillCategoriesResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/skillcategories")!
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
                    let response = try JSONDecoder().decode(GetSkillCategoriesResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkillCategory(_ id: Int, completion: @escaping (Result<GetSkillCategoryResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/skillcategory/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillCategoryResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkills(_ id: Int, completion: @escaping (Result<GetSkillsResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/skills/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillsResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkill(_ id: Int, completion: @escaping (Result<GetSkillResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/skill/specific/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkillTeachers(_ id: Int, completion: @escaping (Result<GetSkillTeachersResponse, Error>) -> Void) {
        guard let token = settings.userToken else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token"])
            completion(.failure(error))
            return
        }
        
        let url = URL(string: "\(settings.apiURL)/skill/teachers/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillTeachersResponse.self, from: data)
                    completion(.success(response))
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
    
    
    
    //IMAGE HANDLER
    
    func uploadImage(_ image: UIImage, url: URL, owner: User, key: String) {
        let phpURL = URL(string: "\(url)/upload.php")!
        var request = URLRequest(url: phpURL)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(owner.id)_\(key).jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 1.0)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                let alert = UIAlertController(title: "Failed to upload image", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = scene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
                print("Upload error: \(error)")
                return
            }
            if let responseData = responseData {
                print("Response: \(String(data: responseData, encoding: .utf8) ?? "No response")")
            }
        }.resume()
    }
    
    func getImageURL(owner: User, key: String) -> URL {
        return URL(string: "\($settings.dataURL.wrappedValue)/uploads/\(owner.id)_\(key).jpg")!
    }
}










//ZD2 HTTP

class HTTPSModule: ObservableObject {
    func login(apiURL: String, mail: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = URL(string: "\(apiURL)/login")!
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
    
    func register(apiURL: String, mail: String, firstname: String, lastname: String, password: String, passwordConfirm: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        let url = URL(string: "\(apiURL)/register")!
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
    
    func getUser(_ user: User, zd2Data: ZD2Data, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/user")!
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
    
    func patchUser(zd2Data: ZD2Data, patchUserId: String, firstname: String? = nil, lastname: String? = nil, password: String? = nil, roleID: Int? = nil, released: Bool? = nil, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        let url = URL(string: "\(zd2Data.settings.apiURL)/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(zd2Data.appUser.userToken)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "patchUserId": patchUserId
        ]
        
        if let firstname = firstname {
            parameters["firstname"] = firstname
        }
        
        if let lastname = lastname {
            parameters["lastname"] = lastname
        }
        
        if let password = password {
            parameters["password"] = password
        }
        
        if let roleID = roleID {
            parameters["roleID"] = roleID
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
                    let response = try JSONDecoder().decode(PatchResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSocialmedia(zd2Data: ZD2Data, completion: @escaping (Result<GetSocialmediaResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/user/socialmedia")!
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
    
    func patchSocialmedia(zd2Data: ZD2Data, patchUserId: String, xName: String?, instagramName: String?, discordName: String?, facebookName: String?, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        let url = URL(string: "\(zd2Data.settings.apiURL)/user/socialmedia")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(zd2Data.appUser.userToken)", forHTTPHeaderField: "Authorization")
        
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
                    let response = try JSONDecoder().decode(PatchResponse.self, from: data)
                    completion(.success(response))
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
    
    func getTeachingInformation(zd2Data: ZD2Data, completion: @escaping (Result<GetTeachinginformationResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/user/teachinginformation")!
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
    
    func patchTeachingInformation(zd2Data: ZD2Data, patchUserId: String, teachesOnline: Bool, teachesInPerson: Bool, teachingCity: String?, teachingCountry: String?, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        let url = URL(string: "\(zd2Data.settings.apiURL)/user/teachinginformation")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("JWT \(zd2Data.appUser.userToken)", forHTTPHeaderField: "Authorization")
        
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
    
    func getUserRelease(zd2Data: ZD2Data, completion: @escaping (Result<GetUserReleaseResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/user/released")!
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
    
    func getSkillCategories(zd2Data: ZD2Data, completion: @escaping (Result<GetSkillCategoriesResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/skillcategories")!
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
                    let response = try JSONDecoder().decode(GetSkillCategoriesResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkillCategory(_ id: Int, zd2Data: ZD2Data, completion: @escaping (Result<GetSkillCategoryResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/skillcategory/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillCategoryResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkills(_ id: Int, zd2Data: ZD2Data, completion: @escaping (Result<GetSkillsResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/skills/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillsResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkill(_ id: Int, zd2Data: ZD2Data, completion: @escaping (Result<GetSkillResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/skill/specific/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillResponse.self, from: data)
                    completion(.success(response))
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
    
    func getSkillTeachers(_ id: Int, zd2Data: ZD2Data, completion: @escaping (Result<GetSkillTeachersResponse, Error>) -> Void) {
        let token = zd2Data.appUser.userToken
        let url = URL(string: "\(zd2Data.settings.apiURL)/skill/teachers/\(String(id))")!
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
                    let response = try JSONDecoder().decode(GetSkillTeachersResponse.self, from: data)
                    completion(.success(response))
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
}
