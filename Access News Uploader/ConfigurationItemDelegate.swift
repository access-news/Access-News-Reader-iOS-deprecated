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

    func updateValue(_ newValue: String)
    func backToMain() // pop
    func forward(to configurationItem: ConfigurationItemViewController) // push
}
