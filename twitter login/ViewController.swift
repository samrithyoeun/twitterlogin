//
//  ViewController.swift
//  twitter login
//
//  Created by Samrith Yoeun on 7/17/18.
//  Copyright © 2018 samrith. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

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
        AuthenticationManager.shared.twitterLogin()
    }
    
}

extension ViewController: GoogleSignInDelegate {
    func googleSignInResponse(user: User) {
        print(user)
    }
    
    func googleSignInLaunch(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func googleSignInDismiss(_ viewController: UIViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

