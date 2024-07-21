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
    var body: some View {
        VStack {
            if zd2Data.appUser.loggedIn {
                if zd2Data.appUser.verifiedLogIn {
                    //ZD2View
                } else {
                    //Log in the user
                    //If error -> Go to login Screen
                }
            } else {
                OnboardingZD2(zd2Data: $zd2Data)
            }
        }
    }
}
