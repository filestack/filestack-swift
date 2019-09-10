//
//  UIColor+hexString.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/11/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X%02X", colorInt(red), colorInt(green), colorInt(blue), colorInt(alpha))
    }

    private func colorInt(_ cgFloat: CGFloat) -> Int {
        return Int(round(cgFloat * 255))
    }
}
