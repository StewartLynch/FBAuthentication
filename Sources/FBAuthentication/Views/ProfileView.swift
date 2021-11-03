//
//  ProfileView.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2021-07-05.
//  Copyright © 2021 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

public struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfo: UserInfo
    @State private var providers: [FBAuth.ProviderType] = []
    @State private var canDelete = false
    @State private var fullname = ""
    var primaryColor: UIColor
    public init(primaryColor: UIColor = .systemOrange) {
        self.primaryColor = primaryColor
    }
    public var body: some View {
        ZStack {
            VStack {
                Text(userInfo.user.name)
                    .font(.title)
                if !canDelete {
                    HStack {
                        TextInputView("Full Name", text: $fullname)
                        Button {
                            FBFirestore.updateUserName(with: fullname, uid: userInfo.user.uid) { result in
                                switch result {
                                case .success:
                                    print("success")
                                    userInfo.user.name = fullname
                                    presentationMode.wrappedValue.dismiss()
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                            Text("Update")
                                .padding(.vertical, 15)
                                .frame(width: 100)
                                .background(Color(primaryColor))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .opacity(!fullname.isEmpty ? 1 : 0.75)
                        }.disabled(fullname.isEmpty)
                    }
                    .padding()
                }
                Text(canDelete ?
                    "DO YOU REALLY WANT TO DELETE?" :
                    "Deleting your account will delete all content " +
                    "and remove your information from the database. " +
                    "You must first re-authenticate")
                HStack {
                    Button("Cancel") {
                        canDelete = false
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.vertical, 15)
                    .frame(width: 100)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .foregroundColor(Color(.label))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    Button(canDelete ? "DELETE ACCOUNT" : "Authenticate") {
                        if canDelete {
                            FBAuth.deleteUser { result in
                                if case let .failure(error) = result {
                                    print(error.localizedDescription)
                                }
                            }
                            // Alternative if you also want to delete the corresponding user collection
//                            FBFirestore.deleteUserData(uid: userInfo.user.uid) { result in
//                                presentationMode.wrappedValue.dismiss()
//                                switch result {
//                                case .success:
//                                    FBAuth.deleteUser { result in
//                                        if case let .failure(error) = result {
//                                            print(error.localizedDescription)
//                                        }
//                                    }
//                                case .failure(let error):
//                                    print(error.localizedDescription)
//                                }
//                            }
                        } else {
                            withAnimation {
                            providers = FBAuth.getProviders()
                            }
                        }
                    }
                    .padding(.vertical, 15)
                    .frame(width: 179)
                    .background(Color.red)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 10)
            if !providers.isEmpty {
                ReAuthenticateView(providers: $providers, canDelete: $canDelete)
            }
        }.onAppear {
            fullname = userInfo.user.name
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(UserInfo())
    }
}
