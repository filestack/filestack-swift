//
//  TransformEnhancePreset.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 19/08/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Represents an enhance transformation preset.
@objc(FSTransformEnhancePreset)
public enum TransformEnhancePreset: UInt, CustomStringConvertible {
    /// Automatically chooses a preset that does best enhancement to a photo.
    case auto
    /// Gives more depth and brightness to a photo.
    case vivid
    /// Automatically scans each face in the photo and adjusts how much corrections to apply to each face.
    case beautify
    /// Similar to `beautify`, but it applies stronger corrections and uses a larger set of possible modifications.
    case beautifyPlus
    /// By turning off the contrast, maximum detail is retrieved from the shadow areas without blowing out the
    /// bright areas.
    case fixDark
    /// Automatically detects noise, and if detected, applies powerful noise removal to remove any grains from
    /// your photos while preserving details.
    case fixNoise
    /// Removes abnormal tint (yellow, blue, green, etc.) from your photos.
    case fixTint
    /// Optimizes your landscape photographs with more color vibrancy. The contrast is adjusted to reveal slightly
    /// more detail in the shadow areas.
    case outdoor
    /// Applies correction for dark night sky and sets off excess colors from fireworks.
    case fireworks
}

// MARK: - CustomStringConvertible Conformance

extension TransformEnhancePreset {
    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .auto: return "auto"
        case .vivid: return "vivid"
        case .beautify: return "beautify"
        case .beautifyPlus: return "beautify_plus"
        case .fixDark: return "fix_dark"
        case .fixNoise: return "fix_noise"
        case .fixTint: return "fix_tint"
        case .outdoor: return "outdoor"
        case .fireworks: return "fireworks"
        }
    }
}
