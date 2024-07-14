//
//  appData.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI

struct AppSettings: Codable, Equatable {
    var apiURL: String
    var userToken: String?
    var user: User?
}

class AppDataModule {
    @Binding var settings: AppSettings
    
    init(settings: Binding<AppSettings>) {
        self._settings = settings
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(AppDataJSONModule().encode($settings.wrappedValue), forKey: "SkilllinkrAppData")
        print("Saved AppData")
    }
    
    func load() {
        let defaults = UserDefaults.standard
        let appData = AppDataJSONModule().decode(defaults.string(forKey: "SkilllinkrAppData") ?? "")
        settings = appData ?? AppSettings(apiURL: "https://skilllinkr.micstudios.de/api")
    }
}

class AppDataJSONModule {
    // Method to encode client data to JSON string
    func encode(_ data: AppSettings) -> String? {
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
    func decode(_ string: String) -> AppSettings? {
        // Convert JSON string to data
        guard let data = string.data(using: .utf8) else {
            // Print error message if conversion fails
            print("Couldn't convert received message to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            // Attempt to decode JSON data to ClientData object
            let packetData = try decoder.decode(AppSettings.self, from: data)
            return packetData
        } catch {
            // Print error message if decoding fails
            print("Error decoding ClientData: \(error)")
            return nil
        }
    }
}
