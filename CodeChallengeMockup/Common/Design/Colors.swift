//
//  Colors.swift
//  CodeChallengeMockup
//
//  Created by Chase Wang on 9/2/20.
//  Copyright © 2020 ocw. All rights reserved.
//

import UIKit.UIColor

enum Colors {
    static let hex_f8f8f7_offWhite = UIColor(hex: 0xF8F8F7)
}

extension UIColor {
    /// Initialize a color with a hex value. You should generally never do this and instead use
    /// an existing color above.
    fileprivate convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
