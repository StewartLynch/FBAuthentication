//
//  UserViewModel.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-18.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

struct UserViewModel {
    var email: String = ""
    var password: String = ""
    var fullname: String = ""
    var confirmPassword: String = ""

    // MARK: - Validation Checks
    var passwordsMatch: Bool { password == confirmPassword }

    func isEmpty(_ field: String) -> Bool {
        field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    func isEmailValid() -> Bool {
        // Password must be 8 chars, contain a capital letter and a number
        let passwordTest = NSPredicate(format: "SELF MATCHES %@",
                                       "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return passwordTest.evaluate(with: email)
    }
    func isPasswordValid() -> Bool {
        // Password must be 8 chars, contain a capital letter and a number
        let passwordTest = NSPredicate(format: "SELF MATCHES %@",
                                       "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$")
        return passwordTest.evaluate(with: password)
    }
    var isSignInComplete: Bool {
        isEmailValid() && !isEmpty(password)
    }
    var isSignUpComplete: Bool {
        isSignInComplete && isPasswordValid() && passwordsMatch
    }

    // MARK: - Validation Error Strings
    var validNameText: String {
        isEmpty(fullname) ? "Enter your full name" : ""
    }
    var validEmailAddressText: String {
        isEmailValid() ? "" : "Enter a valid email address"
    }
    var validPasswordText: String {
        isPasswordValid() ? "" : "Must be 8 characters containing at least one number and one Capital letter."
    }
    var validConfirmPasswordText: String {
        passwordsMatch ? "" : "Password fields do not match."
    }
}
