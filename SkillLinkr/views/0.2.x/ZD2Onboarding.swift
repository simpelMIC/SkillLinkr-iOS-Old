//
//  OnboardingZD2.swift
//  SkillLinkr
//
//  Created by Christian on 21.07.24.
//

import Foundation
import SwiftUI

struct ZD2Onboarding: View {
    @Binding var zd2Data: ZD2Data
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Icon")
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        Rectangle()
                            .foregroundStyle(.ultraThinMaterial)
                    }
                VStack {
                    HStack {
                        Image("Icon")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .cornerRadius(9)
                        Text("SkillLinkr")
                            .font(.largeTitle)
                    }
                    .shadow(radius: 10)
                    HStack {
                        NavigationLink("Login") {
                            ZD2LoginView(zd2Data: $zd2Data, displayMode: .navigation)
                        }
                        .buttonStyle(.borderedProminent)
                        .shadow(radius: 10)
                        NavigationLink("or create a new account") {
                            ZD2NewAccountView(zd2Data: $zd2Data)
                        }
                        .shadow(radius: 10)
                    }
                    .padding()
                }
            }
        }
    }
}

//Login
struct ZD2LoginView: View {
    @Binding var zd2Data: ZD2Data
    @State var email: String = ""
    @State var password: String = ""
    
    @State var error: String?
    
    //For some --maybe-- other use cases
    enum DisplayMode {
        case navigation
        case overlay
    }
    
    @State var displayMode: DisplayMode
    var body: some View {
        if displayMode == .navigation {
            List {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                    .autocorrectionDisabled()
                if error != nil {
                    Text(error!)
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Login") {
                    login()
                }
                .disabled(email.isEmpty || password.isEmpty)
            }
        } else {
            VStack {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 350)
                SecureField("Password", text: $password)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 350)
                if error != nil {
                    Text(error!)
                }
                Button("Login") {
                    login()
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding()
            }
        }
    }
    
    func login() {
        HTTPSModule().login(apiURL: $zd2Data.settings.apiURL.wrappedValue.absoluteString, mail: $email.wrappedValue, password: $password.wrappedValue) { result in
            switch result {
            case .success(let response):
                zd2Data.appUser.loggedIn = true
                zd2Data.appUser.userToken = response.message.token
                ZD2DataModule().save($zd2Data.wrappedValue)
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }
}

//Register
struct ZD2NewAccountView: View {
    @Binding var zd2Data: ZD2Data
    @State var firstname: String = ""
    @State var lastname: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    
    @State var error: String?
    var body: some View {
        List {
            TextField("Firstname", text: $firstname)
            TextField("Lastname", text: $lastname)
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .autocorrectionDisabled()
            SecureField("Confirm Password", text: $passwordConfirm)
                .autocorrectionDisabled()
            if error != nil {
                Text(error!)
            }
        }
        .navigationTitle("New Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Create") {
                create()
            }
            .disabled(firstname.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty)
        }
    }
    
    func create() {
        HTTPSModule().register(apiURL: $zd2Data.settings.apiURL.wrappedValue.absoluteString, mail: $email.wrappedValue, firstname: $firstname.wrappedValue, lastname: $lastname.wrappedValue, password: $password.wrappedValue, passwordConfirm: $passwordConfirm.wrappedValue) { result in
            switch result {
            case .success(let response):
                zd2Data.appUser.loggedIn = true
                zd2Data.appUser.userToken = response.message.token
                ZD2DataModule().save($zd2Data.wrappedValue)
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }
}

#Preview {
    ZD2Onboarding(zd2Data: .constant(defaultZD2Data))
}
