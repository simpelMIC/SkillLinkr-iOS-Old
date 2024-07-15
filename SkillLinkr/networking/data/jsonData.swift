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

struct UserResponse: Codable, Equatable {
    var status: String
    var message: User
}

struct User: Codable, Equatable {
    var id: String
    var firstname: String
    var lastname: String
    var mail: String
    var released: Bool
    var role: UserRole
    var updatedAt: String
    var createdAt: String
}

struct UserRole: Codable, Equatable {
    var id: Int
    var name: String
    var description: String
    var createdAt: String
    var updatedAt: String
}

struct PatchUserResponse: Codable {
    var status: String
    var message: String
}

struct ErrorResponse: Codable {
    var status: String
    var message: String
}
