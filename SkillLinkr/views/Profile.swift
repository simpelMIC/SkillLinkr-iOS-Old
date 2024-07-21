//
//  profileView.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct ProfileView: View {
    @Binding var httpModule: HTTPModule
    @Binding var appData: AppData
    @State var isSheetPresented: Bool = false
    @State var id = UUID()
    var body: some View {
        if $appData.user.wrappedValue == nil {
            Text("Fetching user data...")
        } else {
            ScrollView {
                VStack {
                    CachedAsyncImage(url: URL(string: "\(appData.dataURL)/uploads/\(appData.user?.id ?? "")_profileImage.jpg")!, content: {_ in
                        AsyncImage(url: URL(string: "\(appData.dataURL)/uploads/\(appData.user?.id ?? "")_profileImage.jpg")!)
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .clipped()
                            .id(id)
                    }, placeholder: {
                        Image("userIcon")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 350)
                            .clipped()
                    })
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 350)
                    .clipped()
                    .id(id)
                    Text($appData.user.wrappedValue?.firstname ?? "Fetching user data...")
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
                id = UUID()
            }
            .sheet(isPresented: $isSheetPresented, content: {
                PatchProfileView(httpModule: $httpModule, appData: $appData, navigationBarTitleMode: .inline) {
                    isSheetPresented.toggle()
                    getUser()
                    id = UUID()
                }
            })
        }
    }
    
    func getUser() {
        httpModule.getUser { result in
            switch result {
            case .success(let userResponse):
                print("User details fetched successfully!")
                appData.user = User(id: userResponse.message.id, firstname: userResponse.message.firstname, lastname: userResponse.message.lastname, mail: userResponse.message.mail, released: userResponse.message.released, role: userResponse.message.role, updatedAt: userResponse.message.updatedAt, createdAt: userResponse.message.createdAt)
            case .failure(let error):
                print("Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(httpModule: .constant(HTTPModule(settings: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de/upload", appSettings: AppSettings())), appDataModule: AppDataModule(appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de/upload", appSettings: AppSettings()))))), appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de/upload", user: User(id: "clylut6xg0007s9menwvunl5i", firstname: "Thorsten", lastname: "Schmidt", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), appSettings: AppSettings())))
    }
}

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
