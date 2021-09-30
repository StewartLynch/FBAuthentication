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
    func passwordsMatch(_ confirmPW: String) -> Bool {
        return confirmPW == password
    }
    func isEmpty(_ field: String) -> Bool {
        return field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    func isEmailValid(_ email: String) -> Bool {
        // Password must be 8 chars, contain a capital letter and a number
            let passwordTest = NSPredicate(format: "SELF MATCHES %@",
                                           "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
            return passwordTest.evaluate(with: email)
    }
    func isPasswordValid(_ password: String) -> Bool {
        // Password must be 8 chars, contain a capital letter and a number
        let passwordTest = NSPredicate(format: "SELF MATCHES %@",
                                       "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$")
        return passwordTest.evaluate(with: password)
    }
    var isSignInComplete: Bool {
        if  !isEmailValid(email) ||
            isEmpty(fullname) ||
            !isPasswordValid(password) ||
            !passwordsMatch(confirmPassword) {
            return false
        }
        return true
    }
    var isLogInComplete: Bool {
        if isEmpty(email) ||
            isEmpty(password) {
            return false
        }
        return true
    }
    // MARK: - Validation Error Strings
    var validNameText: String {
        if !isEmpty(fullname) {
            return ""
        } else {
            return "Enter your full name"
        }
    }
    var validEmailAddressText: String {
        if isEmailValid(email) {
            return ""
        } else {
            return "Enter a valid email address"
        }
    }
    var validPasswordText: String {
        if isPasswordValid(password) {
            return ""
        } else {
            return "Must be 8 characters containing at least one number and one Capital letter."
        }
    }
    var validConfirmPasswordText: String {
        if passwordsMatch(confirmPassword) {
            return ""
        } else {
            return "Password fields do not match."
        }
    }
}
