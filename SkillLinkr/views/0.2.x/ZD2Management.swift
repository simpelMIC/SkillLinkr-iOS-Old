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
                if dataLoaded {
                    Text(zd2Data.appUser.user.user.firstname)
                } else {
                    Text("Fetching user details...")
                    //Load user on apper
                        .onAppear {
                            HTTPSModule().getUser($zd2Data.appUser.user.user.wrappedValue, zd2Data: $zd2Data.wrappedValue) { result in
                                switch result {
                                case .success(let response):
                                    zd2Data.appUser.user.user = response.message
                                    zd2Data.appUser.verifiedLogIn = true
                                    dataLoaded = true
                                case .failure(let error):
                                    //1. time error: Retry/Logout
                                    let alert = UIAlertController(title: "Failed to fetch user details", message: error.localizedDescription, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Retry", style: .destructive, handler: { _ in
                                        HTTPSModule().getUser($zd2Data.appUser.user.user.wrappedValue, zd2Data: $zd2Data.wrappedValue) { result in
                                            switch result {
                                            case .success(let response):
                                                zd2Data.appUser.user.user = response.message
                                                zd2Data.appUser.verifiedLogIn = true
                                                dataLoaded = true
                                            case .failure(let error):
                                                //2. time error: Only Log Out
                                                let alert = UIAlertController(title: "Failed to fetch user details AGAIN", message: error.localizedDescription, preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                                                    zd2Data.appUser.loggedIn = false
                                                }))
                                                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                                   let rootViewController = scene.windows.first?.rootViewController {
                                                    rootViewController.present(alert, animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    }))
                                    alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                                        zd2Data.appUser.loggedIn = false
                                    }))
                                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let rootViewController = scene.windows.first?.rootViewController {
                                        rootViewController.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                }
            } else {
                ZD2Onboarding(zd2Data: $zd2Data)
            }
        }
    }
}

#Preview {
    ZD2Management(zd2Data: .constant(defaultZD2Data))
}
