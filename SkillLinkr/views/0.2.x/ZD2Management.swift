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
                            getAppUser()
                        }
                } else {
                    Text("Fetching user details...")
                    //Load user on appear
                        .onAppear {
                            getAppUser()
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
                getAppUser()
            }),
            secondaryButton: .destructive(Text("Log Out"), action: {
                isAlertPresented = false
                logOut()
            })
            )
        })
    }
    
    public func logOut() {
        dataLoaded = false
        zd2Data.appUser.loggedIn = false
        zd2Data.appUser.verifiedLogIn = false
        zd2Data.appUser.userToken = ""
        ZD2DataModule().save($zd2Data.wrappedValue)
    }
    
    public func getAppUser() {
        print("Fetching appUser...")
        getUser(zd2Data.appUser.user) { result in
            switch result {
            case .success((let user, let socialmedia, let teachingInformation, let userSkills)):
                if user != nil {
                    zd2Data.appUser.user.user = user!
                    zd2Data.appUser.verifiedLogIn = true
                    dataLoaded = true
                    print("Saved (GET) UserData")
                } else {
                    isAlertPresented = true
                    dataLoaded = false
                }
                if socialmedia != nil {
                    zd2Data.appUser.user.socialmedia = socialmedia!
                    print("Saved (GET) Socialmedia")
                }
                if teachingInformation != nil {
                    zd2Data.appUser.user.teachingInformation = teachingInformation!
                    print("Saved (GET) TeachingInformation")
                }
                if userSkills != nil {
                    zd2Data.appUser.user.skills = userSkills!
                    print("Saved (GET) UserSkills")
                }
            case .failure(let error):
                print("FAILED TO GET APP USER: \(error.localizedDescription)")
                self.error = error.localizedDescription
                dataLoaded = false
                isAlertPresented = true
            }
        }
    }

    public func getUser(_ user: ZD2User, completion: @escaping (Result<(User?, Socialmedia?, Teachinginformation?, [Skill]?), Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        // Variables to store the results
        var userData: User?
        var userDataError: Error?
        
        var socialMedia: Socialmedia?
        var socialmediaError: Error?
        
        var teachingInformation: Teachinginformation?
        var teachingInformationError: Error?
        
        var userSkills: [Skill]?
        var userSkillsError: Error?
        
        // Get user data
        dispatchGroup.enter()
        getUserData(user) { result in
            switch result {
            case .success(let response):
                userData = response
            case .failure(let error):
                self.error = error.localizedDescription
                userDataError = error
                break
            }
            dispatchGroup.leave()
        }
        
        // Get user social media
        dispatchGroup.enter()
        getUserSocialmedia(user) { result in
            switch result {
            case .success(let response):
                socialMedia = response
            case .failure(let error):
                socialmediaError = error
                break
            }
            dispatchGroup.leave()
        }
        
        // Get user teaching information
        dispatchGroup.enter()
        getUserTeachingInformation(user) { result in
            switch result {
            case .success(let response):
                teachingInformation = response
            case .failure(let error):
                teachingInformationError = error
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        getUserSkills(user) { result in
            switch result {
            case .success(let response):
                userSkills = response
            case .failure(let error):
                userSkillsError = error
                break
            }
            dispatchGroup.leave()
        }
        
        // Notify when all tasks are complete
        dispatchGroup.notify(queue: .main) {
            // Check if all necessary data is available
            if userData == nil || socialMedia == nil || teachingInformation == nil || userSkills == nil {
                // Handle the case where some of the data might be missing
                let missingDataError = NSError(domain: "de.micstudios", code: 0, userInfo: [NSLocalizedDescriptionKey: "userData: \(userDataError?.localizedDescription ?? ""), userSocialmedia: \(socialmediaError?.localizedDescription ?? ""), teachingInformation: \(teachingInformationError?.localizedDescription ?? ""), userSkills: \(userSkillsError?.localizedDescription ?? "")"])
                completion(.failure(missingDataError))
            } else {
                completion(.success((userData, socialMedia, teachingInformation, userSkills)))
            }
        }
    }


    
    private func getUserData(_ user: ZD2User, completion: @escaping (Result<User, Error>) -> Void) {
        print("Getting userData...")
        let module = HTTPSModule()
        module.getUser(user.user, zd2Data: $zd2Data.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("UserData fetched successfully: \(response.status)")
                completion(.success(response.message))
            case .failure(let error):
                print("Failed to fetch userData: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func getUserSocialmedia(_ user: ZD2User, completion: @escaping (Result <Socialmedia, Error>) -> Void) {
        print("Getting socialmedia...")
        let module = HTTPSModule()
        module.getSocialmedia(zd2Data: $zd2Data.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("Socialmedia fetched successfully: \(response.status)")
                completion(.success(response.message))
            case .failure(let error):
                print("Failed to fetch socialmedia: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func getUserTeachingInformation(_ user: ZD2User, completion: @escaping (Result <Teachinginformation, Error>) -> Void) {
        print("Gettings teachingInformation...")
        let module = HTTPSModule()
        module.getTeachingInformation(zd2Data: $zd2Data.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("Teachinginformation fetched successfully: \(response.status)")
                completion(.success(response.message))
            case .failure(let error):
                print("Failed to fetch Teachinginformation: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func getUserSkills(_ user: ZD2User, completion: @escaping (Result <[Skill], Error>) -> Void) {
        print("Getting userSkills...")
        let module = HTTPSModule()
        module.getUserSkills(user: user, zd2Data: $zd2Data.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("UserSkills fetched successfully: \(response.status)")
                completion(.success(response.message.skillsToTeach))
            case .failure(let error):
                print("Failed to fetch userSkills: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
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
        patchUserSkills(user.skills.wrappedValue, userId: user.user.id.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("Patched User Skills: \(response.status)")
            case .failure(let error):
                print("Failed to patch User Skills: \(error.localizedDescription)")
            }
        }
    }

    private func patchUserData(_ user: User, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        print("Calling patchUserData...")
        let module = HTTPSModule()
        module.patchUser(zd2Data: $zd2Data.wrappedValue, patchUserId: user.id, firstname: user.firstname, lastname: user.lastname) { result in
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

    private func patchUserSocialmedia(_ socialmedia: Socialmedia, userId: String, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
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

    private func patchUserTeachingInformation(_ teachingInformation: Teachinginformation, userId: String, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
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
    
    private func patchUserSkills(_ skills: [Skill], userId: String, completion: @escaping (Result<PatchResponse, Error>) -> Void) {
        print("Calling patchUserSkills...")
        let module = HTTPSModule()
        module.patchUserSkills(skills: skills, patchUserId: userId, zd2Data: $zd2Data.wrappedValue) { result in
            switch result {
            case .success(let response):
                print("patchUserSkills success: \(response)")
                completion(.success(response))
            case .failure(let error):
                print("patchUserSkills failure: \(error)")
                completion(.failure(error))
            }
        }
    }
}

#Preview {
    ZD2Management(zd2Data: .constant(defaultZD2Data))
}
