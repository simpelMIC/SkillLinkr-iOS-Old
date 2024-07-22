//
//  ZD2Management.swift
//  SkillLinkr
//
//  Created by Christian on 21.07.24.
//

import Foundation
import SwiftUI

//Parent-View of whole App
struct ZD2Management: View {
    @Binding var zd2Data: ZD2Data
    @State var dataLoaded: Bool = false
    @State var isAlertPresented: Bool = false
    @State var error: String?
    var body: some View {
        VStack {
            if zd2Data.appUser.loggedIn {
                if dataLoaded {
                    ZD2TabView(zd2Data: $zd2Data)
                        .onAppear {
                            getUserData()
                        }
                } else {
                    Text("Fetching user details...")
                    //Load user on apper
                        .onAppear {
                            getUserData()
                        }
                }
            } else {
                ZD2Onboarding(zd2Data: $zd2Data)
            }
        }
        .alert(isPresented: $isAlertPresented, content: {
            Alert(
            title: Text("Log in failed"),
            message: Text(error ?? ""),
            primaryButton: .default(Text("Retry"), action: {
                isAlertPresented = false
                getUserData()
            }),
            secondaryButton: .destructive(Text("Log Out"), action: {
                isAlertPresented = false
                logOut()
            })
            )
        })
    }
    
    public func getUserData() {
        HTTPSModule().getUser($zd2Data.appUser.user.user.wrappedValue, zd2Data: $zd2Data.wrappedValue) { result in
            switch result {
            case .success(let response):
                zd2Data.appUser.user.user = response.message
                print("Logged in as \(response.message.firstname)")
                zd2Data.appUser.verifiedLogIn = true
                dataLoaded = true
            case .failure(let error):
                isAlertPresented = true
                dataLoaded = false
                self.error = error.localizedDescription
            }
        }
    }
    
    public func logOut() {
        dataLoaded = false
        zd2Data.appUser.loggedIn = false
        zd2Data.appUser.verifiedLogIn = false
        zd2Data.appUser.userToken = ""
        ZD2DataModule().save($zd2Data.wrappedValue)
    }
    
    public func patchUser(_ user: Binding<ZD2User>) {
        print("Starting to patch user data...")
        patchUserData(user.user.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("User has been patched successfully: \(response.status)")
                
            case .failure(let error):
                print("User couldn't be patched: \(error.localizedDescription)")
            }
        }
        patchUserSocialmedia(user.socialmedia.wrappedValue, userId: user.user.id.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("User Socialmedia has been patched successfully: \(response.status)")
                
            case .failure(let error):
                print("User Socialmedia couldn't be patched: \(error.localizedDescription)")
            }
        }
        patchUserTeachingInformation(user.teachingInformation.wrappedValue, userId: user.user.id.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("User Teachinginformation has been patched successfully: \(response.status)")
            case .failure(let error):
                print("User Teachinginformation couldn't be patched: \(error.localizedDescription)")
            }
        }
    }

    public func patchUserData(_ user: User, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        print("Calling patchUserData...")
        let module = HTTPSModule()
        module.patchUser(zd2Data: $zd2Data.wrappedValue, patchUserId: user.id) { result in
            switch result {
            case .success(let response):
                print("patchUserData success: \(response)")
                completion(.success(response))
            case .failure(let error):
                print("patchUserData failure: \(error)")
                completion(.failure(error))
            }
        }
    }

    public func patchUserSocialmedia(_ socialmedia: Socialmedia, userId: String, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        print("Calling patchUserSocialmedia...")
        let module = HTTPSModule()
        module.patchSocialmedia(zd2Data: $zd2Data.wrappedValue, patchUserId: userId, xName: socialmedia.xName, instagramName: socialmedia.instagramName, discordName: socialmedia.discordName, facebookName: socialmedia.facebookName) { result in
            switch result {
            case .success(let response):
                print("patchUserSocialmedia success: \(response)")
                completion(.success(response))
            case .failure(let error):
                print("patchUserSocialmedia failure: \(error)")
                completion(.failure(error))
            }
        }
    }

    public func patchUserTeachingInformation(_ teachingInformation: Teachinginformation, userId: String, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        print("Calling patchUserTeachingInformation...")
        let module = HTTPSModule()
        module.patchTeachingInformation(zd2Data: $zd2Data.wrappedValue, patchUserId: userId, teachesOnline: teachingInformation.teachesOnline, teachesInPerson: teachingInformation.teachesInPerson, teachingCity: teachingInformation.teachingCity, teachingCountry: teachingInformation.teachingCountry) { result in
            switch result {
            case .success(let response):
                print("patchUserTeachingInformation success: \(response)")
                completion(.success(response))
            case .failure(let error):
                print("patchUserTeachingInformation failure: \(error)")
                completion(.failure(error))
            }
        }
    }
}

#Preview {
    ZD2Management(zd2Data: .constant(defaultZD2Data))
}
