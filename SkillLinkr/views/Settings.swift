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
    @Binding var appData: AppData
    @State var isAlertPresented: Bool = false
    var body: some View {
        List {
            Section("Your Account") {
                NavigationLink("Edit Profile") {
                    PatchProfileView(httpModule: $httpModule, appData: $appData, navigationBarTitleMode: .large) {
                        
                    }
                }
                Button("Log Out", role: .destructive) {
                    isAlertPresented.toggle()
                }
            }
            Section("How you use SkillLinkr") {
                
            }
            Section("What you see") {
                
            }
            Section("Who can see your content") {
                
            }
            Section("How others can interact with you") {
                
            }
            Section("Your app and your media") {
                NavigationLink("Customize") {
                    CustomizationFeaturesView(httpModule: $httpModule, appData: $appData)
                }
            }
            Section("Other information and Support-Methods") {
                NavigationLink("Developer Settings") {
                    DeveloperSettingsView(httpModule: $httpModule, appData: $appData)
                }
            }
        }
        .navigationTitle("Settings")
        .alert("You really wanna go? :(", isPresented: $isAlertPresented) {
            Button("Log Out", role: .destructive) {
                appData.userToken = nil
                AppDataModule(appData: $appData).save()
            }
        }
    }
}

struct CustomizationFeaturesView: View {
    @Binding var httpModule: HTTPModule
    @Binding var appData: AppData
    var body: some View {
        List {
            Section("Feed") {
                Toggle("Show Action Buttons", isOn: Binding(
                    get: { appData.appSettings.showFeedActionButtons ?? false },
                    set: { appData.appSettings.showFeedActionButtons = $0 }
                ))
            }
        }
        .navigationTitle("Customize")
    }
}

struct DeveloperSettingsView: View {
    @Binding var httpModule: HTTPModule
    @Binding var appData: AppData
    @State var localApiURL: String = ""
    @State var localDataURL: String = ""
    @State var isAlertPresented: Bool = false
    @State var isAlert2Presented: Bool = false
    var body: some View {
        List {
            Section("App") {
                TextField("API URL", text: $localApiURL)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                Button("Update") {
                    isAlertPresented.toggle()
                }
                .disabled($appData.apiURL.wrappedValue == $localApiURL.wrappedValue)
                TextField("DATA URL", text: $localDataURL)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                Button("Update") {
                    isAlert2Presented.toggle()
                }
                .disabled($appData.dataURL.wrappedValue == $localDataURL.wrappedValue)
            }
            Section("User") {
                Text($appData.userToken.wrappedValue ?? "No Token")
                if $appData.userToken.wrappedValue != nil {
                    Button("Copy Token") {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = $appData.userToken.wrappedValue ?? ""
                    }
                }
            }
        }
        .navigationTitle("Developer Settings")
        .onAppear {
            localApiURL = $appData.apiURL.wrappedValue
            localDataURL = $appData.dataURL.wrappedValue
        }
        .alert("You really wanna do that??", isPresented: $isAlertPresented) {
            if $appData.apiURL.wrappedValue == "https://skilllinkr.micstudios.de/api" {
                Button("No I want to be good", role: .cancel) {
                    localApiURL = $appData.apiURL.wrappedValue
                    isAlertPresented.toggle()
                }
                Button("Yes I am a villain", role: .destructive) {
                    appData.apiURL = $localApiURL.wrappedValue
                    isAlertPresented.toggle()
                }
            } else {
                Button("No I want to stay a villain", role: .cancel) {
                    localApiURL = $appData.apiURL.wrappedValue
                    isAlertPresented.toggle()
                }
                Button("Yes I want to go to the good side :)", role: .destructive) {
                    appData.apiURL = $localApiURL.wrappedValue
                    isAlertPresented.toggle()
                }
            }
        }
        .alert("You really wanna do that??", isPresented: $isAlert2Presented) {
            if $appData.dataURL.wrappedValue == "https://images.skilllinkr.micstudios.de/" {
                Button("No I want to be good", role: .cancel) {
                    localDataURL = $appData.dataURL.wrappedValue
                    isAlert2Presented.toggle()
                }
                Button("Yes I am weird and sure what I'm doing", role: .destructive) {
                    appData.dataURL = $localDataURL.wrappedValue
                    AppDataModule(appData: $appData).save()
                    isAlert2Presented.toggle()
                }
            } else {
                Button("No I want to stay weird", role: .cancel) {
                    localDataURL = $appData.dataURL.wrappedValue
                    isAlert2Presented.toggle()
                }
                Button("Yes I want to go to the good side :)", role: .destructive) {
                    appData.dataURL = $localDataURL.wrappedValue
                    AppDataModule(appData: $appData).save()
                    isAlert2Presented.toggle()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(httpModule: .constant(HTTPModule(settings: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de/", appSettings: AppSettings())), appDataModule: AppDataModule(appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de/", appSettings: AppSettings()))))), appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de/", appSettings: AppSettings())))
    }
}
