//
//  RecordUIDelegate.swift
//  Access News Reader
//
//  Created by Society for the Blind on 5/1/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import Foundation
import UIKit

protocol RecordUIDelegate: class {
    func setUI
        ( _ components: [Controls.ControlUIComponent: Any]
        , controls:     [(control: Controls, title: String, status: Bool)]?
        )
}
