//
//  Transform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

typealias TaskOption = (key: String, value: Any?)
typealias Task = (name: String, options: [TaskOption]?)

/// :nodoc:
public class Transform {
    // MARK: - Internal Properties

    var task: Task { Task(name: name, options: options) }

    // MARK: - Private Properties

    private var options = [TaskOption]()
    private let name: String

    // MARK: - Lifecycle

    init(name: String) {
        self.name = name
    }
}

// MARK: - Internal Functions

extension Transform {
    @discardableResult
    func appending(key: String, value: Any?) -> Self {
        options.append((key: key, value: value))

        return self
    }

    func removeAllOptions() {
        options.removeAll()
    }
}

// MARK: - Public Aliases

public extension Transform {
    /// Shortcut for AnimateTransform.
    typealias Animate = AnimateTransform

    /// Shortcut for ASCIITransform.
    typealias ASCII = ASCIITransform

    /// Shortcut for AutoImageTransform.
    typealias AutoImage = AutoImageTransform

    /// Shortcut for AVTransform.
    typealias AV = AVTransform

    /// Shortcut for BlackAndWhiteTransform.
    typealias BlackAndWhite = BlackAndWhiteTransform

    /// Shortcut for BlurFacesTransform.
    typealias BlurFaces = BlurFacesTransform

    /// Shortcut for BlurTransform.
    typealias Blur = BlurTransform

    /// Shortcut for BorderTransform.
    typealias Border = BorderTransform

    /// Shortcut for CacheTransform.
    typealias Cache = CacheTransform

    /// Shortcut for CircleTransform.
    typealias Circle = CircleTransform

    /// Shortcut for CollageTransform.
    typealias Collage = CollageTransform

    /// Shortcut for CompressTransform.
    typealias Compress = CompressTransform

    /// Shortcut for ConvertTransform.
    typealias Convert = ConvertTransform

    /// Shortcut for CopyrightTransform.
    typealias Copyright = CopyrightTransform

    /// Shortcut for CropFacesTransform.
    typealias CropFaces = CropFacesTransform

    /// Shortcut for CropTransform.
    typealias Crop = CropTransform

    /// Shortcut for DetectFacesTransform.
    typealias DetectFaces = DetectFacesTransform

    /// Shortcut for DocumentDetectionTransform.
    typealias DocumentDetection = DocumentDetectionTransform

    /// Shortcut for EnhanceTransform.
    typealias Enhance = EnhanceTransform

    /// Shortcut for FallbackTransform.
    typealias Fallback = FallbackTransform

    /// Shortcut for FlipTransform.
    typealias Flip = FlipTransform

    /// Shortcut for FlopTransform.
    typealias Flop = FlopTransform

    /// Shortcut for ImageSizeTransform.
    typealias ImageSize = ImageSizeTransform

    /// Shortcut for MinifyCSSTransform.
    typealias MinifyCSS = MinifyCSSTransform

    /// Shortcut for MinifyJSTransform.
    typealias MinifyJS = MinifyJSTransform

    /// Shortcut for ModulateTransform.
    typealias Modulate = ModulateTransform

    /// Shortcut for MonochromeTransform.
    typealias Monochrome = MonochromeTransform

    /// Shortcut for NegativeTransform.
    typealias Negative = NegativeTransform

    /// Shortcut for NoMetadataTransform.
    typealias NoMetadata = NoMetadataTransform

    /// Shortcut for OCRTransform.
    typealias OCR = OCRTransform

    /// Shortcut for OilPaintTransform.
    typealias OilPaint = OilPaintTransform

    /// Shortcut for PartialBlurTransform.
    typealias PartialBlur = PartialBlurTransform

    /// Shortcut for PartialPixelateTransform.
    typealias PartialPixelate = PartialPixelateTransform

    /// Shortcut for PDFConvertTransform.
    typealias PDFConvert = PDFConvertTransform

    /// Shortcut for PDFInfoTransform.
    typealias PDFInfo = PDFInfoTransform

    /// Shortcut for PDFMonochromeTransform.
    typealias PDFMonochrome = PDFMonochromeTransform

    /// Shortcut for PixelateFacesTransform.
    typealias PixelateFaces = PixelateFacesTransform

    /// Shortcut for PixelateTransform.
    typealias Pixelate = PixelateTransform

    /// Shortcut for PolaroidTransform.
    typealias Polaroid = PolaroidTransform

    /// Shortcut for ProgressiveJPEGTransform.
    typealias ProgressiveJPEG = ProgressiveJPEGTransform

    /// Shortcut for QualityTransform.
    typealias Quality = QualityTransform

    /// Shortcut for RedEyeRemovalTransform.
    typealias RedEyeRemoval = RedEyeRemovalTransform

    /// Shortcut for ResizeTransform.
    typealias Resize = ResizeTransform

    /// Shortcut for RotateTransform.
    typealias Rotate = RotateTransform

    /// Shortcut for RoundedCornersTransform.
    typealias RoundedCorners = RoundedCornersTransform

    /// Shortcut for SecureForWorkTransform.
    typealias SecureForWork = SecureForWorkTransform

    /// Shortcut for SepiaTransform.
    typealias Sepia = SepiaTransform

    /// Shortcut for ShadowTransform.
    typealias Shadow = ShadowTransform

    /// Shortcut for SharpenTransform.
    typealias Sharpen = SharpenTransform

    /// Shortcut for TornEdgesTransform.
    typealias TornEdges = TornEdgesTransform

    /// Shortcut for UpscaleTransform.
    typealias Upscale = UpscaleTransform

    /// Shortcut for URLScreenshotTransform.
    typealias URLScreenshot = URLScreenshotTransform

    /// Shortcut for VignetteTransform.
    typealias Vignette = VignetteTransform

    /// Shortcut for WatermarkTransform.
    typealias Watermark = WatermarkTransform

    /// Shortcut for ZipTransform.
    typealias Zip = ZipTransform
}
