//
//  UIColor+hexString.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/11/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit


extension UIColor {

    internal var hexString: String {

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return String(format: "%02X%02X%02X%02X",
                      Int(round(red * 255)),
                      Int(round(green * 255)),
                      Int(round(blue * 255)),
                      Int(round(alpha * 255)))
    }
}
