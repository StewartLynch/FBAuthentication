//
//  UserInfo.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2020-03-23.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import Foundation
import FirebaseAuth

/// The object injected into the environment holding the user's current authentication
/// state and an instance of the FBUser object
public class UserInfo: ObservableObject {
    /// Enum describing the current authentication state
    public enum FBAuthState {
        case undefined, signedOut, signedIn
    }
    @Published public var isUserAuthenticated: FBAuthState
    @Published public var user: FBUser
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    /// UserInfo properties
    /// - Parameters:
    ///   - isUserAuthenticated: an enum representing the current state of connection
    ///   - user: The FBUser object
    public init(isUserAuthenticated: Published<FBAuthState>
                = Published<FBAuthState>.init(wrappedValue: .undefined),
                user: Published<FBUser> = Published<FBUser>.init(wrappedValue: FBUser(uid: "",
                                                                                      name: "",
                                                                                      email: ""))) {
        self._user = user
        self._isUserAuthenticated  = isUserAuthenticated
    }
    /// Handles the change of authentication state
    func configureFirebaseStateDidChange() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ (_, user) in
            guard let user = user else {
                self.isUserAuthenticated = .signedOut
                return
            }
            self.isUserAuthenticated = .signedIn
            FBFirestore.retrieveFBUser(uid: user.uid) { (result) in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let user):
                    self.user = user
                }
            }
        })
    }
}
