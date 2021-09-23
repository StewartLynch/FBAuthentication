//
//  FBFireStore.swift
//  Signin With Apple
//
//  Created by Stewart Lynch on 2020-03-18.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//
import FirebaseFirestore

/// A The functions used by the package to retrieve the user information, update and delete account
public enum FBFirestore {
    
    /// Retrieves the FBUser instasnce
    /// - Parameters:
    ///   - uid: The userID
    ///   - completion: a result providing the instance or an error
    static func retrieveFBUser(uid: String, completion: @escaping (Result<FBUser, Error>) -> ()) {
        let reference = Firestore
            .firestore()
            .collection(FBKeys.CollectionPath.users)
            .document(uid)
        getDocument(for: reference) { (result) in
            switch result {
            case .success(let data):
                guard let user = FBUser(documentData: data) else {
                    completion(.failure(FireStoreError.noUser))
                    return
                }
                completion(.success(user))
            case .failure(let err):
                completion(.failure(err))
            }
        }
        
    }
    
    /// Upates the user name
    /// - Parameters:
    ///   - newName: new name provided
    ///   - uid: the unique userID
    ///   - completion: the result providing a success or an error
    static func updateUserName(with newName: String, uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let reference = Firestore.firestore().collection(FBKeys.CollectionPath.users)
        .document(uid)
        reference.setData(["name": newName], merge: true) { err in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(true))
        }
    }
    
    /// Creates the new user
    /// - Parameters:
    ///   - data: the name and email address provided
    ///   - uid: the unique ID generated
    ///   - completion: the result providing a success or an error
    static func mergeFBUser(_ data: [String: Any], uid: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        let reference = Firestore
            .firestore()
            .collection(FBKeys.CollectionPath.users)
            .document(uid)
        reference.setData(data, merge: true) { (err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(true))
        }
    }
    
    
    /// retrieves the document snapshot for the user collection
    /// - Parameters:
    ///   - reference: the document reference
    ///   - completion: a completion handler providing the resulting data or an error
    fileprivate static func getDocument(for reference: DocumentReference, completion: @escaping (Result<[String : Any], Error>) -> ()) {
        reference.getDocument { (documentSnapshot, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let documentSnapshot = documentSnapshot else {
                completion(.failure(FireStoreError.noDocumentSnapshot))
                return
            }
            guard let data = documentSnapshot.data() else {
                completion(.failure(FireStoreError.noSnapshotData))
                return
            }
            completion(.success(data))
        }
    }
    
    /// Deletes the user account
    /// - Parameters:
    ///   - uid: the unique user ID
    ///   - completion: a completion result of a success or an error
   public static func deleteUserData(uid: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        let reference = Firestore
            .firestore()
            .collection(FBKeys.CollectionPath.users)
            .document(uid)
        reference.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
