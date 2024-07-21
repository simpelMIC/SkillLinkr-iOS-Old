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
    var body: some View {
        UserView(httpModule: $httpModule, appData: $appData, user: $appData.user.wrappedValue ?? User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""))
            .navigationTitle("My Profile")
            .toolbar {
                Button {
                    isSheetPresented.toggle()
                } label: {
                    Image(systemName: "pencil")
                }
            }
            .sheet(isPresented: $isSheetPresented, content: {
                PatchProfileView(httpModule: $httpModule, appData: $appData, navigationBarTitleMode: .inline) {
                    isSheetPresented.toggle()
                }
            })
    }
    
    func getUser() {
        httpModule.getUser(appData.user ?? User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")) { result in
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

struct UserView: View {
    @Binding var httpModule: HTTPModule
    @Binding var appData: AppData
    @State var user: User
    @State var isSheetPresented: Bool = false
    @State var id = UUID()
    var body: some View {
        if $appData.user.wrappedValue == nil {
            Text("Fetching user data...")
        } else {
            ScrollView {
                VStack {
                    HStack {
                        AsyncImage(url: httpModule.getImageURL(owner: user, key: "profileImage")) { result in
                            if result.image == nil {
                                if appData.appSettings.profileImageCache != nil {
                                    Image(uiImage: UIImage(data: appData.appSettings.profileImageCache!)!)
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
                                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                                } else {
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
                                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
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
                                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                                    .onAppear {
                                        appData.appSettings.profileImageCache = result.image?.jpgData(compressionQuality: 1)
                                        Task {
                                            await AppDataModule(appData: $appData).save()
                                        }
                                    }
                            }
                        }
                        .id(id)
                        VStack(alignment: .leading) {
                            Text(user.firstname)
                                .font(.system(.title, weight: .semibold))
                            Text(user.lastname)
                        }
                        .padding()
                    }.padding()
                }
            }
            .task {
                refreshData(.texts)
            }
            .refreshable {
                refreshData(.all)
            }
        }
    }
    
    func refreshData(_ contentToRefresh: ContentToRefresh) {
        if contentToRefresh == .texts {
            getUser()
        } else if contentToRefresh == .images {
            id = UUID()
        } else {
            id = UUID()
            getUser()
        }
    }
    
    func getUser() {
        httpModule.getUser(user) { result in
            switch result {
            case .success(let userResponse):
                print("User details fetched successfully!")
                user = User(id: userResponse.message.id, firstname: userResponse.message.firstname, lastname: userResponse.message.lastname, mail: userResponse.message.mail, released: userResponse.message.released, role: userResponse.message.role, updatedAt: userResponse.message.updatedAt, createdAt: userResponse.message.createdAt)
            case .failure(let error):
                print("Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }
    
    enum ContentToRefresh {
        case texts
        case images
        case all
    }
}

#Preview {
    NavigationStack {
        ProfileView(httpModule: .constant(HTTPModule(settings: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache())), appDataModule: AppDataModule(appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache()))))), appData: .constant(AppData(apiURL: "", dataURL: "https://images.skilllinkr.micstudios.de", user: User(id: "", firstname: "Thorsten", lastname: "Schmidt", mail: "", released: true, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), appSettings: AppSettings(), cache: AppCache())))
    }
}
