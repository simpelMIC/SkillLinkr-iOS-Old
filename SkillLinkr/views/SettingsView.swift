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
    @State var localApiURL: String = ""
    @State var isAlertPresented: Bool = false
    var body: some View {
        List {
            Section("App") {
                TextField("API URL", text: $localApiURL)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                Button("Update") {
                    isAlertPresented.toggle()
                }
                .disabled($settings.apiURL.wrappedValue == $localApiURL.wrappedValue)
            }
            Section("User") {
                Text($settings.userToken.wrappedValue ?? "No Token")
                if $settings.userToken.wrappedValue != nil {
                    Button("Copy Token") {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = $settings.userToken.wrappedValue ?? ""
                    }
                }
            }
        }
        .navigationTitle("Developer Settings")
        .onAppear {
            localApiURL = $settings.apiURL.wrappedValue
        }
        .alert("You really wanna do that??", isPresented: $isAlertPresented) {
            if $settings.apiURL.wrappedValue == "https://skilllinkr.micstudios.de/api" {
                Button("No I want to be good", role: .cancel) {
                    localApiURL = $settings.apiURL.wrappedValue
                    isAlertPresented.toggle()
                }
                Button("Yes I am a villain", role: .destructive) {
                    settings.apiURL = $localApiURL.wrappedValue
                    isAlertPresented.toggle()
                }
            } else {
                Button("No I want to stay a villain", role: .cancel) {
                    localApiURL = $settings.apiURL.wrappedValue
                    isAlertPresented.toggle()
                }
                Button("Yes I want to go to the good side :)", role: .destructive) {
                    settings.apiURL = $localApiURL.wrappedValue
                    isAlertPresented.toggle()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(httpModule: .constant(HTTPModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", userToken: "")), appDataModule: AppDataModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api"))))), settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api")))
    }
}
