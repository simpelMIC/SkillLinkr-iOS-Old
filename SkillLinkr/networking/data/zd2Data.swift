//
//  zd2Data.swift
//  SkillLinkr
//
//  Created by Christian on 21.07.24.
//

import Foundation
import SwiftUI

struct ZD2Data: Codable, Equatable {
    var settings: ZD2Settings
    var appUser: AppUser
    var cache: ZD2Cache
    var zd1Data: AppData?
}

struct ZD2User: Codable, Equatable {
    var user: User
    var socialmedia: Socialmedia
    var teachingInformation: Teachinginformation
    var skills: [Skill]
}

struct AppUser: Codable, Equatable {
    var userToken: String
    var loggedIn: Bool
    var verifiedLogIn: Bool
    var user: ZD2User
}

struct ZD2Settings: Codable, Equatable {
    var apiURL: URL
    var imageServerURL: URL?
    var showFeedActionButtons: Bool
}

struct ZD2Cache: Codable, Equatable {
    var users: [ZD2User]
    var skillCategories: [SkillCategory]
    var skills: [Skill]
    var images: [CachedImage]
}

class ZD2DataModule {
    func save(_ data: ZD2Data) {
        Task {
            await ZD2DataUserDefaultsModule().save(data)
        }
    }
    
    func load(completion: @escaping (ZD2Data?) -> Void) {
        Task {
            let data = await ZD2DataUserDefaultsModule().load()
            completion(data)
        }
    }
}

class ZD2DataUserDefaultsModule {
    func save(_ zd2Data: ZD2Data) async {
        let defaults = UserDefaults.standard
        await defaults.set(ZD2DataJSONModule().encode(zd2Data), forKey: "SkilllinkrZD2Data")
        print("Saved ZD2Data")
    }
    
    func load() async -> ZD2Data? {
        let defaults = UserDefaults.standard
        let zd2Data = await ZD2DataJSONModule().decode(defaults.string(forKey: "SkilllinkrZD2Data") ?? "")
        return zd2Data
    }
}

class ZD2DataJSONModule {
    // Method to encode client data to JSON string
    func encode(_ data: ZD2Data) async -> String? {
        let encoder = JSONEncoder()
        // Attempt to encode client data to JSON
        if let json = try? encoder.encode(data) {
            // Convert JSON data to UTF-8 string and return
            return String(data: json, encoding: .utf8)
        } else {
            // Print error message if encoding fails
            print("Error encoding ZD2DATA")
            return nil
        }
    }
    
    // Method to decode JSON string to client data
    func decode(_ string: String) async -> ZD2Data? {
        // Convert JSON string to data
        guard let data = string.data(using: .utf8) else {
            // Print error message if conversion fails
            print("Couldn't convert received message to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            // Attempt to decode JSON data to ClientData object
            let packetData = try decoder.decode(ZD2Data.self, from: data)
            return packetData
        } catch {
            // Print error message if decoding fails
            print("Error decoding ZD2DATA: \(error)")
            return nil
        }
    }
}
