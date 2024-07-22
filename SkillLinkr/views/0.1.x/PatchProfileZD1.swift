//
//  PatchProfile.swift
//  SkillLinkr
//
//  Created by Christian on 20.07.24.
//

import Foundation
import SwiftUI
import PhotosUI

struct PatchProfileView: View {
    enum NavigationBarTitleMode {
        case large
        case inline
    }
    
    @Binding var httpModule: HTTPModule
    @Binding var appData: AppData
    @State var localUser: User = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
    @State var message: String = ""
    @State var navigationBarTitleMode: NavigationBarTitleMode
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var onSave: () -> Void
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    if selectedImageData == nil {
                        AsyncImage(url: httpModule.getImageURL(owner: localUser, key: "profileImage")) { result in
                            if result.image == nil {
                                Image("userIcon")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 140, height: 140)
                                    .clipped()
                                    .mask {
                                        Circle()
                                    }
                                    .overlay {
                                        Circle()
                                            .stroke(.primary, lineWidth: 1)
                                    }
                            } else {
                                result.image?
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 140, height: 140)
                                    .clipped()
                                    .mask {
                                        Circle()
                                    }
                                    .overlay {
                                        Circle()
                                            .stroke(.primary, lineWidth: 1)
                                    }
                            }
                        }
                    } else {
                        Image(uiImage: UIImage(data: selectedImageData!)!)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 140)
                            .clipped()
                            .mask {
                                Circle()
                            }
                            .overlay {
                                Circle()
                                    .stroke(.primary, lineWidth: 1)
                            }
                    }
                    PhotosPicker("Edit Profile Image", selection: $selectedItem, matching: .images)
                        .onChange(of: selectedItem) {
                            Task {
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                        .padding()
                }
                TextField("Firstname", text: $localUser.firstname)
                TextField("Lastname", text: $localUser.lastname)
            }
            .navigationTitle("Profile Settings")
            .toolbar {
                Button("Save") {
                    updateUser()
                    onSave()
                }
            }
            .navigationBarTitleDisplayMode(navigationBarTitleMode == .inline ? .inline : .large)
        }
        .onAppear {
            getUser()
        }
        .onDisappear {
            localUser = User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
            getUser()
        }
    }
    
    func updateUser() {
        httpModule.patchUser(
            token: $appData.userToken.wrappedValue ?? "",
            patchUserId: $localUser.id.wrappedValue,
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
                    let alert = UIAlertController(title: "Failed to update user", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = scene.windows.first?.rootViewController {
                        rootViewController.present(alert, animated: true, completion: nil)
                    }
                    print("Failed to patch user: \(error.localizedDescription)")
                }
            }
        }
        if selectedImageData != nil {
            if let image = UIImage(data: selectedImageData!) {
                httpModule.uploadImage(image, url: URL(string: $appData.dataURL.wrappedValue)!, owner: $appData.user.wrappedValue ?? User(id: "noOwner", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), key: "profileImage")
            }
        }
    }
    
    func getUser() {
        httpModule.getUser(appData.user ?? User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")) { result in
            switch result {
            case .success(let userResponse):
                print("User details fetched successfully!")
                appData.user = User(id: userResponse.message.id, firstname: userResponse.message.firstname, lastname: userResponse.message.lastname, mail: userResponse.message.mail, released: userResponse.message.released, role: userResponse.message.role, updatedAt: userResponse.message.updatedAt, createdAt: userResponse.message.createdAt)
                localUser = User(id: userResponse.message.id, firstname: userResponse.message.firstname, lastname: userResponse.message.lastname, mail: userResponse.message.mail, released: userResponse.message.released, role: userResponse.message.role, updatedAt: userResponse.message.updatedAt, createdAt: userResponse.message.createdAt)
            case .failure(let error):
                print("Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PatchProfileView(httpModule: .constant(HTTPModule(settings: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache())), appDataModule: AppDataModule(appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache()))))), appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", user: User(id: "", firstname: "Thorsten", lastname: "Schmidt", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), appSettings: AppSettings(), cache: AppCache())), navigationBarTitleMode: .large) {
        }
    }
}
