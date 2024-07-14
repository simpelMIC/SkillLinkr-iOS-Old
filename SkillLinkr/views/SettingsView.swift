//
//  settings.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        List {
            Button("Logout") {
                settings.userToken = nil
                AppDataModule(settings: $settings).save()
            }
        }
        .navigationTitle("Settings")
    }
}
