//
//  jsonData.swift
//  SkillLinkr
//
//  Created by Christian on 13.07.24.
//

import Foundation

struct LoginResponse: Codable {
    var status: String
    var message: Message
    
    struct Message: Codable {
        var token: String
    }
}

struct RegisterResponse: Codable {
    var status: String
    var message: Message
    
    struct Message: Codable {
        var token: String
    }
}

struct UserResponse: Codable {
    var status: String
    var message: User
    var user: User
}

struct User: Codable {
    var id: Int
    var firstname: String
    var lastname: String
    var mail: String
    var released: Bool
    var role: String
}

struct PatchUserResponse: Codable {
    var status: String
    var message: String
}

struct ErrorResponse: Codable {
    var status: String
    var message: String
}
