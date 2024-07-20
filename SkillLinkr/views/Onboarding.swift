//
//  onboarding.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import Combine
import SwiftUI

struct OnboardingView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Icon")
                Rectangle()
                    .fill(.ultraThinMaterial)
                VStack {
                    Text("Welcome to Skilllinkr")
                        .font(.title)
                    HStack {
                        NavigationLink("Login") {
                            LoginView(httpModule: $httpModule, settings: $settings)
                        }
                        .buttonStyle(.borderedProminent)
                        NavigationLink("Or create a new account") {
                            RegisterView(httpModule: $httpModule, settings: $settings)
                        }
                    }
                }
            }
        }
    }
}

struct LoginView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    
    @State var mail: String = ""
    @State var password: String = ""
    
    @State var error: String?
    var body: some View {
        Form {
            EmailInputView(placeHolder: "Email", txt: $mail)
            SecureField("Password", text: $password)
            if error != nil {
                Text(error ?? "")
            }
        }
        .navigationTitle("Login")
        .toolbar {
            Button("Login") {
                login()
            }
            .disabled(mail.isEmpty || password.isEmpty)
        }
    }
    
    func login() {
        httpModule.login(mail: $mail.wrappedValue, password: $password.wrappedValue) { result in
            switch result {
            case .success(let loginResponse):
                print("Login successful! Token: \(loginResponse.message.token)")
            case .failure(let error):
                self.error = error.localizedDescription
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}

struct RegisterView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    
    @State var localUser: User = User(id: "error", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 1, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    @State var error: String = ""
    var body: some View {
        Form {
            TextField("Firstname", text: $localUser.firstname)
            TextField("Lastname", text: $localUser.lastname)
            EmailInputView(placeHolder: "Email", txt: $localUser.mail)
            SecureField("Password", text: $password)
            SecureField("Confirm password", text: $passwordConfirm)
            if error != "" {
                Text($error.wrappedValue)
            }
        }
        .navigationTitle("Register")
        .toolbar {
            Button("Register") {
                register()
            }
            .disabled(localUser.firstname.isEmpty || localUser.lastname.isEmpty || localUser.mail.isEmpty || password.isEmpty || passwordConfirm.isEmpty)
        }
    }
    
    func register() {
        httpModule.register(mail: $localUser.mail.wrappedValue, firstname: $localUser.firstname.wrappedValue, lastname: $localUser.lastname.wrappedValue, password: $password.wrappedValue, passwordConfirm: $passwordConfirm.wrappedValue) { result in
            switch result {
            case .success(_):
                print("Registration successful!")
            case .failure(let error):
                print("Registration failed: \(error.localizedDescription)")
                self.error = error.localizedDescription
            }
        }
    }
}

struct EmailInputView: View {
    var placeHolder: String = ""
    @Binding var txt: String
    
    var body: some View {
        TextField(placeHolder, text: $txt)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onReceive(Just(txt)) { newValue in
                let validString = newValue.filter { "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ._-+$!~&=#[]@".contains($0) }
                if validString != newValue {
                    self.txt = validString
                }
        }
    }
}

#Preview {
    OnboardingView(httpModule: .constant(HTTPModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", userToken: "")), appDataModule: AppDataModule(settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", user: User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: "")))))), settings: .constant(AppSettings(apiURL: "https://skilllinkr.micstudios.de/api", user: User(id: "", firstname: "", lastname: "", mail: "", released: false, role: UserRole(id: 0, name: "", description: "", createdAt: "", updatedAt: ""), updatedAt: "", createdAt: ""))))
}
