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
    var secondaryColor: UIColor
    var body: some View {
        NavigationView {
            VStack {
                    VStack(alignment: .leading) {
                        TextInputView("Full Name", text: $user.fullname)
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                    VStack(alignment: .leading) {
                        TextInputView("Email Address", text: $user.email)
                        if !user.validEmailAddressText.isEmpty || user.email.isEmpty {
                            Text(user.validEmailAddressText).font(.caption).foregroundColor(.red)
                        }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                    VStack(alignment: .leading) {
                        TextInputView("Password", text: $user.password, isSecure: true)
                        if !user.validPasswordText.isEmpty {
                            Text(user.validPasswordText).font(.caption).foregroundColor(.red)
                        }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                    VStack(alignment: .leading) {
                        TextInputView("Confirm Password", text: $user.confirmPassword, isSecure: true)
                        if !user.passwordsMatch( user.confirmPassword) {
                            Text(user.validConfirmPasswordText).font(.caption).foregroundColor(.red)
                        }
                        Rectangle().fill(Color(.secondaryLabel))
                            .frame(height: 1)
                    }
                VStack(spacing: 20 ) {
                    Button {
                        FBAuth.createUser(withEmail: self.user.email,
                                          name: self.user.fullname,
                                          password: self.user.password) { (restult) in
                            switch restult {
                            case .failure(let error):
                                self.errorString = error.localizedDescription
                                self.showError = true
                            case .success:
                                print("Account creation successful")
                            }
                        }
                    } label: {
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
                }.padding()
            }
            .frame(width: 300)
            .padding(.top)
                .alert(isPresented: $showError) {
                    Alert(title: Text("Error creating accout"),
                          message: Text(self.errorString),
                          dismissButton: .default(Text("OK")))
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
        SignUpView(primaryColor: UIColor.systemOrange, secondaryColor: .blue)
    }
}

struct TextInputView: View {
    var title: String
    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
    }
    @Binding var text: String
    var isSecure = false
    var body: some View {
        //        VStack {
        ZStack(alignment: .leading) {
            Text(title)
                .foregroundColor(text.tfProperties.phColor)
                .offset(y: text.tfProperties.offset)
                .scaleEffect(text.tfProperties.scale, anchor: .leading)
            if isSecure {
                SecureField("", text: $text).autocapitalization(.none)
            } else {
                TextField("", text: $text).autocapitalization(.none)
            }
        }
            .padding(.bottom, text.isEmpty ? 0 : 15)
        .animation(.default, value: text)
        //        }
    }
}

extension String {
    struct TFProperties: Equatable {
        var offset: Double = 0
        var phColor = Color(.placeholderText)
        var scale: Double = 1
    }
    var tfProperties: TFProperties {
        if isEmpty {
            return TFProperties(offset: 0, phColor: Color(.placeholderText), scale: 1)
        } else {
            return TFProperties(offset: 25, phColor: Color(.secondaryLabel), scale: 0.8)
        }
    }
}
