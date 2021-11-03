# FBAuthentication

A Swift Pakage for adding a turnkey sign up/sign in to Firebase workflow for your SwiftUI apps.
After configuring your app for Firebase/Firestore connectivity, a single line of code will create the workflow for signing up and signing in to a Firebase account.

#### Features
* Sign up and sign in in with email
* Sign up and sign in with Apple
* Password reset option sign in with email
* Firebase account deletion functionality included.
* Custom colors and project image

#### Setup and Installation
For detailed instructions and link to video see the documentation page: https://stewartlynch.github.io/FBAuthentication/

### TLDR

1. Create your XCode project and copy the Bundle ID.
2. Log in to the Firebase Console and create a new project.
3. Add a new iOS App and enter your Bundle ID for the app.
4. Download the GoogleServices-Info.plist and drop it into your Xcode project.
5. Add Authentication by choosing Email/Password and Apple.
6. Add Firestore Database service to your project.
7. Log into your Apple Developer account and in the Certificates, IDs and profiles section, enable Email Sources for the firebase project.
8. Add Sign in with Apple capability to your Xcode app.
9. Add the FBAuthentication package to your Xcode project using the URL from this page https://github.com/StewartLynch/FBAuthentication/
10. Import Firebase and FBAuthentication in your @main file and configure Firebase then inject an instance of UserInfo() into the environment.
11. Design your `HomeView` view in your app which will be the first page that you app goes to after a successfull authentication.
12. Update ContentView by importing `FBAuthentication`, add an instance of userInfo as an `@EnvironmentObject` then replace the body with a call to `LoadingView` passing in your `HomeView` as the startView
```
import SwiftUI
import FBAuthentication

struct ContentView: View {
    @EnvironmentObject var userInfo: UserInfo
    var body: some View {
        LoadingView(startView: HomeView())
    }
}
```
#### Test
Test your app by signing in via email and Apple

#### Logging out
Implement logging out using
```
    FBAuth.logout { (result) in
        print("Logged out")
    }
```

#### Account Profile

To access the profile where you will be able to update the user name or delete the account and all related data, present a sheet to the **ProfileView**

```
.sheet(isPresented: $showProfile {
    ProfileView()
}
```

