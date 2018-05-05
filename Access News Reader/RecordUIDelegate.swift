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
        ( navLeftButton:     (title: String, active: Bool)?
        , navRightButton:    (title: String, active: Bool)?
        , publication:       ( type: Constants.PublicationLabelType
                             , title: String?
                             )?
        , articleTitle:      ( title: String
                             , enabled: Bool
                             , colour: UIColor
                             )?
        , publicationStatus: Bool?
        , articleStatus:     Bool?
        , controlStatus:     (text: String, colour: UIColor)?
        , visibleControls:   [Controls: (title: String, isEnabled: Bool)]
    )
}
