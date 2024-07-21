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
            
        }
        .navigationTitle("Messages")
        .refreshable {
            
        }
    }
}

#Preview {
    NavigationStack {
        ZD2Messenger(zd2Data: .constant(dummyZD2Data))
    }
}
