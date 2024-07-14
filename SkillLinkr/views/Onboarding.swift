//
//  onboarding.swift
//  SkillLinkr
//
//  Created by Christian on 14.07.24.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    var body: some View {
        NavigationStack {
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

struct LoginView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    
    @State var mail: String = ""
    @State var password: String = ""
    var body: some View {
        List {
            TextField("Email", text: $mail)
            TextField("Password", text: $password)
            Button("Login") {
                login()
            }
        }
        .navigationTitle("Login")
    }
    
    func login() {
        // Example usage for login:
        httpModule.login(mail: $mail.wrappedValue, password: $password.wrappedValue) { result in
            switch result {
            case .success(let loginResponse):
                print("Login successful! Token: \(loginResponse.message.token)")
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}

struct RegisterView: View {
    @Binding var httpModule: HTTPModule
    @Binding var settings: AppSettings
    
    @State var localUser: User = User(id: 404, firstname: "", lastname: "", mail: "", released: false, role: "error")
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    @State var error: String = ""
    var body: some View {
        List {
            TextField("Firstname", text: $localUser.firstname)
            TextField("Lastname", text: $localUser.lastname)
            TextField("Email", text: $localUser.mail)
            SecureField("Password", text: $password)
            SecureField("Confirm password", text: $passwordConfirm)
            if error != "" {
                Text($error.wrappedValue)
            }
            Button("Register") {
                register()
            }
        }
        .navigationTitle("Register")
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
