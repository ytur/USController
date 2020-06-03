//
//  UIColor+Extension.swift
//  Example
//
//  Created by Yasin TURKOGLU on 2.06.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit

extension UIColor {

    public static let customButtonYellow: UIColor = UIColor(rgb: 0xFCB000, alpha: 1)
    public static let customButtonDisableGray: UIColor = UIColor(rgb: 0xD6D6D6, alpha: 1)

    // MARK: init

    public convenience init(rgb: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
