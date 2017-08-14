//
//  ImageTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an `ImageTransform` object.

    See [Filestack Architecture Overview](https://www.filestack.com/docs/image-transformations) for more information
    about image transformations.
 */
@objc(FSImageTransform) public class ImageTransform: NSObject {


    // MARK: - Public Properties

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A Filestack Handle. `nil` by default.
    public let handle: String?

    /// An external URL. `nil` by default.
    public let externalURL: URL?

    /// An URL corresponding to this image transform.
    public var url: URL {

        return computeURL()
    }


    // MARK: - Private Properties

    private typealias TaskOption = (key: String, value: Any?)
    private typealias Task = (name: String, options: [TaskOption]?)
    private var transformationTasks: [Task] = [Task]()


    // MARK: - Lifecyle Functions

    internal init(handle: String, apiKey: String, security: Security? = nil) {

        self.handle = handle
        self.externalURL = nil
        self.apiKey = apiKey
        self.security = security

        super.init()
    }

    internal init(externalURL: URL, apiKey: String, security: Security? = nil) {

        self.handle = nil
        self.externalURL = externalURL
        self.apiKey = apiKey
        self.security = security

        super.init()
    }


    // MARK: - Public Functions

    /**
        Resizes the image to a given width and height using a particular fit and alignment mode.
     
        - Parameter width: The new width in pixels. Valid range: `1...10000`
        - Parameter height: The new height in pixels. Valid range: `1...10000`
        - Parameter fit: An `ImageTransformFit` value.
        - Parameter align: An `ImageTransformAlign` value.
     */
    @discardableResult public func resize(width: Int? = nil,
                                          height: Int? = nil,
                                          fit: ImageTransformFit? = nil,
                                          align: ImageTransformAlign? = nil) -> Self {

        var options = [TaskOption]()

        if let width = width {
            options.append((key: "width", value: width))
        }

        if let height = height {
            options.append((key: "height", value: height))
        }

        if let fit = fit {
            options.append((key: "fit", value: fit))
        }

        if let align = align {
            options.append((key: "align", value: align))
        }

        let task = Task(name: "resize", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Crops the image to a specified rectangle.
     
        - Parameter x: The starting point X coordinate.
        - Parameter y: The starting point Y coordinate.
        - Parameter width: The output image's width.
        - Parameter height: The output image's height.
     */
    @discardableResult public func crop(x: Int, y: Int, width: Int, height: Int) -> Self {

        let task = Task(name: "crop", options: [(key: "dim", value: [x, y, width, height])])

        transformationTasks.append(task)

        return self
    }

    /**
        Rotates the image in a range from 0 to 359 degrees.

        - Parameter deg: The rotation angle in degrees. Valid range: `0...359`
        - Parameter exif: If `true`, sets the Exif orientation of the image to Exif orientation 1.
            A `false` value takes an image and sets the exif orientation to the first of the eight 
            EXIF orientations. The image will behave as though it is contained in an html img tag 
            if displayed in an application that supports Exif orientations.
        - Parameter background: The background color to display if the image is rotated less 
            than a full 90 degrees.
     */
    @discardableResult public func rotate(deg: Int, exif: Bool? = nil, background: UIColor? = nil) -> Self {

        return pRotate(deg: deg, exif: exif, background: background)
    }

    /**
        Rotates the image based on Exif information.

        - Parameter exif: If `true`, sets the Exif orientation of the image to Exif orientation 1.
        A `false` value takes an image and sets the exif orientation to the first of the eight
        EXIF orientations. The image will behave as though it is contained in an html img tag
        if displayed in an application that supports Exif orientations.
        - Parameter background: The background color to display if the image is rotated less
        than a full 90 degrees.
     */
    @discardableResult public func rotateDegExif(exif: Bool? = nil, background: UIColor? = nil) -> Self {

        return pRotate(deg: "exif", exif: exif, background: background)
    }

    /**
        Flips/mirrors the image vertically.
     */
    @discardableResult public func flip() -> Self {

        let task = Task(name: "flip", options: nil)

        transformationTasks.append(task)

        return self
    }

    /**
        Flips/mirrors the image horizontally.
     */
    @discardableResult public func flop() -> Self {

        let task = Task(name: "flop", options: nil)

        transformationTasks.append(task)

        return self
    }

    /**
        Watermarks the image by overlaying another image on top of your main image.
     
        - Parameter file: The Filestack handle of the image that you want to layer on top of 
            another image as a watermark.
        - Parameter size: The size of the overlayed image as a percentage of its original size. 
            Valid range: `1...500`
        - Parameter position: The position of the overlayed image. These values can be paired as 
            well like position: [.top, .right].
     */
    @discardableResult public func watermark(file: String, size: Int? = nil, position: [ImageTransformPosition]? = nil) -> Self {

        var options = [TaskOption]()

        options.append((key: "file", value: file))

        if let size = size {
            options.append((key: "size", value: size))
        }

        if let position = position {
            options.append((key: "position", value: position))
        }

        let task = Task(name: "watermark", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Detects the faces contained inside an image.
     
        - Parameter minSize: This parameter is used to weed out objects that most likely 
            are not faces. Valid range: `0.01...10000`
        - Parameter maxSize: This parameter is used to weed out objects that most likely
            are not faces. Valid range: `0.01...10000`
        - Parameter color: Will change the color of the "face object" boxes and text. 
        - Parameter export: If true, it will export all face objects to a JSON object.
     */
    @discardableResult public func detectFaces(minSize: Float? = nil,
                                               maxSize: Float? = nil,
                                               color: UIColor? = nil,
                                               export: Bool? = nil) -> Self {

        var options = [TaskOption]()

        if let minSize = minSize {
            options.append((key: "minsize", value: minSize))
        }

        if let maxSize = maxSize {
            options.append((key: "maxsize", value: maxSize))
        }

        if let color = color {
            options.append((key: "color", value: color.hexString))
        }

        if let export = export {
            options.append((key: "export", value: export))
        }

        let task = Task(name: "detect_faces", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Crops selected faces contained inside an image.
     
        - Parameter mode: An `ImageTransformCropMode` value.
        - Parameter width: The crop's width.
        - Parameter height: The crop's height.
        - Parameter faces: The faces to be included in the crop.
     */
    @discardableResult public func cropFaces(mode: ImageTransformCropMode,
                                             width: Int? = nil,
                                             height: Int? = nil,
                                             faces: [Int]? = nil) -> Self {

        return pCropFaces(mode: mode, width: width, height: height, faces: faces)
    }

    /**
        Crops all the faces contained inside an image.

        - Parameter mode: An `ImageTransformCropMode` value.
        - Parameter width: The crop's width.
        - Parameter height: The crop's height.
     */
    @discardableResult public func cropFacesAll(mode: ImageTransformCropMode,
                                                width: Int? = nil,
                                                height: Int? = nil) -> Self {

        return pCropFaces(mode: mode, width: width, height: height, faces: "all")
    }

    /**
        Pixelates selected faces contained inside an image.

        - Parameter faces: The faces to be pixelated.
        - Parameter minSize: This parameter is used to weed out objects that most likely
            are not faces. Valid range: `0.01...10000`
        - Parameter maxSize: This parameter is used to weed out objects that most likely
            are not faces. Valid range: `0.01...10000`
        - Parameter buffer: Adjusts the buffer around the face object as a percentage of 
            the original object. Valid range: `0...1000`
        - Parameter blur: The amount to blur the pixelated faces. Valid range: `0...20`
        - Parameter type: An `ImageTransformPixelateFacesType` value.
     */
    @discardableResult public func pixelateFaces(faces: [Int],
                                                 minSize: Float? = nil,
                                                 maxSize: Float? = nil,
                                                 buffer: Int,
                                                 blur: Float? = nil,
                                                 type: ImageTransformPixelateFacesType? = nil) -> Self {

        return pPixelateFaces(faces: faces,
                              minSize: minSize,
                              maxSize: maxSize,
                              buffer: buffer,
                              blur: blur,
                              type: type)
    }

    /**
        Pixelates all the faces contained inside an image.

        - Parameter minSize: This parameter is used to weed out objects that most likely
        are not faces. Valid range: `0.01...10000`
        - Parameter maxSize: This parameter is used to weed out objects that most likely
        are not faces. Valid range: `0.01...10000`
        - Parameter buffer: Adjusts the buffer around the face object as a percentage of
        the original object. Valid range: `0...1000`
        - Parameter blur: The amount to blur the pixelated faces. Valid range: `0...20`
        - Parameter type: An `ImageTransformPixelateFacesType` value.
     */
    @discardableResult public func pixelateFacesAll(minSize: Float? = nil,
                                                    maxSize: Float? = nil,
                                                    buffer: Int,
                                                    blur: Float? = nil,
                                                    type: ImageTransformPixelateFacesType? = nil) -> Self {

        return pPixelateFaces(faces: "all",
                              minSize: minSize,
                              maxSize: maxSize,
                              buffer: buffer,
                              blur: blur,
                              type: type)
    }

    /**
        Rounds the image's corners.
     
        - Parameter radius: The radius of the rounded corner effect on your image. 
            Valid range: `1...10000`
        - Parameter blur: Specify the amount of blur to apply to the rounded edges of the image.
            Valid range: `0...20`
        - Parameter background: Sets the background color to display where the rounded corners 
            have removed part of the image.
     */
    @discardableResult public func roundCorners(radius: Int? = nil,
                                                blur: Float? = nil,
                                                background: UIColor? = nil) -> Self {

        return pRoundCorners(radius: radius, blur: blur, background: background)
    }

    /**
        Rounds the image's corners using max radius.

        - Parameter blur: Specify the amount of blur to apply to the rounded edges of the image.
        Valid range: `0...20`
        - Parameter background: Sets the background color to display where the rounded corners
        have removed part of the image.
     */
    @discardableResult public func roundCornersMaxRadius(blur: Float? = nil,
                                                         background: UIColor? = nil) -> Self {

        return pRoundCorners(radius: "max", blur: blur, background: background)
    }

    /**
        Applies a vignette border effect to the image.
     
        - Parameter amount: Controls the opacity of the vignette effect. Valid range: `0...100`
        - Parameter blurMode: An `ImageTransformBlurMode` value.
        - Parameter background: Replaces the default transparent background with the specified color.
     */
    @discardableResult public func vignette(amount: Int? = nil,
                                            blurMode: ImageTransformBlurMode? = nil,
                                            background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let amount = amount {
            options.append((key: "amount", value: amount))
        }

        if let blurMode = blurMode {
            options.append((key: "blurmode", value: String(describing: blurMode)))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "vignette", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a Polaroid border effect to the image.
     
        - Parameter color: Sets the Polaroid frame color.
        - Parameter rotate: The degree by which to rotate the image clockwise. 
            Valid range: `0...359`
        - Parameter background: Sets the background color to display behind the Polaroid if
            it has been rotated at all.
     */
    @discardableResult public func polaroid(color: UIColor? = nil,
                                            rotate: Int? = nil,
                                            background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let color = color {
            options.append((key: "color", value: color.hexString))
        }

        if let rotate = rotate {
            options.append((key: "rotate", value: String(describing: rotate)))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "polaroid", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a torn edge border effect to the image.
     
        - Parameter spread: Sets the spread of the tearing effect. Valid range: `1...10000`
        - Parameter background: Sets the background color to display behind the torn edge effect.
     */
    @discardableResult public func tornEdges(spread: [Int]? = nil,
                                             background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let spread = spread {
            options.append((key: "spread", value: spread))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "torn_edges", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a shadow border effect to the image.
     
        - Parameter blur: Sets the level of blur for the shadow effect. Valid range: `0...20`
        - Parameter opacity: Sets the opacity level of the shadow effect. Vaid range: `0 to 100`
        - Parameter vector: Sets the vector of the shadow effect. The value must be an array of 
            two integers in a range from -1000 to 1000.
        - Parameter color: Sets the shadow color.
        - Parameter background: Sets the background color to display behind the image, 
            like a matte the shadow is cast on.
     */
    @discardableResult public func shadow(blur: Int? = nil,
                                          opacity: Int? = nil,
                                          vector: [Int]? = nil,
                                          color: UIColor? = nil,
                                          background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let blur = blur {
            options.append((key: "blur", value: blur))
        }

        if let opacity = opacity {
            options.append((key: "opacity", value: opacity))
        }

        if let vector = vector {
            options.append((key: "vector", value: vector))
        }

        if let color = color {
            options.append((key: "color", value: color.hexString))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "shadow", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a circle border effect to the image.
     
        - Parameter background: Sets the background color to display behind the image.
     */
    @discardableResult public func circle(background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "circle", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a border effect to the image.
     
        - Parameter width: Sets the width in pixels of the border to render around the image.
            Valid range: `1...1000`
        - Parameter color: Sets the color of the border to render around the image.
        - Parameter background: Sets the background color to display behind the image.
     */
    @discardableResult public func border(width: Int? = nil,
                                          color: UIColor? = nil,
                                          background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let width = width {
            options.append((key: "width", value: width))
        }

        if let color = color {
            options.append((key: "color", value: color.hexString))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "border", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a sharpening effect to the image.
     
        - Parameter amount: The amount to sharpen the image. Valid range: `1...20`
     */
    @discardableResult public func sharpen(amount: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let amount = amount {
            options.append((key: "amount", value: amount))
        }

        let task = Task(name: "sharpen", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Applies a blurring effect to the image.

        - Parameter amount: The amount to blur the image. Valid range: `1...20`
     */
    @discardableResult public func blur(amount: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let amount = amount {
            options.append((key: "amount", value: amount))
        }

        let task = Task(name: "blur", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Converts the image to monochrome.
     */
    @discardableResult public func monochrome() -> Self {

        let task = Task(name: "monochrome", options: nil)

        transformationTasks.append(task)

        return self
    }

    /**
        Converts the image to black and white.
     
        - Parameter threshold: Controls the balance between black and white (contrast) in 
            the returned image. Valid range: `1...100`
     */
    @discardableResult public func blackAndWhite(threshold: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let threshold = threshold {
            options.append((key: "threshold", value: threshold))
        }

        let task = Task(name: "blackwhite", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Converts the image to sepia color.
     
        - Parameter tone: The value to set the sepia tone to. Valid range: `0...100`
     */
    @discardableResult public func sepia(tone: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let tone = tone {
            options.append((key: "tone", value: tone))
        }

        let task = Task(name: "sepia", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Converts the image to a different format.
     
        - Parameter format: The format to which you would like to convert the file.
            See [Filetype Conversions - Output](https://www.filestack.com/docs/image-transformations/conversion)
            for more information on supported formats.
        - Parameter background: Set a background color when converting transparent .png files 
            into other file types.
        - Parameter page: If you are converting a file that contains multiple pages such as a PDF 
            or PowerPoint file, you can extract a specific page using the page parameter.
            Valid range: `1...10000`
        - Parameter density: You can adjust the density when converting documents like PowerPoint, 
            PDF, AI and EPS files to image formats like JPG or PNG. Valid range: `1...500`
        - Parameter compress: If true, takes advantage of Filestack's image compression which utilizes
            JPEGtran and OptiPNG.
        - Parameter quality: You can change the quality (and reduce the file size) of JPEG images 
            by using the quality parameter. Valid range: `1...100`
        - Parameter strip: If true, it will remove any metadata embedded in an image.
        - Parameter colorSpace: An `ImageTransformColorSpace` value.
        - Parameter secure: This parameter applies to conversions of HTML and SVG sources. 
            If true, the HTML or SVG file will be stripped of any insecure tags (HTML sanitization).
        - Parameter docInfo: The docinfo parameter can be used to get information about a document, 
            such as the number of pages and the dimensions of the file. This information is 
            delivered as a JSON object that will look like this: 
            ```
            {
                "numpages":41,
                "dimensions":
                    {
                        "width":538,
                        "height":718
                    }
            }
            ```
        - Parameter pageFormat: An `ImageTransformPageFormat` value.
        - Parameter pageOrientation: An `ImageTransformPageOrientation` value.
     */
    @discardableResult public func convert(format: String,
                                           background: UIColor? = nil,
                                           page: Int? = nil,
                                           density: Int? = nil,
                                           compress: Bool? = nil,
                                           quality: Int? = nil,
                                           strip: Bool? = nil,
                                           colorSpace: ImageTransformColorSpace? = nil,
                                           secure: Bool? = nil,
                                           docInfo: Bool? = nil,
                                           pageFormat: ImageTransformPageFormat? = nil,
                                           pageOrientation: ImageTransformPageOrientation? = nil) -> Self {

        return pConvert(format: format,
                        background: background,
                        page: page,
                        density: density,
                        compress: compress,
                        quality: quality,
                        strip: strip,
                        colorSpace: colorSpace,
                        secure: secure,
                        docInfo: docInfo,
                        pageFormat: pageFormat,
                        pageOrientation: pageOrientation)
    }

    /**
        Converts the image to a different format preserving the input quality.

        - Parameter format: The format to which you would like to convert the file.
            See [Filetype Conversions - Output](https://www.filestack.com/docs/image-transformations/conversion)
            for more information on supported formats.
        - Parameter background: Set a background color when converting transparent .png files
            into other file types.
        - Parameter page: If you are converting a file that contains multiple pages such as a PDF
            or PowerPoint file, you can extract a specific page using the page parameter.
            Valid range: `1...10000`
        - Parameter density: You can adjust the density when converting documents like PowerPoint,
            PDF, AI and EPS files to image formats like JPG or PNG. Valid range: `1...500`
        - Parameter compress: If true, takes advantage of Filestack's image compression which utilizes
            JPEGtran and OptiPNG.
        - Parameter strip: If true, it will remove any metadata embedded in an image.
        - Parameter colorSpace: An `ImageTransformColorSpace` value.
        - Parameter secure: This parameter applies to conversions of HTML and SVG sources.
            If true, the HTML or SVG file will be stripped of any insecure tags (HTML sanitization).
        - Parameter docInfo: The docinfo parameter can be used to get information about a document,
            such as the number of pages and the dimensions of the file. This information is
            delivered as a JSON object that will look like this:
            ```
            {
                "numpages":41,
                "dimensions":
                {
                    "width":538,
                    "height":718
                }
            }
            ```
        - Parameter pageFormat: An `ImageTransformPageFormat` value.
        - Parameter pageOrientation: An `ImageTransformPageOrientation` value.
     */
    @discardableResult public func convertPreservingInputQuality(format: String,
                                                                 background: UIColor? = nil,
                                                                 page: Int? = nil,
                                                                 density: Int? = nil,
                                                                 compress: Bool? = nil,
                                                                 strip: Bool? = nil,
                                                                 colorSpace: ImageTransformColorSpace? = nil,
                                                                 secure: Bool? = nil,
                                                                 docInfo: Bool? = nil,
                                                                 pageFormat: ImageTransformPageFormat? = nil,
                                                                 pageOrientation: ImageTransformPageOrientation? = nil) -> Self {

        return pConvert(format: format,
                        background: background,
                        page: page,
                        density: density,
                        compress: compress,
                        quality: "input",
                        strip: strip,
                        colorSpace: colorSpace,
                        secure: secure,
                        docInfo: docInfo,
                        pageFormat: pageFormat,
                        pageOrientation: pageOrientation)
    }

    /**
        Removes any metadata embedded in an image.
     */
    @discardableResult public func noMetadata() -> Self {

        let task = Task(name: "no_metadata", options: nil)

        transformationTasks.append(task)

        return self
    }

    /**
        Set the quality of your JPG or WEBP image without the danger of possibly generating 
        a larger file.
     
        - Parameter value: This task will take a JPG or WEBP file and reduce the file size of 
            the image by reducing the quality. If the file is not a JPG, the original file will 
            be returned. If after the conversion, the resulting file is not smaller than the 
            original, the original file will be returned. Valid range: `1...100`
     */
    @discardableResult public func quality(value: Int) -> Self {

        var options = [TaskOption]()

        options.append((key: "value", value: value))

        let task = Task(name: "quality", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Takes the file or files that are passed into it and compresses them into a zip file.
     */
    @discardableResult public func zip() -> Self {

        let task = Task(name: "zip", options: nil)

        transformationTasks.append(task)

        return self
    }

    /**
        Converts a video to a different format, resolution, etc.
     
        - Parameter preset: The format to convert to. 
            See (File Processing - Video Conversion)[https://www.filestack.com/docs/video-transformations] 
            for more information about supported presets.
        - Parameter force: Restarts completed or pending video encoding. If a transcoding fails, 
            and you make the same request again, it will not restart the transcoding process unless
            this parameter is set to `true`.
        - Parameter width: Set the width in pixels of the video that is generated by the transcoding 
            process.
        - Parameter height: Set the height in pixels of the video that is generated by the 
            transcoding process.
        - Parameter title: Set the title in the file metadata.
        - Parameter extName: Set the file extension for the video that is generated by the 
            transcoding process.
        - Parameter fileName: Set the filename of the video that is generated by the transcoding 
            process.
        - Parameter location: An `StorageLocation` value.
        - Parameter path: The path to store the file at within the specified file store. 
            For S3, this is the key where the file will be stored at. By default, Filestack stores 
            the file at the root at a unique id, followed by an underscore, followed by the 
            filename, for example: `3AB239102DB_myvideo.mp4`.
        - Parameter `access`: An `StorageAccess` value.
        - Parameter container: The bucket or container in the specified file store where the file 
            should end up.
        - Parameter upscale: Upscale the video resolution to match your profile. Defaults to `true`.
        - Parameter aspectMode: An `ImageTransformAspectMode` value.
        - Parameter twoPass: Specify that the transcoding process should do two passes to improve 
            video quality. Defaults to `false`.
        - Parameter videoBitRate: Specify the video bitrate for the video that is generated by the 
            transcoding process. Valid range: `1...5000`
        - Parameter fps: Specify the frames per second of the video that is generated by the 
            transcoding process. Valid range: `1...300`. If ommited, uses the original fps of 
            the source file.
        - Parameter keyframeInterval: Adds a key frame every `keyframeInterval` frames to the video 
            that is generated by the transcoding process. Default is `250`.
        - Parameter audioBitRate: Sets the audio bitrate for the video that is generated by the 
            transcoding process. Valid range: `0...999`
        - Parameter audioSampleRate: Set the audio sample rate for the video that is generated by 
            the transcoding process. Valid range: `0...99999`. Default is `44100`.
        - Parameter audioChannels: Set the number of audio channels for the video that is generated 
            by the transcoding process. Valid range: `1...12`. Default is same as source video.
        - Parameter clipLength: Set the length of the video that is generated by the transcoding 
            process. Valid format should include hours, minutes and seconds.
        - Parameter clipOffset: Set the point to begin the video clip from. For example, `00:00:10`
            will start the video transcode 10 seconds into the source video. Valid format should 
            include hours, minutes and seconds.
        - Parameter watermarkURL: The Filestack handle or URL of the image file to use as a 
            watermark on the transcoded video.
        - Parameter watermarkTop: The distance from the top of the video frame to place the 
            watermark on the video. Valid range: `0...9999`
        - Parameter watermarkBottom: The distance from the bottom of the video frame to place the 
            watermark on the video. Valid range: `0...9999`
        - Parameter watermarkLeft: The distance from the left side of the video frame to place the 
            watermark on the video. Valid range: `0...9999`
        - Parameter watermarkRight: The distance from the right side of the video frame to place the 
            watermark on the video. Valid range: `0...9999`
        - Parameter watermarkWidth: Resize the width of the watermark.
        - Parameter watermarkHeight: Resize the height of the watermark.
     */
    @discardableResult public func videoConvert(preset: String,
                                                force: Bool? = nil,
                                                width: Int? = nil,
                                                height: Int? = nil,
                                                title: String? = nil,
                                                extName: String? = nil,
                                                fileName: String? = nil,
                                                location: StorageLocation? = nil,
                                                path: String? = nil,
                                                `access`: StorageAccess? = nil,
                                                container: String? = nil,
                                                upscale: Bool? = nil,
                                                aspectMode: ImageTransformAspectMode? = nil,
                                                twoPass: Bool? = nil,
                                                videoBitRate: Int? = nil,
                                                fps: Int? = nil,
                                                keyframeInterval: Int? = nil,
                                                audioBitRate: Int? = nil,
                                                audioSampleRate: Int? = nil,
                                                audioChannels: Int? = nil,
                                                clipLength: String? = nil,
                                                clipOffset: String? = nil,
                                                watermarkURL: URL? = nil,
                                                watermarkTop: Int? = nil,
                                                watermarkBottom: Int? = nil,
                                                watermarkLeft: Int? = nil,
                                                watermarkRight: Int? = nil,
                                                watermarkWidth: Int? = nil,
                                                watermarkHeight: Int? = nil) -> Self {

        var options = [TaskOption]()

        options.append((key: "preset", value: preset))

        if let force = force {
            options.append((key: "force", value: force))
        }

        if let width = width {
            options.append((key: "width", value: width))
        }

        if let height = height {
            options.append((key: "height", value: height))
        }

        if let title = title {
            options.append((key: "title", value: title))
        }

        if let extName = extName {
            options.append((key: "extname", value: extName))
        }

        if let fileName = fileName {
            options.append((key: "filename", value: fileName))
        }

        if let location = location {
            options.append((key: "location", value: location))
        }

        if let path = path {
            options.append((key: "path", value: path))
        }

        if let access = access {
            options.append((key: "access", value: access))
        }

        if let container = container {
            options.append((key: "container", value: container))
        }

        if let upscale = upscale {
            options.append((key: "upscale", value: upscale))
        }

        if let aspectMode = aspectMode {
            options.append((key: "aspect_mode", value: aspectMode))
        }

        if let twoPass = twoPass {
            options.append((key: "two_pass", value: twoPass))
        }

        if let videoBitRate = videoBitRate {
            options.append((key: "video_bitrate", value: videoBitRate))
        }

        if let fps = fps {
            options.append((key: "fps", value: fps))
        }

        if let keyframeInterval = keyframeInterval {
            options.append((key: "keyframe_interval", value: keyframeInterval))
        }

        if let audioBitRate = audioBitRate {
            options.append((key: "audio_bitrate", value: audioBitRate))
        }

        if let audioSampleRate = audioSampleRate {
            options.append((key: "audio_samplerate", value: audioSampleRate))
        }

        if let audioChannels = audioChannels {
            options.append((key: "audio_channels", value: audioChannels))
        }

        if let clipLength = clipLength {
            options.append((key: "clip_length", value: clipLength))
        }

        if let clipOffset = clipOffset {
            options.append((key: "clip_offset", value: clipOffset))
        }

        if let watermarkURL = watermarkURL {
            options.append((key: "watermark_url", value: watermarkURL))
        }

        if let watermarkTop = watermarkTop {
            options.append((key: "watermark_top", value: watermarkTop))
        }

        if let watermarkBottom = watermarkBottom {
            options.append((key: "watermark_bottom", value: watermarkBottom))
        }

        if let watermarkLeft = watermarkLeft {
            options.append((key: "watermark_left", value: watermarkLeft))
        }

        if let watermarkRight = watermarkRight {
            options.append((key: "watermark_right", value: watermarkRight))
        }

        if let watermarkWidth = watermarkWidth {
            options.append((key: "watermark_width", value: watermarkWidth))
        }

        if let watermarkHeight = watermarkHeight {
            options.append((key: "watermark_height", value: watermarkHeight))
        }

        let task = Task(name: "video_convert", options: options)

        transformationTasks.append(task)

        return self
    }

    /**
        Converts an audio file to a different format, bitrate, etc.

        - Parameter preset: The format to convert to.
            See (File Processing - Video Conversion)[https://www.filestack.com/docs/video-transformations]
            for more information about supported presets.
        - Parameter force: Restarts completed or pending video encoding. If a transcoding fails,
            and you make the same request again, it will not restart the transcoding process unless
            this parameter is set to `true`.
        - Parameter title: Set the title in the file metadata.
        - Parameter extName: Set the file extension for the video that is generated by the
            transcoding process.
        - Parameter fileName: Set the filename of the video that is generated by the transcoding
            process.
        - Parameter location: An `StorageLocation` value.
        - Parameter path: The path to store the file at within the specified file store.
            For S3, this is the key where the file will be stored at. By default, Filestack stores
            the file at the root at a unique id, followed by an underscore, followed by the
            filename, for example: `3AB239102DB_myvideo.mp4`.
        - Parameter `access`: An `StorageAccess` value.
        - Parameter container: The bucket or container in the specified file store where the file
            should end up.
        - Parameter audioBitRate: Sets the audio bitrate for the video that is generated by the
            transcoding process. Valid range: `0...999`
        - Parameter audioSampleRate: Set the audio sample rate for the video that is generated by
            the transcoding process. Valid range: `0...99999`. Default is `44100`.
        - Parameter audioChannels: Set the number of audio channels for the video that is generated
            by the transcoding process. Valid range: `1...12`. Default is same as source video.
        - Parameter clipLength: Set the length of the video that is generated by the transcoding
            process. Valid format should include hours, minutes and seconds.
        - Parameter clipOffset: Set the point to begin the video clip from. For example, `00:00:10`
            will start the video transcode 10 seconds into the source video. Valid format should
            include hours, minutes and seconds.
     */
    @discardableResult public func audioConvert(preset: String,
                                                force: Bool? = nil,
                                                title: String? = nil,
                                                extName: String? = nil,
                                                fileName: String? = nil,
                                                location: StorageLocation? = nil,
                                                path: String? = nil,
                                                `access`: StorageAccess? = nil,
                                                container: String? = nil,
                                                audioBitRate: Int? = nil,
                                                audioSampleRate: Int? = nil,
                                                audioChannels: Int? = nil,
                                                clipLength: String? = nil,
                                                clipOffset: String? = nil) -> Self {

        return videoConvert(preset: preset,
                            force: force,
                            title: title,
                            extName: extName,
                            fileName: fileName,
                            location: location,
                            path: path,
                            access: access,
                            container: container,
                            audioBitRate: audioBitRate,
                            audioSampleRate: audioSampleRate,
                            audioChannels: audioChannels,
                            clipLength: clipLength,
                            clipOffset: clipOffset)
    }

    /**
        Includes detailed information about the transformation request.
     */
    @discardableResult public func debug() -> Self {

        let task = Task(name: "debug", options: nil)

        transformationTasks.insert(task, at: 0)

        return self
    }

    /**
        Stores a copy of the transformation results to your preferred filestore.
     
        - Parameter fileName: Change or set the filename for the converted file.
        - Parameter location: An `StorageLocation` value.
        - Parameter path: Where to store the file in your designated container. For S3, this is 
            the key where the file will be stored at.
        - Parameter container: The name of the bucket or container to write files to.
        - Parameter region: S3 specific parameter. The name of the S3 region your bucket is located 
            in. All regions except for `eu-central-1` (Frankfurt), `ap-south-1` (Mumbai),
            and `ap-northeast-2` (Seoul) will work.
        - Parameter access: An `StorageAccess` value.
        - Parameter base64Decode: Specify that you want the data to be first decoded from base64 
            before being written to the file. For example, if you have base64 encoded image data, 
            you can use this flag to first decode the data before writing the image file.
        - Parameter queue: The queue on which the completion handler is dispatched.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    @discardableResult public func store(fileName: String? = nil,
                                         location: StorageLocation? = nil,
                                         path: String? = nil,
                                         container: String? = nil,
                                         region: String? = nil,
                                         access: StorageAccess? = nil,
                                         base64Decode: Bool? = nil,
                                         queue: DispatchQueue? = .main,
                                         completionHandler: @escaping (FileLink?, NetworkJSONResponse) -> Void) -> Self {

        var options = [TaskOption]()

        if let fileName = fileName {
            options.append((key: "filename", value: fileName))
        }

        if let location = location {
            options.append((key: "location", value: location))
        }

        if let path = path {
            options.append((key: "path", value: path))
        }

        if let container = container {
            options.append((key: "container", value: container))
        }

        if let region = region {
            options.append((key: "region", value: region))
        }

        if let access = access {
            options.append((key: "access", value: access))
        }

        if let base64Decode = base64Decode {
            options.append((key: "base64decode", value: base64Decode))
        }

        let task = Task(name: "store", options: options)

        transformationTasks.insert(task, at: 0)


        // Create and perform post request

        guard let request = processService.request(url: url, method: .post) else { return self }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(queue: queue ?? .main) { (response) in

            let jsonResponse = NetworkJSONResponse(with: response)
            var fileLink: FileLink?

            if let json = jsonResponse.json,
               let urlString = json["url"] as? String,
               let url = URL(string: urlString) {

                fileLink = FileLink(handle: url.lastPathComponent, apiKey: self.apiKey, security: self.security)
            }

            completionHandler(fileLink, jsonResponse)

            return
        }

        return self
    }


    // MARK: - Private Functions

    @discardableResult private func pRotate(deg: Any? = nil, exif: Bool? = nil, background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let deg = deg {
            options.append((key: "deg", value: deg))
        }

        if let exif = exif {
            options.append((key: "exif", value: exif))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "rotate", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult private func pCropFaces(mode: ImageTransformCropMode? = nil,
                                               width: Int? = nil,
                                               height: Int? = nil,
                                               faces: Any? = nil) -> Self {

        var options = [TaskOption]()

        if let mode = mode {
            options.append((key: "mode", value: String(describing: mode)))
        }

        if let width = width {
            options.append((key: "width", value: width))
        }

        if let height = height {
            options.append((key: "height", value: height))
        }

        if let faces = faces {
            options.append((key: "faces", value: faces))
        }

        let task = Task(name: "crop_faces", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult private func pPixelateFaces(faces: Any,
                                                   minSize: Float? = nil,
                                                   maxSize: Float? = nil,
                                                   buffer: Int,
                                                   blur: Float? = nil,
                                                   type: ImageTransformPixelateFacesType? = nil) -> Self {

        var options = [TaskOption]()

        options.append((key: "faces", value: faces))

        if let minSize = minSize {
            options.append((key: "minsize", value: minSize))
        }

        if let maxSize = maxSize {
            options.append((key: "maxsize", value: maxSize))
        }

        options.append((key: "buffer", value: buffer))

        if let blur = blur {
            options.append((key: "blur", value: blur))
        }

        if let type = type {
            options.append((key: "type", value: String(describing: type)))
        }

        let task = Task(name: "pixelate_faces", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult private func pRoundCorners(radius: Any? = nil,
                                                  blur: Float? = nil,
                                                  background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let radius = radius {
            options.append((key: "radius", value: radius))
        }

        if let blur = blur {
            options.append((key: "blur", value: blur))
        }

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "round_corners", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult private func pConvert(format: String,
                                             background: UIColor? = nil,
                                             page: Int? = nil,
                                             density: Int? = nil,
                                             compress: Bool? = nil,
                                             quality: Any? = nil,
                                             strip: Bool? = nil,
                                             colorSpace: ImageTransformColorSpace? = nil,
                                             secure: Bool? = nil,
                                             docInfo: Bool? = nil,
                                             pageFormat: ImageTransformPageFormat? = nil,
                                             pageOrientation: ImageTransformPageOrientation? = nil) -> Self {

        var options = [TaskOption]()

        options.append((key: "format", value: format))

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        if let page = page {
            options.append((key: "page", value: page))
        }

        if let density = density {
            options.append((key: "density", value: density))
        }

        if let compress = compress {
            options.append((key: "compress", value: compress))
        }

        if let quality = quality {
            options.append((key: "quality", value: quality))
        }

        if let strip = strip {
            options.append((key: "strip", value: strip))
        }

        if let colorSpace = colorSpace {
            options.append((key: "colorspace", value: String(describing: colorSpace)))
        }

        if let secure = secure {
            options.append((key: "secure", value: secure))
        }

        if let docInfo = docInfo {
            options.append((key: "docinfo", value: docInfo))
        }

        if let pageFormat = pageFormat {
            options.append((key: "pageformat", value: String(describing: pageFormat)))
        }

        if let pageOrientation = pageOrientation {
            options.append((key: "pageorientation", value: String(describing: pageOrientation)))
        }

        let task = Task(name: "output", options: options)

        transformationTasks.append(task)

        return self
    }

    private func computeURL() -> URL {

        let tasks = tasksToURLFragment()

        if let handle = handle {
            return processService.buildURL(tasks: tasks, handle: handle, security: security)!
        } else {
            return processService.buildURL(tasks: tasks, externalURL: externalURL!, key: apiKey, security: security)!
        }
    }

    private func sanitize(string: String) -> String {

        let allowedCharacters = CharacterSet(charactersIn: ",").inverted

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
    }

    private func tasksToURLFragment() -> String {

        let tasks: [String] = transformationTasks.map {

            if let options = $0.options {
                let params: [String] = options.map {

                    switch $0.value {
                    case let array as [Any]:

                        return "\($0.key):[\((array.map { String(describing: $0) }).joined(separator: ","))]"

                    default:

                        if let value = $0.value as? String {
                            return "\($0.key):\(sanitize(string: value))"
                        } else if let value = $0.value {
                                return "\($0.key):\(value)"
                        } else {
                            return $0.key
                        }
                    }
                }

                if params.count > 0 {
                    return "\($0.name)=\(params.joined(separator: ","))"
                }
            }

            return $0.name
        }

        return tasks.joined(separator: "/")
    }
}
