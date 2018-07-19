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
import CloudrailSI

class AuthenticationManager: NSObject {
    static let shared = AuthenticationManager()
    let fbLoginManager = FBSDKLoginManager()
    var googleDelegate: GoogleSignInDelegate?
    var oauthswift: OAuthSwift?
    var linkedinHelper: LinkedinSwiftHelper?
    var instagram = Instagram.init(clientId: Config.instagramKey, clientSecret: Config.instagramSecret)
    var twitter = Twitter.init(clientId: Config.twitterConsumerKey, clientSecret: Config.twitterConsumerSecret)
    var github = GitHub.init(clientId: Config.githubKey, clientSecret: Config.githubSecret)
    var linkedin = LinkedIn.init(clientId: Config.linkedKey, clientSecret: Config.linkedSecret)
    
    typealias ResponseUser = ( (_ user: User) -> () )
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
                            var user = self.mapData(result)
                            print("facebook authentication")
                            print(user)
                            user.token = FBSDKAccessToken.current().tokenString
                            completion(Result.success(user))
                        } else {
                            completion(Result.failure("authenticaton: cannot get the user data from Facebook"))
                        }
                    })
                }
            }
        }
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
    
    func twitterUniversalLogin(){
            let oauthswift = OAuth1Swift(
                consumerKey: Config.twitterConsumerKey,
                consumerSecret: Config.twitterConsumerSecret,
                requestTokenUrl: "https://api.twitter.com/oauth/request_token",
                authorizeUrl:    "https://api.twitter.com/oauth/authorize",
                accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
            )
            self.oauthswift = oauthswift
            let _ = oauthswift.authorize(
                withCallbackURL: URL(string: "http://oauthswift.herokuapp.com/callback/twitter")!,
                success: { credential, response, parameters in
                    print("credential")
                    print(credential)
            },
                failure: { error in
                    print(error.description)
            }
            )
        }
    
        func testTwitter(_ oauthswift: OAuth1Swift) {
            let _ = oauthswift.client.get(
                "https://api.twitter.com/1.1/statuses/mentions_timeline.json", parameters: [:],
                success: { response in
                    let jsonDict = try? response.jsonObject()
                    print(String(describing: jsonDict))
            }, failure: { error in
                print(error)
            }
            )
        }
    
    
    func gitHubLogIn(callback: ResponseUser) {
        do {
            try github.login()
            let name  = try github.fullName()
            let id = try github.identifier()
            let email = try github.email()
            let user = User(name: name, id: id, token: "", email: email)
            print("github user")
            print(user)
            callback(user)
        } catch let error {
            print("github error")
            print(error)
        }
    }
    
    func linkedInLogin(callback: ResponseUser) {
        do {
            try linkedin.login()
            let name  = try linkedin.fullName()
            let email = try linkedin.email()
            let id = try linkedin.identifier()
            let credential = try linkedin.saveAsString()
            let user = User(name: name, id: id, token: credential, email: email)
            print(user)
            callback(user)
        } catch let error {
            print("linked error")
            print(error)
        }
    }
    
    func instagramLogin(callback: ResponseUser){
        do {
            try instagram.login()
            let name  = try instagram.fullName()
            let id = try instagram.identifier()
            let email = try instagram.email()
            let user = User(name: name, id: id, token: "", email: email)
            print(user)
            callback(user)
        } catch let error {
            print("instagram error")
            print(error)
        }
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






