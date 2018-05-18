//
//  Controls.swift
//  Access News Reader
//
//  Created by Society for the Blind on 5/1/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import Foundation

// https://cocoacasts.com/how-to-work-with-bitmasks-in-swift/
struct Controls: OptionSet {
    let rawValue: Int

    static let record = Controls(rawValue: 1 << 0)
    static let pause  = Controls(rawValue: 1 << 1)
    static let play   = Controls(rawValue: 1 << 2)
    static let stop   = Controls(rawValue: 1 << 3)
    static let submit = Controls(rawValue: 1 << 4)
}

extension Controls: Hashable {
    var hashValue: Int {
        let c: Controls = [.record, .pause, .play, .stop, .submit]
        return c.rawValue
    }

    enum RecordLabel: String {
        case new   = "Record New"
        case start = "Start Recording"
    }

}
