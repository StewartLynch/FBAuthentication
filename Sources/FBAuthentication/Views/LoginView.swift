//
//  LoginView.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2020-03-23.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    enum Action {
        case signUp, resetPW
    }
    @State private var showSheet = false
    @State private var action: Action?
    var primaryColor: UIColor
    var secondaryColor: UIColor
    var body: some View {
        VStack {
            SignInWithEmailView(showSheet: $showSheet,
                                action: $action,
                                primaryColor: primaryColor,
                                secondaryColor: secondaryColor)
            SignInWithAppleButtonView()
        }
            .sheet(isPresented: $showSheet) { [action] in
                if action == .signUp {
                    SignUpView(primaryColor: primaryColor,
                               secondaryColor: secondaryColor)
                } else {
                    ForgotPasswordView(primaryColor: primaryColor)
                }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(primaryColor: .systemBlue, secondaryColor: .systemOrange)
    }
}
