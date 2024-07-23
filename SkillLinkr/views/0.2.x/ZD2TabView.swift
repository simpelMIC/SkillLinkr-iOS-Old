//
//  ZD2TabView.swift
//  SkillLinkr
//
//  Created by Christian on 22.07.24.
//

import Foundation
import SwiftUI

struct ZD2TabView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        TabView {
            NavigationStack {
                ZD2FeedView(zd2Data: $zd2Data)
            }
            .tabItem {
                Image(systemName: "square.stack.fill")
                Text("Feed")
            }
            
            NavigationStack {
                ZD2Messenger(zd2Data: $zd2Data)
            }
            .tabItem {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Messages")
            }
            
            NavigationStack {
                ZD2AppUserView(zd2Data: $zd2Data)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("My Account")
            }
        }
    }
}

#Preview {
    ZD2TabView(zd2Data: .constant(dummyZD2Data))
}
