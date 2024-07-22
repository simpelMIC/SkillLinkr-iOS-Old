//
//  ZD2Settings.swift
//  SkillLinkr
//
//  Created by Christian on 22.07.24.
//

import Foundation
import SwiftUI

struct ZD2SettingsView: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        List {
            Section("Your Account") {
                NavigationLink("Edit Profile") {
                    ZD2EditProfileView(zd2Data: $zd2Data)
                }
                Button("Log Out", role: .destructive) {
                    ZD2Management(zd2Data: $zd2Data).logOut()
                }
            }
            Section("How you use SkillLinkr") {
                NavigationLink("Notifications") {
                    
                }
                NavigationLink("Time spent") {
                    
                }
            }
            Section("What you see") {
                NavigationLink("Favorites") {
                    
                }
            }
            Section("Who can see your content") {
                NavigationLink("Account Privacy") {
                    
                }
                NavigationLink("Blocked") {
                    
                }
            }
            Section("How others can interact with you") {
                NavigationLink("Restricted Accounts") {
                    
                }
                NavigationLink("Follow and invite Friends") {
                    
                }
            }
            Section("Your app and media") {
                NavigationLink("Device permissions") {
                    
                }
                NavigationLink("Archiving and Downloading") {
                    
                }
                NavigationLink("Accessibility") {
                    
                }
                NavigationLink("Media quality") {
                    
                }
                NavigationLink("Website permissions") {
                    
                }
            }
            Section("More info and support") {
                NavigationLink("Help") {
                    
                }
                NavigationLink("Account Status") {
                    
                }
                NavigationLink("Developer Settings") {
                    
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        ZD2SettingsView(zd2Data: .constant(dummyZD2Data))
    }
}
