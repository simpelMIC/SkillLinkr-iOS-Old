//
//  ContentView.swift
//  SkillLinkr
//
//  Created by Christian on 13.07.24.
//

import SwiftUI

struct MainView: View {
    //One of many default ZD1Data
    @State var appData: AppData = AppData(apiURL: "https://skilllinkr.micstudios.de/api", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache())
    //Default ZD2Data
    @State var zd2Data: ZD2Data = ZD2Data(settings: ZD2Settings(apiURL: URL(string: "https://skilllinkr.micstudios.de/api")!, showFeedActionButtons: false), appUser: AppUser(userToken: "", loggedIn: false, verifiedLogIn: false, user: ZD2User(user: User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), socialmedia: Socialmedia(id: 0, userId: "", updatedAt: "", createdAt: ""), teachingInformation: Teachinginformation(id: 0, userId: "", teachesInPerson: false, teachesOnline: false, updatedAt: "", createdAt: ""))), cache: ZD2Cache(users: [], skillCategories: [], skills: []))
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
            ZD2Management(zd2Data: $zd2Data)
                .task {
                    ZD2DataModule().load { data in
                        //Set ZD2Data to (from UserDefaults) loaded data
                        //Fallback default Data is loaded if an error occurs
                        zd2Data = data ?? zd2Data
                    }
                }
                .onDisappear {
                    ZD2DataModule().save($zd2Data.wrappedValue)
                }
        } else {
            ChooseLayoutVersionView(appData: $appData, zd2Data: $zd2Data)
        }
    }
}

//ZD1
struct ChooseLayoutVersionView: View {
    @Binding var appData: AppData
    @Binding var zd2Data: ZD2Data
    var body: some View {
        Text("Choose a Layout Version")
            .font(.largeTitle)
            .foregroundStyle(.accent)
        HStack {
            Button("ZD1") {
                appData.appSettings.layoutVersion = .zD1
                zd2Data.zd1Data?.appSettings.layoutVersion = .zD1
                Task {
                    await AppDataModule(appData: $appData).save()
                }
                ZD2DataModule().save($zd2Data.wrappedValue)
            }
            .padding()
            Button("ZD2") {
                appData.appSettings.layoutVersion = .zD2
                zd2Data.zd1Data?.appSettings.layoutVersion = .zD2
                Task {
                    await AppDataModule(appData: $appData).save()
                }
                ZD2DataModule().save($zd2Data.wrappedValue)
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
