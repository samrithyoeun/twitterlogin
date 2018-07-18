//
//  AuthenticationManager.swift
//  login social
//
//  Created by PM Academy 3 on 7/16/18.
//  Copyright © 2018 PM Academy 3. All rights reserved.
//

import Foundation
import GoogleSignIn
import SwiftyJSON
import FBSDKLoginKit
import TwitterKit
import Alamofire
import OAuthSwift
import LinkedinSwift

class AuthenticationManager: NSObject {
    static let shared = AuthenticationManager()
    let fbLoginManager = FBSDKLoginManager()
    var googleDelegate: GoogleSignInDelegate?
    var oauthswift: OAuthSwift?
    var linkedinHelper: LinkedinSwiftHelper?
    
    override init() {
        
        super.init()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let linkedInSwitHelperConfiguration = LinkedinSwiftConfiguration(
            clientId: Config.linkedKey,
            clientSecret: Config.linkedSecret,
            state: "DLKDJF45DIWOERCM",
            permissions: ["r_basicprofile", "r_emailaddress"],
            redirectUrl: "https://github.com/tonyli508/LinkedinSwift")
        
        linkedinHelper = LinkedinSwiftHelper(configuration: linkedInSwitHelperConfiguration!)
    }
    
    func facebookLogin (from uiViewController: UIViewController, completion: @escaping (Result<User>) -> () ) {
        fbLoginManager.logIn(withReadPermissions: ["email"], from: uiViewController) { (result, error) -> Void in
            if (error == nil) {
                if (result?.isCancelled)! {
                    print("athentication: user cancelled Facebook log in ")
                    return
                } else {
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name, picture.type(large)"])
                        .start(completionHandler: { (connection, result, error) -> Void in
                        if (error == nil){
                            let user = self.mapData(result)
                            completion(Result.success(user))
                        } else {
                            completion(Result.failure("authenticaton: cannot get the user data from Facebook"))
                        }
                    })
                }
            }
        }
    }
    
    func facebookLogOut(){
        fbLoginManager.logOut()
    }

    func mapData(_ value: Any?) -> User {
        let json = JSON(value ?? "")
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let email = json["email"].stringValue
        let user = User(name: name, id: id, token: "", email: email)
        return user
    }
    
    func googleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func twitterLogin(){
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                let authToken = session?.authToken
                let username = session?.userName
                let id = session?.userID
                let user = User(name: username!, id: id!, token: authToken!, email: "")
                print("getData: \(user)")
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }

    func gitHubLogIn() {
        let oauthswift = OAuth2Swift(
            consumerKey:    Config.githubKey,
            consumerSecret: Config.githubSecret,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "oauth-swift://oauth-callback/github")!, scope: "user,repo", state: state,
            success: { credential, response, parameters in
                print("success \(credential)")
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
    func linkedInLogin(){
        linkedinHelper?.authorizeSuccess({ (lsToken) -> Void in
            //Login success lsToken
            print(lsToken)
        }, error: { (error) -> Void in
            print(error)
            //Encounter error: error.localizedDescription
        }, cancel: { () -> Void in
            print("user cancel")
            //User Cancelled!
        })
    }
}

extension AuthenticationManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
        } else {
            let userId = user.userID
            let token = user.authentication.idToken
            let fullName = user.profile.name
            let email = user.profile.email
            _ = user.profile.imageURL(withDimension: 200)
            let user = User(name: fullName!, id: userId!, token: token!, email: email!)
            googleDelegate?.googleSignInResponse(user: user)
        }
        
    }
    
}

extension AuthenticationManager: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
         googleDelegate?.googleSignInLaunch(viewController)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        googleDelegate?.googleSignInDismiss(viewController)
    }
    
    
}






