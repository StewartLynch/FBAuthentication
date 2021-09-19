//
//  FBUser.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-18.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import Foundation

/// The User object created when the user authenticates.
public struct FBUser {
    let uid: String
    public let name: String
    let email: String
    
    // App Specific properties can be added here
    
   public init(uid: String, name: String, email: String) {
        self.uid = uid
        self.name = name
        self.email = email
    }

}

public extension FBUser {
    /// the Firebase keys
     init?(documentData: [String : Any]) {
        let uid = documentData[FBKeys.User.uid] as? String ?? ""
        let name = documentData[FBKeys.User.name] as? String ?? ""
        let email = documentData[FBKeys.User.email] as? String ?? ""
        
        // Make sure you also initialize any app specific properties if you have them

        
        self.init(uid: uid,
                  name: name,
                  email: email
                  // Dont forget any app specific ones here too
        )
    }
    
    /// Properties mapped to the Firebase keys
    /// - Parameters:
    ///   - uid: A unique identifier
    ///   - name: The name entered on the signup form or passed in via sign in with apple
    ///   - email: email address used if signin with email
    /// - Returns: Returns an data object
    static func dataDict(uid: String, name: String, email: String) -> [String: Any] {
        var data: [String: Any]
        
        // If name is not "" this must be a new entry so add all first time data
        if name != "" {
            data = [
                FBKeys.User.uid: uid,
                FBKeys.User.name: name,
                FBKeys.User.email: email
                // Again, include any app specific properties that you want stored on creation
            ]
        } else {
            // This is a subsequent entry so only merge uid and email so as not
            // to overrwrite any other data.
            data = [
                FBKeys.User.uid: uid,
                FBKeys.User.email: email
            ]
        }
        return data
    }
}
