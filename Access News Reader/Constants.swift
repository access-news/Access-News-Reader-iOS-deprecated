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

    static var documentDir: URL {
        get {
            let documentURLs = FileManager.default.urls(
                for: .documentDirectory,
                in:  .userDomainMask
            )
            return documentURLs.first!
        }
    }

    static var recordings: [URL] {
        get {
            let fileURLs = try? FileManager.default.contentsOfDirectory(at: self.documentDir, includingPropertiesForKeys: nil, options: [])
            return fileURLs ?? []
        }
    }

    static let userLoggedIn: String = "userLoggedIn"

    // storyboard IDs
    static let  mainViewController = "MainViewController"
    static let loginViewController = "LoginViewController"

    static let noTitleColor =
        UIColor(red:   0.345,
                green: 0.337,
                blue:  0.839,
                alpha: 0.5)

    enum PublicationLabelType {
        case selected, not_selected
    }

    enum RecordUINavButton: String {
        case left
        case right
        case queued  = "Queued Recordings"
        case edit    = "Edit"
        case finish  = "Finish Editing"
        case profile = "Profile"
        case main    = "Back to Main"
    }

    enum RecordUIComponent: String {
        case navLeftButton
        case navRightButton
        case selectedPublication
        case articleTitle
        case publicationStatus
        case articleStatus
        case controlStatus
    }
}
