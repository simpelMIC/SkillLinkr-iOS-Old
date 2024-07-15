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
        if $settings.userToken.wrappedValue == nil || $settings.userToken.wrappedValue == "" {
            OnboardingView(httpModule: $httpModule, settings: $settings)
        } else {
            AppView(httpModule: $httpModule, settings: $settings)
                .onAppear {
                    httpModule.getUserRelease { result in
                        switch result {
                        case .success(let userReleaseResponse):
                            if userReleaseResponse.status == "success" {
                                settings.user = User(id: "", firstname: "", lastname: "", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
                            } else {
                                settings.user = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
                            }
                        case .failure(let error):
                            print("Failed to validate account access: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}

struct AppView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        if settings.user?.released ?? false == true {
            TabView {
                NavigationStack {
                    FeedView(httpModule: $httpModule, settings: $settings)
                }
                .tabItem {
                    Image(systemName: "square.stack.fill")
                    Text("Feed")
                }
                NavigationStack {
                    ProfileView(httpModule: $httpModule, settings: $settings)
                }
                .tabItem {
                    Image(systemName: "person")
                    Text("My Profile")
                }
                NavigationStack {
                    SettingsView(httpModule: $httpModule, settings: $settings)
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }
        } else {
            VStack {
            Text("This account is not released")
                .font(.title)
                HStack {
                    Button("Log Out", role: .destructive) {
                        settings.userToken = nil
                        AppDataModule(settings: $settings).save()
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Retry") {
                        httpModule.getUserRelease { result in
                            switch result {
                            case .success(let userReleaseResponse):
                                if userReleaseResponse.status == "success" {
                                    settings.user = User(id: "", firstname: "", lastname: "", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
                                } else {
                                    settings.user = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
                                }
                            case .failure(let error):
                                print("Failed to validate account access: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
