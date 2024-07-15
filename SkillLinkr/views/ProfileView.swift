//
//  profileView.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    @State var isSheetPresented: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: ""))
                Text($settings.user.wrappedValue?.firstname ?? "Fetching user data...")
                    .font(.title)
            }
        }
        .navigationTitle("My Profile")
        .toolbar {
            Button {
                isSheetPresented.toggle()
            } label: {
                Image(systemName: "pencil")
            }
        }
        .task {
            getUser()
        }
        .sheet(isPresented: $isSheetPresented, content: {
            PatchUserView(httpModule: $httpModule, settings: $settings) {
                isSheetPresented.toggle()
                getUser()
            }
        })
    }
    
    func getUser() {
        httpModule.getUser { result in
            switch result {
            case .success(let userResponse):
                print("User details fetched successfully!")
                settings.user = User(id: userResponse.message.id, firstname: userResponse.message.firstname, lastname: userResponse.message.lastname, mail: userResponse.message.mail, released: userResponse.message.released, role: userResponse.message.role, updatedAt: userResponse.message.updatedAt, createdAt: userResponse.message.createdAt)
            case .failure(let error):
                print("Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }
}

struct PatchUserView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    @State var localUser: User = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
    @State var message: String = ""
    var onSave: () -> Void
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("Firstname", text: $localUser.firstname)
                    TextField("Lastname", text: $localUser.lastname)
                }
                .padding(20)
            }
            .navigationTitle("Profile Settings")
            .toolbar {
                Button("Save") {
                    updateUser()
                    onSave()
                }
            }
        }
        .onAppear {
            localUser = $settings.user.wrappedValue ?? User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
        }
        .onDisappear {
            localUser = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
            getUser()
        }
    }
    
    func updateUser() {
            httpModule.patchUser(
                token: $settings.userToken.wrappedValue ?? "",
                patchUserId: $localUser.id.wrappedValue,
                mail: $localUser.mail.wrappedValue,
                firstname: $localUser.firstname.wrappedValue,
                lastname: $localUser.lastname.wrappedValue
            ) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        message = response.message
                        print("User has been patched successfully")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        message = "Failed to update user: \(error.localizedDescription)"
                        print("Failed to patch user: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    func getUser() {
        httpModule.getUser { result in
            switch result {
            case .success(let userResponse):
                print("User details fetched successfully!")
                settings.user = User(id: userResponse.message.id, firstname: userResponse.message.firstname, lastname: userResponse.message.lastname, mail: userResponse.message.mail, released: userResponse.message.released, role: userResponse.message.role, updatedAt: userResponse.message.updatedAt, createdAt: userResponse.message.createdAt)
            case .failure(let error):
                print("Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(httpModule: .constant(HTTPModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", userToken: "")), appDataModule: AppDataModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api"))))), settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api")))
    }
}
