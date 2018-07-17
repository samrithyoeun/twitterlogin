//
//  Result.swift
//  login social
//
//  Created by PM Academy 3 on 7/16/18.
//  Copyright © 2018 PM Academy 3. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(String)
}
