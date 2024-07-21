//
//  ContentView.swift
//  SkillLinkr
//
//  Created by Christian on 13.07.24.
//

import SwiftUI

struct MainView: View {
    @State var appData: AppData = AppData(apiURL: "https://skilllinkr.micstudios.de/api", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache())
    var body: some View {
        if appData.appSettings.layoutVersion == .zD1 {
            ContentView(httpModule: HTTPModule(settings: $appData, appDataModule: AppDataModule(appData: $appData)), appData: $appData)
                .task {
                    await AppDataModule(appData: $appData).load()
                }
                .onDisappear {
                    Task {
                        await AppDataModule(appData: $appData).save()
                    }
                }
        } else if appData.appSettings.layoutVersion == .zD2 {
            ZD2Management()
        } else {
            ChooseLayoutVersionView(appData: $appData)
        }
    }
}

struct ChooseLayoutVersionView: View {
    @Binding var appData: AppData
    var body: some View {
        Text("Choose a Layout Version")
            .font(.largeTitle)
            .foregroundStyle(.accent)
        HStack {
            Button("ZD1") {
                appData.appSettings.layoutVersion = .zD1
                Task {
                    await AppDataModule(appData: $appData).save()
                }
            }
            .padding()
            Button("ZD2") {
                appData.appSettings.layoutVersion = .zD2
                Task {
                    await AppDataModule(appData: $appData).save()
                }
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @State var httpModule: HTTPModule
    @Binding var appData: AppData
    var body: some View {
        if $appData.userToken.wrappedValue == nil || $appData.userToken.wrappedValue == "" {
            OnboardingView(httpModule: $httpModule, appData: $appData)
        } else {
            AppView(httpModule: $httpModule, appData: $appData)
                .onAppear {
                    httpModule.getUserRelease { result in
                        switch result {
                        case .success(let userReleaseResponse):
                            if userReleaseResponse.status == "success" {
                                appData.user = User(id: "", firstname: "", lastname: "", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
                            } else {
                                appData.user = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
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
    @Binding var appData: AppData
    var body: some View {
        if appData.user?.released ?? false == true {
            TabView {
                NavigationStack {
                    FeedView(httpModule: $httpModule, appData: $appData)
                }
                .tabItem {
                    Image(systemName: "square.stack.fill")
                    Text("Feed")
                }
                NavigationStack {
                    ProfileView(httpModule: $httpModule, appData: $appData)
                }
                .tabItem {
                    Image(systemName: "person")
                    Text("My Profile")
                }
                NavigationStack {
                    SettingsView(httpModule: $httpModule, appData: $appData)
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
                        appData.userToken = nil
                        Task {
                            await AppDataModule(appData: $appData).save()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Retry") {
                        httpModule.getUserRelease { result in
                            switch result {
                            case .success(let userReleaseResponse):
                                if userReleaseResponse.status == "success" {
                                    appData.user = User(id: "", firstname: "", lastname: "", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
                                } else {
                                    appData.user = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
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
