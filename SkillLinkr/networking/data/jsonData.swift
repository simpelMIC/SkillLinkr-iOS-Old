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

struct ErrorResponse: Codable {
    var status: String
    var message: String
}

struct GetSocialmediaResponse: Codable {
    var status: String
    var message: Socialmedia
}

struct Socialmedia: Codable, Equatable {
    var id: Int
    var userId: String
    var discordName: String?
    var facebookName: String?
    var instagramName: String?
    var xName: String?
    var updatedAt: String
    var createdAt: String
}

struct Teachinginformation: Codable, Equatable {
    var id: Int
    var userId: String
    var teachesInPerson: Bool
    var teachesOnline: Bool
    var teachingCity: String?
    var teachingCountry: String?
    var updatedAt: String
    var createdAt: String
}

struct GetTeachinginformationResponse: Codable {
    var status: String
    var message: Teachinginformation
}

struct PatchResponse: Codable {
    var status: String
    var message: String
}

struct GetUserReleaseResponse: Codable {
    var status: String
    var message: String
}

struct AnyError: Error {
    let error: Error
    
    init(_ error: Error) {
        self.error = error
    }
}

struct SkillCategory: Codable, Equatable {
    var id: Int
    var name: String
    var createdAt: String //Date
    var updatedAt: String //Date
}

struct GetSkillCategoriesResponse: Codable, Equatable {
    var status: String
    var message: [SkillCategory]
}

struct Skill: Codable, Equatable {
    var id: Int
    var name: String
    var createdAt: String
    var updatedAt: String
    var skillCategoryId: Int
}

struct GetSkillResponse: Codable, Equatable {
    var status: String
    var message: Skill
}

struct GetSkillsResponse: Codable, Equatable {
    var status: String
    var message: [Skill]
}

struct GetSkillCategoryResponse: Codable, Equatable {
    var status: String
    var message: SkillCategory
}

struct GetSkillTeachersResponse: Codable, Equatable {
    var status: String
    var message: [User]
}

struct GetUserSkillsResponse: Codable, Equatable {
    var status: String
    var message: GetUserResponseThing
}

struct GetUserResponseThing: Codable, Equatable {
    var id: String
    var skillsToTeach: [Skill]
}
