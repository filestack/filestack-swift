//
//  NegativeTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Returns a negative image by portraying the lightest area as the darkest and the darkest areas as the lightest.
 */
@objc(FSNegativeTransform) public class NegativeTransform: Transform {
    /**
     Initializes a `NegativeTransform` object.
     */
    public init() {
        super.init(name: "negative")
    }
}
