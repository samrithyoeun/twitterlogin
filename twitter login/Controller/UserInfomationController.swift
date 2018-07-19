//
//  UserInfomationController.swift
//  twitter login
//
//  Created by PM Academy 3 on 7/19/18.
//  Copyright © 2018 samrith. All rights reserved.
//

import UIKit

class UserInfomationController: UIViewController {
    
    @IBOutlet weak var informationLabel: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("receving data : \(user)")
        informationLabel.text = "You logged in with: \nName: \(user?.name)\nEmail: \(user?.email)\nId: \(user?.id) "
    }

}
