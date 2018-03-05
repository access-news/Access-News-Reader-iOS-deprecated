//
//  ConfigurationItemDelegate.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/5/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import Foundation
import UIKit

protocol ConfigurationItemDelegate: class {
    var selectedPublication: String {get set}
    var hours:               String {get set}
    var defaults:            UserDefaults {get}
}
