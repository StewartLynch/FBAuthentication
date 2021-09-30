//
//  LoadingView.swift
//  LoadingView
//
//  Created by Stewart Lynch on 2021-09-14.
//

import SwiftUI
public struct LoadingView<StartView>: View where StartView: View {
    /// The view that is first presented while identifying the current authentication state
    @EnvironmentObject var userInfo: UserInfo
    var startView: StartView
    var title: String
    var primaryColor: UIColor
    var secondaryColor: UIColor
    var logoImage: Image?
    /// Loading View parameters
    /// - Parameters:
    ///   - startView: The view that is presented once the user is authenticated
    ///   - title: A title displayed on the login screen, defaults to "Log in"
    ///   - primaryColor: the color used for the primary button defaults to systemOranage
    ///   - secondaryColor: color used for the secondary button defaults to systemBlue
    ///   - logoImage: An image to be used on the login screen.  If left as nil, will display a Firebase logo
    public init(startView: StartView,
                title: String = "Log in",
                primaryColor: UIColor = .systemOrange,
                secondaryColor: UIColor = .systemBlue,
                logoImage: Image? = nil ) {
        self.title = title
        self.startView = startView
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.logoImage = logoImage
    }
    /// The body of the view
    public var body: some View {
        Group {
            if userInfo.isUserAuthenticated == .undefined {
                Text("Loading...")
            } else if userInfo.isUserAuthenticated == .signedOut {
                VStack {
                    Text(title)
                        .font(.title)
                        .foregroundColor(Color(secondaryColor))
                    LoginView(primaryColor: primaryColor, secondaryColor: secondaryColor)
                    if logoImage != nil {
                        logoImage!
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 120, height: 120)
                    } else {
                        firebaseLogo
                        .padding(.top)
                    }
                    Spacer()
                }
            } else {
                startView
            }
        }
        .onAppear {
            self.userInfo.configureFirebaseStateDidChange()
        }
    }
}

extension LoadingView {
    var firebaseLogo: some View {
        ZStack(alignment: .center) {
            VStack {
                Rectangle().fill(Color(secondaryColor))
                    .frame(width: 120, height: 1)
                Rectangle().fill(Color(secondaryColor))
                    .frame(width: 120, height: 1)
            }
            Image("firebase-icon", bundle: .module)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(15)
                .background(Circle().fill(Color(secondaryColor)))
        }
    }
}
