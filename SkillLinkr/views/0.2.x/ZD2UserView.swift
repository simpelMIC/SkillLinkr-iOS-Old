//
//  ZD2UserView.swift
//  SkillLinkr
//
//  Created by Christian on 22.07.24.
//

import Foundation
import SwiftUI

struct ZD2UserView: View {
    @Binding var zd2Data: ZD2Data
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
            ZD2Management(zd2Data: $zd2Data).getUser(user) { result in
                switch result {
                case .success(((let userData, let socialmedia, let teachingInformation, let userSkills))):
                    user = ZD2User(user: userData ?? user.user, socialmedia: socialmedia ?? user.socialmedia, teachingInformation: teachingInformation ?? user.teachingInformation, skills: userSkills ?? user.skills)
                case .failure(let error):
                    print("Failed to get User: \(error)")
                }
            }
        }
        .onAppear {
            ZD2Management(zd2Data: $zd2Data).getUser(user) { result in
                switch result {
                case .success(((let userData, let socialmedia, let teachingInformation, let userSkills))):
                    user = ZD2User(user: userData ?? user.user, socialmedia: socialmedia ?? user.socialmedia, teachingInformation: teachingInformation ?? user.teachingInformation, skills: userSkills ?? user.skills)
                case .failure(let error):
                    print("Failed to get User: \(error)")
                }
            }
        }
    }
}

struct ZD2AppUserView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        ZD2UserView(zd2Data: $zd2Data, user: $zd2Data.appUser.user.wrappedValue)
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
    @State var localUser: ZD2User = defaultUser
    var body: some View {
        List {
            Section("General information") {
                TextField("Firstname", text: $localUser.user.firstname)
                    .textInputAutocapitalization(.words)
                TextField("Lastname", text: $localUser.user.lastname)
                    .textInputAutocapitalization(.words)
            }
            Section("Socialmedia Links") {
                OptionalTextField("X (Name)", text: $localUser.socialmedia.xName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                OptionalTextField("Discord (Name)", text: $localUser.socialmedia.discordName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                OptionalTextField("Instagram (Name)", text: $localUser.socialmedia.instagramName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                OptionalTextField("FaceBook (Name)", text: $localUser.socialmedia.facebookName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            Section("Teaching info") {
                Toggle("I teach in person", isOn: $localUser.teachingInformation.teachesInPerson)
                    .toggleStyle(iOSCheckbox())
                    .foregroundStyle(.primary)
                Toggle("I teach online", isOn: $localUser.teachingInformation.teachesOnline)
                    .toggleStyle(iOSCheckbox())
                    .foregroundStyle(.primary)
                VStack(alignment: .leading) {
                    Text("Country: \(Locale.current.localizedString(forRegionCode: localUser.teachingInformation.teachingCountry ?? "") ?? "")")
                    OptionalCountryPicker(selectedCountry: $localUser.teachingInformation.teachingCountry)
                }
            }
            Button("Save changes") {
                save()
            }
        }
        .task {
            ZD2Management(zd2Data: $zd2Data).getAppUser()
            localUser = zd2Data.appUser.user
        }
        .onDisappear {
            ZD2Management(zd2Data: $zd2Data).getAppUser()
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
    if true {
        if false {
            ZD2UserView(zd2Data: .constant(dummyZD2Data), user: ZD2User(user: User(id: "1", firstname: "Test1", lastname: "Testmann1", mail: "test@testmann.com", released: true, role: UserRole(id: 0, name: "User", description: "User", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), socialmedia: Socialmedia(id: 0, userId: "1", updatedAt: "", createdAt: ""), teachingInformation: Teachinginformation(id: 0, userId: "1", teachesInPerson: true, teachesOnline: true, updatedAt: "", createdAt: ""), skills: []))
        } else {
            NavigationStack {
                ZD2AppUserView(zd2Data: .constant(dummyZD2Data))
            }
        }
    } else {
        ZD2EditProfileView(zd2Data: .constant(dummyZD2Data))
    }
}
