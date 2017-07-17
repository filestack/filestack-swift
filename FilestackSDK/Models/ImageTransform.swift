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

    /// URL
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

    @discardableResult public func crop(x: Int, y: Int, width: Int, height: Int) -> Self {

        let task = Task(name: "crop", options: [(key: "dim", value: [x, y, width, height])])

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func rotate(deg: Int, exif: Bool? = nil, background: UIColor? = nil) -> Self {

        return pRotate(deg: deg, exif: exif, background: background)
    }

    @discardableResult public func rotate(exif: Bool, background: UIColor? = nil) -> Self {

        return pRotate(deg: nil, exif: exif, background: background)
    }

    @discardableResult public func rotateDegExif(exif: Bool? = nil, background: UIColor? = nil) -> Self {

        return pRotate(deg: "exif", exif: exif, background: background)
    }

    @discardableResult public func flip() -> Self {

        let task = Task(name: "flip", options: nil)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func flop() -> Self {

        let task = Task(name: "flop", options: nil)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func watermark(file: String, size: Int? = nil, position: ImageTransformPosition? = nil) -> Self {

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

    @discardableResult public func watermark(file: String, size: Int? = nil, position: [ImageTransformPosition]) -> Self {

        var options = [TaskOption]()

        options.append((key: "file", value: file))

        if let size = size {
            options.append((key: "size", value: size))
        }

        options.append((key: "position", value: position))

        let task = Task(name: "watermark", options: options)

        transformationTasks.append(task)

        return self
    }

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

    @discardableResult public func cropFaces(mode: ImageTransformCropMode,
                                             width: Int? = nil,
                                             height: Int? = nil,
                                             faces: Int? = nil) -> Self {

        return pCropFaces(mode: mode, width: width, height: height, faces: faces)
    }

    @discardableResult public func cropFaces(mode: ImageTransformCropMode,
                                             width: Int? = nil,
                                             height: Int? = nil,
                                             faces: [Int]) -> Self {

        return pCropFaces(mode: mode, width: width, height: height, faces: faces)
    }

    @discardableResult public func cropFacesAll(mode: ImageTransformCropMode,
                                                width: Int? = nil,
                                                height: Int? = nil) -> Self {

        return pCropFaces(mode: mode, width: width, height: height, faces: "all")
    }

    @discardableResult public func pixelateFaces(faces: Int,
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

    @discardableResult public func roundCorners(radius: Int? = nil,
                                                blur: Float? = nil,
                                                background: UIColor? = nil) -> Self {

        return pRoundCorners(radius: radius, blur: blur, background: background)
    }

    @discardableResult public func roundCornersMaxRadius(blur: Float? = nil,
                                                         background: UIColor? = nil) -> Self {

        return pRoundCorners(radius: "max", blur: blur, background: background)
    }

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

    @discardableResult public func circle(background: UIColor? = nil) -> Self {

        var options = [TaskOption]()

        if let background = background {
            options.append((key: "background", value: background.hexString))
        }

        let task = Task(name: "circle", options: options)

        transformationTasks.append(task)

        return self
    }

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

    @discardableResult public func sharpen(amount: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let amount = amount {
            options.append((key: "amount", value: amount))
        }

        let task = Task(name: "sharpen", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func blur(amount: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let amount = amount {
            options.append((key: "amount", value: amount))
        }

        let task = Task(name: "blur", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func monochrome() -> Self {

        let task = Task(name: "monochrome", options: nil)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func blackAndWhite(threshold: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let threshold = threshold {
            options.append((key: "threshold", value: threshold))
        }

        let task = Task(name: "blackwhite", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func sepia(tone: Int? = nil) -> Self {

        var options = [TaskOption]()

        if let tone = tone {
            options.append((key: "tone", value: tone))
        }

        let task = Task(name: "sepia", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func convert(format: String,
                                           background: UIColor? = nil,
                                           page: Int? = nil,
                                           density: Int? = nil,
                                           compress: Bool? = nil,
                                           quality: Int? = nil,
                                           strip: Bool? = nil,
                                           noMetadata: Bool? = nil,
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
                        noMetadata: noMetadata,
                        colorSpace: colorSpace,
                        secure: secure,
                        docInfo: docInfo,
                        pageFormat: pageFormat,
                        pageOrientation: pageOrientation)
    }

    @discardableResult public func convertPreservingInputQuality(format: String,
                                                                 background: UIColor? = nil,
                                                                 page: Int? = nil,
                                                                 density: Int? = nil,
                                                                 compress: Bool? = nil,
                                                                 strip: Bool? = nil,
                                                                 noMetadata: Bool? = nil,
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
                        noMetadata: noMetadata,
                        colorSpace: colorSpace,
                        secure: secure,
                        docInfo: docInfo,
                        pageFormat: pageFormat,
                        pageOrientation: pageOrientation)
    }

    @discardableResult public func quality(value: Int) -> Self {

        var options = [TaskOption]()

        options.append((key: "value", value: value))

        let task = Task(name: "quality", options: options)

        transformationTasks.append(task)

        return self
    }

    @discardableResult public func zip() -> Self {

        let task = Task(name: "zip", options: nil)

        transformationTasks.append(task)

        return self
    }

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

    @discardableResult func debug() -> Self {

        let task = Task(name: "debug", options: nil)

        transformationTasks.insert(task, at: 0)

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
                                             noMetadata: Bool? = nil,
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

        if let noMetadata = noMetadata, noMetadata == true {
            options.append((key: "no_metadata", value: nil))
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

        let tasks: [String] = transformationTasks.flatMap {

            if let options = $0.options {
                let params: [String] = options.flatMap {

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
