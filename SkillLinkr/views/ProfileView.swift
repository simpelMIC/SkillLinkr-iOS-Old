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
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: ""))
                Text($settings.user.wrappedValue?.firstname ?? "Fetching user data...")
                    .font(.title)
            }
        }
        .navigationTitle("My Profile")
        .onAppear {
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
}
