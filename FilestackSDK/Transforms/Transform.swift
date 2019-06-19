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
@objc(FSTransform) public class Transform: NSObject {

    private var options = [TaskOption]()
    private let name: String

    var task: Task {
        return Task(name: name, options: options)
    }

    init(name: String) {
        self.name = name
    }
}

extension Transform {
    typealias ASCII = ASCIITransform
    typealias AV = AVTransform
    typealias BlackAndWhite = BlackAndWhiteTransform
    typealias BlurFaces = BlurFacesTransform
    typealias Blur = BlurTransform
    typealias Border = BorderTransform
    typealias Cache = CacheTransform
    typealias Circle = CircleTransform
    typealias Collage = CollageTransform
    typealias Compress = CompressTransform
    typealias Convert = ConvertTransform
    typealias CropFaces = CropFacesTransform
    typealias Crop = CropTransform
    typealias DetectFaces = DetectFacesTransform
    typealias DocumentDetection = DocumentDetectionTransform
    typealias Enhance = EnhanceTransform
    typealias Fallback = FallbackTransform
    typealias Flip = FlipTransform
    typealias Flop = FlopTransform
    typealias ImageSize = ImageSizeTransform
    typealias Modulate = ModulateTransform
    typealias Monochrome = MonochromeTransform
    typealias Negative = NegativeTransform
    typealias NoMetadata = NoMetadataTransform
    typealias OilPaint = OilPaintTransform
    typealias PartialBlur = PartialBlurTransform
    typealias PartialPixelate = PartialPixelateTransform
    typealias PDFConvert = PDFConvertTransform
    typealias PDFInfo = PDFInfoTransform
    typealias PDFMonochrome = PDFMonochromeTransform
    typealias PixelateFaces = PixelateFacesTransform
    typealias Pixelate = PixelateTransform
    typealias Polaroid = PolaroidTransform
    typealias ProgressiveJPEG = ProgressiveJPEGTransform
    typealias Quality = QualityTransform
    typealias RedEyeRemoval = RedEyeRemovalTransform
    typealias Resize = ResizeTransform
    typealias Rotate = RotateTransform
    typealias RoundedCorners = RoundedCornersTransform
    typealias SecureForWork = SecureForWorkTransform
    typealias Sepia = SepiaTransform
    typealias Shadow = ShadowTransform
    typealias Sharpen = SharpenTransform
    typealias TornEdges = TornEdgesTransform
    typealias Upscale = UpscaleTransform
    typealias URLScreenshot = URLScreenshotTransform
    typealias Vignette = VignetteTransform
    typealias Watermark = WatermarkTransform
    typealias Zip = ZipTransform

    // Deprecations
    @available(*, deprecated, renamed: "RoundedCorners") typealias RoundCorners = RoundedCorners
    @available(*, deprecated, renamed: "URLScreenshot") typealias UrlScreenshot = URLScreenshot
}

extension Transform {

    @discardableResult func appending(key: String, value: Any?) -> Self {
        options.append((key: key, value: value))

        return self
    }

    func removeAllOptions() {
        options.removeAll()
    }
}
