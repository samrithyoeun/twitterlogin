//
//  GoogleSignInDelegate.swift
//  login social
//
//  Created by Samrith Yoeun on 7/16/18.
//  Copyright © 2018 PM Academy 3. All rights reserved.
//

import Foundation
import UIKit

protocol GoogleSignInDelegate {
    func googleSignInResponse(user: User)
    func googleSignInLaunch(_ viewController: UIViewController)
    func googleSignInDismiss(_ viewController: UIViewController)
    
}
