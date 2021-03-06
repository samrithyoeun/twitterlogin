//
//  ViewController.swift
//  twitter login
//
//  Created by Samrith Yoeun on 7/17/18.
//  Copyright © 2018 samrith. All rights reserved.
//

import UIKit
import TwitterKit
import OAuthSwift
import CloudrailSI

class ViewController: UIViewController {
    
    var oauthswift: OAuth2Swift?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthenticationManager.shared.googleDelegate = self
        
        AuthenticationManager.shared.googleSignOut()
    }

    @IBAction func facebookButtonTapped(_ sender: Any) {
        AuthenticationManager.shared.facebookLogin(from: self) { (user) in
            print(user)
        }
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        AuthenticationManager.shared.googleSignIn()
    }
    
    @IBAction func twitterButtonTapped(_ sender: Any) {
        AuthenticationManager.shared.twitterUniversalLogin()
    }
    
    @IBAction func gitHubButtonTapped(_ sender: Any) {
        AuthenticationManager.shared.gitHubLogIn { (user) in
            loginWithUser(user)
        }
    }
    
    @IBAction func linkedInButtonTapped(_ sender: Any) {
        AuthenticationManager.shared.linkedInLogin{ (user) in
            loginWithUser(user)
        }
    }
    
   
    @IBAction func instagramButtonTapped(_ sender: Any) {
        AuthenticationManager.shared.instagramLogin{ (user) in
            loginWithUser(user)
        }
    }
    
    private func loginWithUser(_ user: User) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userInfoVC = storyBoard.instantiateViewController(withIdentifier: "userInfoViewController") as! UserInfomationController
        userInfoVC.user = user
        self.present(userInfoVC, animated: true, completion: nil)
    }
}

extension ViewController: GoogleSignInDelegate {
    func googleSignInResponse(user: User) {
        loginWithUser(user)
    }
    
    func googleSignInLaunch(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func googleSignInDismiss(_ viewController: UIViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

