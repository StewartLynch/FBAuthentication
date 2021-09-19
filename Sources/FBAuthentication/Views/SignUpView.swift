//
//  SignUpView.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-19.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userInfo: UserInfo
    @State var user: UserViewModel = UserViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showError = false
    @State private var errorString = ""
    var primaryColor: UIColor
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Full Name", text: self.$user.fullname).autocapitalization(.words)
                if !user.validNameText.isEmpty {
                    Text(user.validNameText).font(.caption).foregroundColor(.red)
                }
                TextField("Email Address", text: self.$user.email).autocapitalization(.none).keyboardType(.emailAddress)
                if !user.validEmailAddressText.isEmpty {
                    Text(user.validEmailAddressText).font(.caption).foregroundColor(.red)
                }
                SecureField("Password", text: self.$user.password).autocapitalization(.none)
                if !user.validPasswordText.isEmpty {
                    Text(user.validPasswordText).font(.caption).foregroundColor(.red)
                }
                SecureField("Confirm Password", text: self.$user.confirmPassword).autocapitalization(.none)
                if !user.passwordsMatch(_confirmPW: user.confirmPassword) {
                    Text(user.validConfirmPasswordText).font(.caption).foregroundColor(.red)
                }
                HStack {
                    Spacer()
                    Button(action: {
                        FBAuth.createUser(withEmail: self.user.email,
                                          name: self.user.fullname,
                                          password: self.user.password) { (restult) in
                            switch restult {
                            case .failure(let error):
                                self.errorString = error.localizedDescription
                                self.showError = true
                            case .success( _):
                                print("Account creation successful")
                            }
                        }
                    }) {
                        Text("Register")
                            .frame(width: 200)
                            .padding(.vertical, 15)
                            .background(Color(primaryColor))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .opacity(user.isSignInComplete ? 1 : 0.75)
                    }
                    .disabled(!user.isSignInComplete)
                    Spacer()
                }
                .padding(.top)
            }
            .padding(.top)
            .alert(isPresented: $showError) {
                Alert(title: Text("Error creating accout"), message: Text(self.errorString), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Sign Up", displayMode: .inline)
            .navigationBarItems(trailing: Button("Dismiss") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(primaryColor:UIColor.systemOrange)
    }
}
