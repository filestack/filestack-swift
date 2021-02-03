//
//  FlopTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Flips/mirrors the image horizontally.
public class FlopTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `FlopTransform` object.
    public init() {
        super.init(name: "flop")
    }
}
