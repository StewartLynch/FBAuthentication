//
//  SignInWithEmailView.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-19.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

struct SignInWithEmailView: View {
    @EnvironmentObject var userInfo: UserInfo
    @State var user: UserViewModel = UserViewModel()
    @Binding var showSheet: Bool
    @Binding var action: LoginView.Action?
    @State private var showAlert = false
    @State private var authError: EmailAuthError?
    var primaryColor: UIColor
    var secondaryColor: UIColor
    var body: some View {
        VStack {
            TextField("Email Address",
                      text: self.$user.email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $user.password)
            HStack {
                Spacer()
                Button {
                    action = .resetPW
                    showSheet = true
                } label: {
                    Text("Forgot Password")
                }
                .foregroundColor(Color(primaryColor))
            }
            .padding(.bottom)
            VStack(spacing: 10) {
                Button {
                    FBAuth.authenticate(withEmail: self.user.email,
                                        password: self.user.password) { (result) in
                                            switch result {
                                            case .failure(let error):
                                                self.authError = error
                                                self.showAlert = true
                                            case .success:
                                                print("Signed in")
                                            }
                    }
                } label: {
                    Text("Login")
                        .padding(.vertical, 15)
                        .frame(width: 200)
                        .background(Color(primaryColor))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .opacity(user.isLogInComplete ? 1 : 0.75)
                }.disabled(!user.isLogInComplete)
                Button {
                    action = .signUp
                   showSheet = true
                } label: {
                    Text("Sign Up")
                        .padding(.vertical, 15)
                        .frame(width: 200)
                        .background(Color(secondaryColor))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Error"),
                      message: Text(self.authError?.localizedDescription ?? "Unknown error"),
                      dismissButton: .default(Text("OK")) {
                    if self.authError == .incorrectPassword {
                        self.user.password = ""
                    } else {
                        self.user.password = ""
                        self.user.email = ""
                    }
                    })
            }
        }
        .padding(.top)
        .frame(width: 300)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct SignInWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithEmailView(showSheet: .constant(false),
                            action: .constant(.signUp),
                            primaryColor: .systemGreen,
                            secondaryColor: .systemBlue)
    }
}
