//
//  ContentView.swift
//  SkillLinkr
//
//  Created by Christian on 13.07.24.
//

import SwiftUI

struct MainView: View {
    @State var settings: AppSettings = AppSettings(apiURL: "https://skilllinkr.micstudios.de/api")
    var body: some View {
        ContentView(httpModule: HTTPModule(settings: $settings, appDataModule: AppDataModule(settings: $settings)), settings: $settings)
            .task {
                AppDataModule(settings: $settings).load()
            }
    }
}

struct ContentView: View {
    @State var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        if settings.userToken == nil {
            OnboardingView(httpModule: $httpModule, settings: $settings)
        } else {
            Text("Logged in")
            Button("Log out") {
                settings.userToken = nil
            }
        }
    }
    
    func register() {
        // Example usage for register:
        httpModule.register(mail: "example1@mail.com", firstname: "John", lastname: "Doe", password: "password123", passwordConfirm: "password123") { result in
            switch result {
            case .success(let registerResponse):
                print("Registration successful! Token: \(registerResponse.message.token)")
            case .failure(let error):
                print("Registration failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    MainView()
}
