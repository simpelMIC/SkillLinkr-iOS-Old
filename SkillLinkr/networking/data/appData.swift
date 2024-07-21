//
//  appData.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI

struct AppData: Codable, Equatable {
    var apiURL: String
    var dataURL: String
    var userToken: String?
    var user: User?
    var appSettings: AppSettings
}

struct AppSettings: Codable, Equatable {
    var showFeedActionButtons: Bool?
}

class AppDataModule {
    @Binding var appData: AppData
    
    init(appData: Binding<AppData>) {
        self._appData = appData
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(AppDataJSONModule().encode($appData.wrappedValue), forKey: "SkilllinkrAppData")
        print("Saved AppData")
    }
    
    func load() {
        let defaults = UserDefaults.standard
        let appData = AppDataJSONModule().decode(defaults.string(forKey: "SkilllinkrAppData") ?? "")
        self.appData = appData ?? AppData(apiURL: "https://skilllinkr.micstudios.de/api", dataURL: "https://images.skilllinkr.micstudios.de/upload", appSettings: AppSettings())
    }
}

class AppDataJSONModule {
    // Method to encode client data to JSON string
    func encode(_ data: AppData) -> String? {
        let encoder = JSONEncoder()
        // Attempt to encode client data to JSON
        if let json = try? encoder.encode(data) {
            // Convert JSON data to UTF-8 string and return
            return String(data: json, encoding: .utf8)
        } else {
            // Print error message if encoding fails
            print("Error encoding ClientData")
            return nil
        }
    }
    
    // Method to decode JSON string to client data
    func decode(_ string: String) -> AppData? {
        // Convert JSON string to data
        guard let data = string.data(using: .utf8) else {
            // Print error message if conversion fails
            print("Couldn't convert received message to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            // Attempt to decode JSON data to ClientData object
            let packetData = try decoder.decode(AppData.self, from: data)
            return packetData
        } catch {
            // Print error message if decoding fails
            print("Error decoding ClientData: \(error)")
            return nil
        }
    }
}
