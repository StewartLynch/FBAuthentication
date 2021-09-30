//
//  FBUser.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-18.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import Foundation

/// The User object created when the user authenticates.
public struct FBUser: Codable {
    public let uid: String
    public var name: String
    let email: String
    // App Specific properties can be added here
    /// The FBUser object
    /// - Parameters:
    ///   - uid: the UserID
    ///   - name: the name provided
    ///   - email: the email address provided
   public init(uid: String, name: String, email: String) {
        self.uid = uid
        self.name = name
        self.email = email
    }
}
