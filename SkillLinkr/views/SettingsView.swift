//
//  settings.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        List {
            NavigationLink("Developer Settings") {
                DeveloperSettingsView(httpModule: $httpModule, settings: $settings)
            }
            Button("Log Out", role: .destructive) {
                settings.userToken = nil
                AppDataModule(settings: $settings).save()
            }
        }
        .navigationTitle("Settings")
    }
}

struct DeveloperSettingsView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        List {
            Text($settings.userToken.wrappedValue ?? "No Token")
            if $settings.userToken.wrappedValue != nil {
                Button("Copy Token") {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = $settings.userToken.wrappedValue ?? ""
                }
            }
        }
        .navigationTitle("Developer Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(httpModule: .constant(HTTPModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", userToken: "")), appDataModule: AppDataModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api"))))), settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api")))
    }
}
