//
//  ZD2Messenger.swift
//  SkillLinkr
//
//  Created by Christian on 22.07.24.
//

import Foundation
import SwiftUI

struct ZD2Messenger: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        List {
            NavigationLink {
                
            } label: {
                SingleMessageView(user: dummyZD2User)
            }
        }
        .navigationTitle("Messages")
        .refreshable {
            
        }
    }
}

struct SingleMessageView: View {
    var user: ZD2User
    let imageSize: CGFloat = 50
    var body: some View {
        HStack {
            Image("userIcon")
                .resizable()
                .frame(width: imageSize, height: imageSize)
            VStack(alignment: .leading) {
                Text("\(user.user.firstname) \(user.user.lastname)")
                    .font(.headline)
                    .frame(width: 250, height: 15, alignment: .topLeading)
                Text("You: Hello")
                    .font(.subheadline)
                    .frame(width: 250, height: 40, alignment: .topLeading)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ZD2Messenger(zd2Data: .constant(dummyZD2Data))
    }
}
