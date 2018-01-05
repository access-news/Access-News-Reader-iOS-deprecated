//
//  ConfigurationItemDelegate.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/5/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import Foundation
import UIKit
import Social

protocol ConfigurationItemDelegate: class{
    func updateValue(newValue: String, of configItem: SLComposeSheetConfigurationItem)

    func nextConfigurationItemViewController()
}
