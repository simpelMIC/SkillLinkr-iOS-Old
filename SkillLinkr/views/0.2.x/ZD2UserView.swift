//
//  ZD2UserView.swift
//  SkillLinkr
//
//  Created by Christian on 22.07.24.
//

import Foundation
import SwiftUI

struct ZD2UserView: View {
    @State var user: ZD2User
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    HStack {
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
                            .padding()
                            .padding(.trailing)
                        VStack(alignment: .leading) {
                            Text(user.user.firstname)
                                .font(.system(.title, weight: .semibold))
                                .frame(width: 160, height: 30, alignment: .leading)
                                .clipped()
                            Text(user.user.lastname)
                                .frame(width: 140, height: 20, alignment: .leading)
                                .clipped()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
                .clipped()
            }
        }
        .refreshable {
            
        }
    }
}

struct ZD2AppUserView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        ZD2UserView(user: $zd2Data.appUser.user.wrappedValue)
            .navigationTitle("My Profile")
            .toolbar {
                Menu {
                    NavigationLink {
                        ZD2SettingsView(zd2Data: $zd2Data)
                    } label: {
                        Text("Settings")
                        Image(systemName: "gear")
                    }
                    NavigationLink {
                        ZD2EditProfileView(zd2Data: $zd2Data)
                    } label: {
                        Text("Edit Profile")
                        Image(systemName: "pencil")
                    }
                    Button(role: .destructive) {
                        ZD2Management(zd2Data: $zd2Data).logOut()
                    } label: {
                        Text("Log Out")
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
    }
}

struct ZD2EditProfileView: View {
    @Binding var zd2Data: ZD2Data
    @State var localUser: ZD2User = ZD2User(user: User(id: "1", firstname: "Test1", lastname: "Testmann1", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), socialmedia: Socialmedia(id: 0, userId: "1", updatedAt: "", createdAt: ""), teachingInformation: Teachinginformation(id: 0, userId: "1", teachesInPerson: true, teachesOnline: true, updatedAt: "", createdAt: ""))
    var body: some View {
        List {
            Section("General information") {
                TextField("Firstname", text: $localUser.user.firstname)
                TextField("Lastname", text: $localUser.user.lastname)
            }
            Section("Socialmedia Links") {
                OptionalTextField("X (Name)", text: $localUser.socialmedia.xName)
                OptionalTextField("Discord (Name)", text: $localUser.socialmedia.discordName)
                OptionalTextField("Instagram (Name)", text: $localUser.socialmedia.instagramName)
                OptionalTextField("FaceBook (Name)", text: $localUser.socialmedia.facebookName)
            }
            Section("Teaching info") {
                Toggle("I teach in person", isOn: $localUser.teachingInformation.teachesInPerson)
                Toggle("I teach online", isOn: $localUser.teachingInformation.teachesOnline)
                VStack(alignment: .leading) {
                    Text("Country: \(Locale.current.localizedString(forRegionCode: localUser.teachingInformation.teachingCountry ?? "") ?? "")")
                    OptionalCountryPicker(selectedCountry: $localUser.teachingInformation.teachingCountry)
                }
            }
            Button("Save changes") {
                save()
            }
        }
        .onAppear {
            ZD2Management(zd2Data: $zd2Data).getUserData()
            localUser = zd2Data.appUser.user
        }
        .navigationTitle("Edit My Profile")
        .toolbar {
            Button("Save") {
                save()
            }
        }
    }
    
    func save() {
        ZD2Management(zd2Data: $zd2Data).patchUser($localUser)
    }
}

#Preview {
    if false {
        if false {
            ZD2UserView(user: ZD2User(user: User(id: "1", firstname: "Test1", lastname: "Testmann1", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), socialmedia: Socialmedia(id: 0, userId: "1", updatedAt: "", createdAt: ""), teachingInformation: Teachinginformation(id: 0, userId: "1", teachesInPerson: true, teachesOnline: true, updatedAt: "", createdAt: "")))
        } else {
            NavigationStack {
                ZD2AppUserView(zd2Data: .constant(dummyZD2Data))
            }
        }
    } else {
        ZD2EditProfileView(zd2Data: .constant(dummyZD2Data))
    }
}
