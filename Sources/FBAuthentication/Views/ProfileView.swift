//
//  ProfileView.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2021-07-05.
//  Copyright © 2021 CreaTECH Solutions. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfo: UserInfo
    @State private var providers: [FBAuth.ProviderType] = []
    @Binding var canDelete: Bool
    var body: some View {
        ZStack {
            VStack {
                Text(userInfo.user.name)
                    .font(.title)
                Text(canDelete ? "DO YOU REALLY WANT TO DELETE?" : "You are logged in as \(userInfo.user.email). Deleting your account will delete all content and remove your information from the database.  You must first re-authenticate")
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
                            presentationMode.wrappedValue.dismiss()
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
            .padding(.horizontal,10)
            if !providers.isEmpty {
                ReAuthenticateView(providers: $providers, canDelete: $canDelete)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(canDelete: .constant(false)).environmentObject(UserInfo())
    }
}
