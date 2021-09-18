//
//  FBAuth.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-18.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import CryptoKit
import AuthenticationServices

// This typeAlias is defined just to make it simpler to deal with the tuble used in the SignInWithApple handle function once signed in.
typealias SignInWithAppleResult = (authDataResult: AuthDataResult, appleIDCredential: ASAuthorizationAppleIDCredential)

public struct FBAuth {
    // MARK: - Sign In with Email functions
    
    static func resetPassword(email:String, resetCompletion:@escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if let error = error {
                resetCompletion(.failure(error))
            } else {
                resetCompletion(.success(true))
            }
        }
        )}
    
    static func authenticate(withEmail email :String,
                             password:String,
                             completionHandler:@escaping (Result<Bool, EmailAuthError>) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            // check the NSError code and convert the error to an AuthError type
            var newError:NSError
            if let err = error {
                newError = err as NSError
                var authError:EmailAuthError?
                switch newError.code {
                case 17009:
                    authError = .incorrectPassword
                case 17008:
                    authError = .invalidEmail
                case 17011:
                    authError = .accoundDoesNotExist
                default:
                    authError = .unknownError
                }
                completionHandler(.failure(authError!))
            } else {
                completionHandler(.success(true))
            }
        }
    }
    
    // MARK: - SignIn with Apple Functions
    
    static func signInWithApple(idTokenString: String,
                                nonce: String,
                                completion: @escaping (Result<AuthDataResult, Error>) -> ()) {
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        // Sign in with Apple.
        Auth.auth().signIn(with: credential) { (authDataResult, err) in
            if let err = err {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                print(err.localizedDescription)
                completion(.failure(err))
                return
            }
            // User is signed in to Firebase with Apple.
            guard let authDataResult = authDataResult else {
                completion(.failure(SignInWithAppleAuthError.noAuthDataResult))
                return
            }
            completion(.success(authDataResult))
        }
    }
    
    static func handle(_ signInWithAppleResult: SignInWithAppleResult, completion: @escaping (Result<Bool, Error>) -> ()) {
        // SignInWithAppleResult is a tuple with the authDataResult and appleIDCredentioal
        // Now that you are signed in, we can update our User database to add this user.
        
        // First the uid
        let uid = signInWithAppleResult.authDataResult.user.uid
        
        // Now Extract the fullname into a single string name
        // Note, you only get this object when the account is created.
        // All subsequent times, the fullName will be nill so you need to capture it now if you want it for
        // your database
        
        var name = ""
        let fullName = signInWithAppleResult.appleIDCredential.fullName
        // Extract all three components
        let givenName = fullName?.givenName ?? ""
        let middleName = fullName?.middleName ?? ""
        let familyName = fullName?.familyName ?? ""
        let names = [givenName, middleName, familyName]
        // remove any names that are empty
        let filteredNames = names.filter {$0 != ""}
        // Join the names together into a single name
        for i in 0..<filteredNames.count {
            name += filteredNames[i]
            if i != filteredNames.count - 1 {
                name += " "
            }
        }
        
        let email = signInWithAppleResult.authDataResult.user.email ?? ""
        
        
        let data = FBUser.dataDict(uid: uid,
                                         name: name,
                                         email: email)
        
        // Now create or merge the User in Firestore DB
        FBFirestore.mergeFBUser(data, uid: uid) { (result) in
            completion(result)
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - FB Firestore User creation
    static func createUser(withEmail email:String,
                           name: String,
                           password:String,
                           completionHandler:@escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let err = error {
                completionHandler(.failure(err))
                return
            }
            guard let _ = authResult?.user else {
                completionHandler(.failure(error!))
                return
            }
            let data = FBUser.dataDict(uid: authResult!.user.uid,
                                             name: name,
                                             email: authResult!.user.email!)
            
            FBFirestore.mergeFBUser(data, uid: authResult!.user.uid) { (result) in
                completionHandler(result)
            }
            completionHandler(.success(true))
        }
    }
    
    // MARK: - Logout
    
    public static func logout(completion: @escaping (Result<Bool, Error>) -> ()) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            completion(.success(true))
        } catch let err {
            completion(.failure(err))
        }
    }
    
    // MARK: - Delete User
    enum ProviderType: String {
        case password
        case apple = "apple.com"
    }
    
    static func getProviders() -> [ProviderType] {
        var providers:[ProviderType] = []
        if let user = Auth.auth().currentUser {
            for data in user.providerData {
                if let providerType = ProviderType(rawValue: data.providerID) {
                    providers.append(providerType)
                }
            }
        }
        return providers
    }
    
    static func reauthenticateWithPassword(password: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    static func reauthenticateWithApple(idTokenString: String, nonce: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    static func deleteUser(completion: @escaping (Result<Bool,Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
}
