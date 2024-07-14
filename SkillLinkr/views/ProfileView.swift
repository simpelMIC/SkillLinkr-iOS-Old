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
    var body: some View {
        VStack {
            Text(settings.userToken ?? "No Token")
        }
        .navigationTitle(settings.user?.firstname ?? "Johannes")
        .onAppear {
            httpModule.getUser { result in
                switch result {
                case .success(let userResponse):
                    print("User details fetched successfully!")
                    settings.user?.firstname = userResponse.message.firstname
                    settings.user?.lastname = userResponse.message.lastname
                    settings.user?.mail = userResponse.message.mail
                    settings.user?.released = userResponse.message.released
                    settings.user?.role = userResponse.message.role
                case .failure(let error):
                    print("Failed to fetch user details: \(error.localizedDescription)")
                }
            }
        }
    }
}
