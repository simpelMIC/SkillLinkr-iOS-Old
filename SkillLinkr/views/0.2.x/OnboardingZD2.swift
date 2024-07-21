//
//  OnboardingZD2.swift
//  SkillLinkr
//
//  Created by Christian on 21.07.24.
//

import Foundation
import SwiftUI

struct OnboardingZD2: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        ZStack {
            
        }
    }
}

struct ZD2LoginView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        Text("Login")
    }
}

struct ZD2NewAccountView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        Text("New Account")
    }
}

struct FailedLoginView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        VStack {
            Text("Login failed.")
                .font(.largeTitle)
                .foregroundStyle(.accent)
            HStack {
                Button("Log Out") {
                    zd2Data.appUser.loggedIn = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
                Button("Retry") {
                    
                }
                .padding()
            }
        }
    }
}
