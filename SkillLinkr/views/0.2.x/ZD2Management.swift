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
    //Default ZD2Data
    @State var zd2Data: ZD2Data = ZD2Data(settings: ZD2Settings(apiURL: URL(string: "https://skilllinkr.micstudios.de/api")!, showFeedActionButtons: false), appUser: AppUser(userToken: "", loggedIn: false, verifiedLogIn: false, user: ZD2User(user: User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""), socialmedia: Socialmedia(id: 0, userId: "", updatedAt: "", createdAt: ""), teachingInformation: Teachinginformation(id: 0, userId: "", teachesInPerson: false, teachesOnline: false, updatedAt: "", createdAt: ""))), cache: ZD2Cache(users: [], skillCategories: [], skills: []), zd1Data: AppData(apiURL: "https://skilllinkr.micstudios.de/api", dataURL: "https://images.skilllinkr.micstudios.de", appSettings: AppSettings(), cache: AppCache()))
    @State var dataLoaded: Bool = false
    var body: some View {
        VStack {
            
        }
        .task {
            ZD2DataModule().load { data in
                //Set ZD2Data to (from UserDefaults) loaded data
                //Fallback default Data is loaded if an error occurs
                zd2Data = data ?? zd2Data
            }
        }
    }
}
