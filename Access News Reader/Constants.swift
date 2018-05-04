//
//  Constants.swift
//  Access News Reader
//
//  Created by Society for the Blind on 12/31/17.
//  Copyright © 2017 Society for the Blind. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let userLoggedIn: String = "userLoggedIn"

    // storyboard IDs
    static let  mainViewController = "MainViewController"
    static let loginViewController = "LoginViewController"

    static let errorColor = UIColor(red: 0.345, green: 0.337, blue: 0.839, alpha: 0.5)

    enum PublicationLabelType {
        case selected, not_selected
    }
}
