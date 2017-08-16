//
//  ImageTransformTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import FilestackSDK


class ImageTransformTests: XCTestCase {

    private let processStubConditions = isScheme(Config.processURL.scheme!) && isHost(Config.processURL.host!)

    override func tearDown() {

        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testResizeTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testResizeTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .resize(width: 50, fit: .crop, align: .center)

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,fit:crop,align:center")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .crop(x: 20, y: 30, width: 150, height: 250)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .rotate(deg: 320, exif: true, background: .white)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:320,exif:true,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateDegExifTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .rotateDegExif(exif: false, background: .red)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:exif,exif:false,background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .rotate(deg: 150)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:150")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testFlipTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .flip()

        let expectedURL = Config.processURL
            .appendingPathComponent("flip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testFlopTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .flop()

        let expectedURL = Config.processURL
            .appendingPathComponent("flop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testWatermarkTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.top])

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[top]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testWatermarkTransformationWithPairedPositionURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.top, .left])

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[top,left]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testWatermarkTransformationWithPairedPositionAndOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .watermark(file: "WATERMARK-HANDLE")

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: .white, export: true)

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .detectFaces(color:.red)

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=color:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .detectFaces()

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .cropFaces(mode: .fill, width: 250, height: 150, faces: [4])

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[4]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .cropFaces(mode: .thumb, faces: [1])

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:thumb,faces:[1]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithOptionals2URL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .cropFaces(mode: .crop)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:crop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithFacesArrayURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .cropFaces(mode: .fill, width: 250, height: 150, faces: [1,2,3,4])

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[1,2,3,4]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithFacesAllURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .cropFacesAll(mode: .fill, width: 250, height: 150)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:all")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .pixelateFaces(faces: [3], minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[3],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithFacesArrayURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .pixelateFaces(faces: [1,3,5], minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[1,3,5],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithFacesAllURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .pixelateFacesAll(minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:all,minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .pixelateFaces(faces: [4], buffer: 250)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[4],buffer:250")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionals2URL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .pixelateFaces(faces: [1,3,5], buffer: 320)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[1,3,5],buffer:320")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionals3URL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .pixelateFacesAll(buffer:220)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:all,buffer:220")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .roundCorners(radius: 150, blur: 0.8, background: .black)

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners=radius:150,blur:0.8,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .roundCorners()

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersMaxRadiusTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .roundCornersMaxRadius(blur: 0.25, background: .white)

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners=radius:max,blur:0.25,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersMaxRadiusTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .roundCornersMaxRadius()

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners=radius:max")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVignetteTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .vignette(amount: 80, blurMode: .gaussian, background: .black)

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette=amount:80,blurmode:gaussian,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVignetteTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .vignette()

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVignetteTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .vignette(amount: 35)

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette=amount:35")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPolaroidTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .polaroid(color: .white, rotate: 33, background: .black)

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid=color:FFFFFFFF,rotate:33,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPolaroidTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .polaroid()

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPolaroidTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .polaroid(rotate: 45)

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid=rotate:45")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTornEdgesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .tornEdges(spread: [5, 25], background: .blue)

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges=spread:[5,25],background:0000FFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTornEdgesTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .tornEdges()

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTornEdgesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .tornEdges(spread: [5, 25])

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges=spread:[5,25]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testShadowTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .shadow(blur: 10, opacity: 35, vector: [30, 30], color: .black, background: .white)

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow=blur:10,opacity:35,vector:[30,30],color:000000FF,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testShadowTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .shadow()

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testShadowTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .shadow(blur: 15, opacity: 20)

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow=blur:15,opacity:20")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCircleTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .circle(background: .red)

        let expectedURL = Config.processURL
            .appendingPathComponent("circle=background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCircleTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .circle()

        let expectedURL = Config.processURL
            .appendingPathComponent("circle")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBorderTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .border(width: 3, color: .white, background: .red)

        let expectedURL = Config.processURL
            .appendingPathComponent("border=width:3,color:FFFFFFFF,background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBorderTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .border()

        let expectedURL = Config.processURL
            .appendingPathComponent("border")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBorderTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .border(width: 5)

        let expectedURL = Config.processURL
            .appendingPathComponent("border=width:5")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSharpenTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .sharpen(amount: 3)

        let expectedURL = Config.processURL
            .appendingPathComponent("sharpen=amount:3")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSharpenTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .sharpen()

        let expectedURL = Config.processURL
            .appendingPathComponent("sharpen")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlurTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .blur(amount: 5)

        let expectedURL = Config.processURL
            .appendingPathComponent("blur=amount:5")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlurTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .blur()

        let expectedURL = Config.processURL
            .appendingPathComponent("blur")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testMonochromeTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .monochrome()

        let expectedURL = Config.processURL
            .appendingPathComponent("monochrome")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlackAndWhiteTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .blackAndWhite(threshold: 45)

        let expectedURL = Config.processURL
            .appendingPathComponent("blackwhite=threshold:45")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlackAndWhiteTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .blackAndWhite()

        let expectedURL = Config.processURL
            .appendingPathComponent("blackwhite")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSepiaTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .sepia(tone: 85)

        let expectedURL = Config.processURL
            .appendingPathComponent("sepia=tone:85")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSepiaTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .sepia()

        let expectedURL = Config.processURL
            .appendingPathComponent("sepia")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testConvertTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .convert(format: "pdf",
                     background: .white,
                     page: 1,
                     density: 100,
                     compress: true,
                     quality: 85,
                     strip: true,
                     colorSpace: ImageTransformColorSpace.input,
                     secure: true,
                     docInfo: true,
                     pageFormat: ImageTransformPageFormat.letter,
                     pageOrientation: ImageTransformPageOrientation.portrait)

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "output=format:pdf,background:FFFFFFFF,page:1,density:100,compress:true,quality:85,strip:true," +
                "colorspace:input,secure:true,docinfo:true,pageformat:letter,pageorientation:portrait"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testConvertTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .convert(format: "jpg",
                     compress: true,
                     strip: true,
                     colorSpace: .input)

        let expectedURL = Config.processURL
            .appendingPathComponent("output=format:jpg,compress:true,strip:true,colorspace:input")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testConvertPreservingInputQualityTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .convertPreservingInputQuality(format: "jpg",
                                           compress: true,
                                           colorSpace: .input)

        let expectedURL = Config.processURL
            .appendingPathComponent("output=format:jpg,compress:true,quality:input,colorspace:input")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testNoMetadataTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .noMetadata()

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "no_metadata"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testQualityTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .quality(value: 88)

        let expectedURL = Config.processURL
            .appendingPathComponent("quality=value:88")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testZipTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .zip()

        let expectedURL = Config.processURL
            .appendingPathComponent("zip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVideoConvertTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .videoConvert(preset: "h264",
                          force: false,
                          width: 1080,
                          height: 720,
                          title: "Chapter 1",
                          extName: "mp4",
                          fileName: "chapter_1",
                          location: .s3,
                          path: "/myfiles/chapter_1.mp4",
                          access: .public,
                          container: "user-videos",
                          upscale: false,
                          aspectMode: .preserve,
                          twoPass: true,
                          videoBitRate: 3200,
                          fps: 30,
                          keyframeInterval: 250,
                          audioBitRate: 320,
                          audioSampleRate: 44100,
                          audioChannels: 2,
                          clipLength: "00:02:30",
                          clipOffset: "00:00:05",
                          watermarkURL: URL(string:"https://SOME-EXTERNAL-URL")!,
                          watermarkTop: 20,
                          watermarkRight: 20,
                          watermarkWidth: 256,
                          watermarkHeight: 256)

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "video_convert=preset:h264,force:false,width:1080,height:720,title:Chapter 1," +
                "extname:mp4,filename:chapter_1,location:S3,path:/myfiles/chapter_1.mp4," +
                "access:public,container:user-videos,upscale:false,aspect_mode:preserve," +
                "two_pass:true,video_bitrate:3200,fps:30,keyframe_interval:250," +
                "audio_bitrate:320,audio_samplerate:44100,audio_channels:2," +
                "clip_length:00:02:30,clip_offset:00:00:05," +
                "watermark_url:https://SOME-EXTERNAL-URL,watermark_top:20,watermark_right:20," +
                "watermark_width:256,watermark_height:256"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVideoConvertWithTitleIncludingCommasTransformationURL() {

        let title = "Chapters 1,2,3 and 4"
        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .videoConvert(preset: "h264", title: title)

        let allowedCharacters = CharacterSet(charactersIn: ",").inverted
        let escapedTitle = title.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!

        let expectedURL = Config.processURL
            .appendingPathComponent("video_convert=preset:h264,title:\(escapedTitle)")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testAudioConvertTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .audioConvert(preset: "m4a",
                          force: false,
                          title: "Chapter 1",
                          extName: "m4a",
                          fileName: "chapter_1",
                          location: .s3,
                          path: "/myfiles/chapter_1.m4a",
                          access: .public,
                          container: "user-audios",
                          audioBitRate: 320,
                          audioSampleRate: 44100,
                          audioChannels: 2,
                          clipLength: "00:02:30",
                          clipOffset: "00:00:05")

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "video_convert=preset:m4a,force:false,title:Chapter 1," +
                "extname:m4a,filename:chapter_1,location:S3,path:/myfiles/chapter_1.m4a," +
                "access:public,container:user-audios," +
                "audio_bitrate:320,audio_samplerate:44100,audio_channels:2," +
                "clip_length:00:02:30,clip_offset:00:00:05"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDebugTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .flip()
            .flop()
            .debug()

        let expectedURL = Config.processURL
            .appendingPathComponent("debug")
            .appendingPathComponent("flip")
            .appendingPathComponent("flop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testChainedTransformationsURL() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)
            .crop(x: 20, y: 30, width: 150, height: 250)
            .flip()
            .flop()
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.bottom, .right])
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: .white, export: true)
            .cropFaces(mode: .fill, width: 250, height: 150, faces: [4])
            .pixelateFaces(faces: [3], minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)
            .roundCorners(radius: 150, blur: 0.8, background: .black)
            .vignette(amount: 80, blurMode: .gaussian, background: .black)
            .polaroid(color: .white, rotate: 33, background: .black)
            .tornEdges(spread: [5, 25], background: .blue)
            .shadow(blur: 10, opacity: 35, vector: [30, 30], color: .black, background: .white)
            .circle(background: .red)
            .border(width: 3, color: .white, background: .red)
            .sharpen(amount: 3)
            .blur(amount: 5)
            .monochrome()
            .blackAndWhite(threshold: 45)
            .sepia(tone: 85)
            .convert(format: "jpg", compress: true, strip: true, colorSpace: .input)
            .noMetadata()
            .quality(value: 88)
            .zip()
            .videoConvert(preset: "h264", force: false, width: 1080, height: 720, title: "Chapter 1", extName: "mp4")
            .audioConvert(preset: "m4a", extName: "m4a", fileName: "audio_1", audioBitRate: 320, audioSampleRate: 44100)
            .debug()

        let expectedURL = Config.processURL
            .appendingPathComponent("debug")
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("flip")
            .appendingPathComponent("flop")
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[bottom,right]")
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[4]")
            .appendingPathComponent("pixelate_faces=faces:[3],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("round_corners=radius:150,blur:0.8,background:000000FF")
            .appendingPathComponent("vignette=amount:80,blurmode:gaussian,background:000000FF")
            .appendingPathComponent("polaroid=color:FFFFFFFF,rotate:33,background:000000FF")
            .appendingPathComponent("torn_edges=spread:[5,25],background:0000FFFF")
            .appendingPathComponent("shadow=blur:10,opacity:35,vector:[30,30],color:000000FF,background:FFFFFFFF")
            .appendingPathComponent("circle=background:FF0000FF")
            .appendingPathComponent("border=width:3,color:FFFFFFFF,background:FF0000FF")
            .appendingPathComponent("sharpen=amount:3")
            .appendingPathComponent("blur=amount:5")
            .appendingPathComponent("monochrome")
            .appendingPathComponent("blackwhite=threshold:45")
            .appendingPathComponent("sepia=tone:85")
            .appendingPathComponent("output=format:jpg,compress:true,strip:true,colorspace:input")
            .appendingPathComponent("no_metadata")
            .appendingPathComponent("quality=value:88")
            .appendingPathComponent("zip")
            .appendingPathComponent("video_convert=preset:h264,force:false,width:1080,height:720,title:Chapter 1,extname:mp4")
            .appendingPathComponent("video_convert=preset:m4a,extname:m4a,filename:audio_1,audio_bitrate:320,audio_samplerate:44100")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTransfomationURLWithExternalURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(externalURL: URL(string: "https://SOME-EXTERNAL-URL/photo.jpg")!)
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)

        let expectedURL = Config.processURL
            .appendingPathComponent("MY-API-KEY")
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("https://SOME-EXTERNAL-URL/photo.jpg")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testChainedTransformationsURLWithExternalURL() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)

        let imageTransform = client.imageTransform(externalURL: URL(string: "https://SOME-EXTERNAL-URL/photo.jpg")!)
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)
            .crop(x: 20, y: 30, width: 150, height: 250)
            .flip()
            .flop()
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.bottom, .right])
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: .white, export: true)
            .cropFaces(mode: .fill, width: 250, height: 150, faces: [4])
            .pixelateFaces(faces: [3], minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)
            .roundCorners(radius: 150, blur: 0.8, background: .black)
            .vignette(amount: 80, blurMode: .gaussian, background: .black)
            .polaroid(color: .white, rotate: 33, background: .black)
            .tornEdges(spread: [5, 25], background: .blue)
            .shadow(blur: 10, opacity: 35, vector: [30, 30], color: .black, background: .white)
            .circle(background: .red)
            .border(width: 3, color: .white, background: .red)
            .sharpen(amount: 3)
            .blur(amount: 5)
            .monochrome()
            .blackAndWhite(threshold: 45)
            .sepia(tone: 85)
            .convert(format: "jpg", compress: true, strip: true, colorSpace: .input)
            .noMetadata()
            .quality(value: 88)
            .zip()
            .videoConvert(preset: "h264", force: false, width: 1080, height: 720, title: "Chapter 1", extName: "mp4")
            .audioConvert(preset: "m4a", extName: "m4a", fileName: "audio_1", audioBitRate: 320, audioSampleRate: 44100)
            .debug()

        let expectedURL = Config.processURL
            .appendingPathComponent("MY-API-KEY")
            .appendingPathComponent("debug")
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("flip")
            .appendingPathComponent("flop")
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[bottom,right]")
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[4]")
            .appendingPathComponent("pixelate_faces=faces:[3],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("round_corners=radius:150,blur:0.8,background:000000FF")
            .appendingPathComponent("vignette=amount:80,blurmode:gaussian,background:000000FF")
            .appendingPathComponent("polaroid=color:FFFFFFFF,rotate:33,background:000000FF")
            .appendingPathComponent("torn_edges=spread:[5,25],background:0000FFFF")
            .appendingPathComponent("shadow=blur:10,opacity:35,vector:[30,30],color:000000FF,background:FFFFFFFF")
            .appendingPathComponent("circle=background:FF0000FF")
            .appendingPathComponent("border=width:3,color:FFFFFFFF,background:FF0000FF")
            .appendingPathComponent("sharpen=amount:3")
            .appendingPathComponent("blur=amount:5")
            .appendingPathComponent("monochrome")
            .appendingPathComponent("blackwhite=threshold:45")
            .appendingPathComponent("sepia=tone:85")
            .appendingPathComponent("output=format:jpg,compress:true,strip:true,colorspace:input")
            .appendingPathComponent("no_metadata")
            .appendingPathComponent("quality=value:88")
            .appendingPathComponent("zip")
            .appendingPathComponent("video_convert=preset:h264,force:false,width:1080,height:720,title:Chapter 1,extname:mp4")
            .appendingPathComponent("video_convert=preset:m4a,extname:m4a,filename:audio_1,audio_bitrate:320,audio_samplerate:44100")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("https://SOME-EXTERNAL-URL/photo.jpg")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testStoreImageTransformation() {

        stub(condition: processStubConditions) { _ in

            let json: [String: Any] = [
                "container": "filestack-web-demo",
                "filename": "custom_flower_crop.jpg",
                "width": 1226,
                "height": 1100,
                "size": 215693,
                "key": "my/custom/path/lv3P2Q4QN2aluHLGhgAV_custom_flower_crop.jpg",
                "type": "image/jpeg",
                "url": "https://cdn.filestackcontent.com/lv3P2Q4QN2aluHLGhgAV"
            ]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let expectation = self.expectation(description: "request should complete")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .crop(x: 301, y: 269, width: 1226, height: 1100)

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "store=filename:custom_flower_crop.jpg,location:S3,path:my/custom/path/," +
                "container:filestack-web-demo,region:us-east-1,access:public,base64decode:true"
            )
            .appendingPathComponent("crop=dim:[301,269,1226,1100]")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("MY-HANDLE")

        var aFileLink: FileLink?
        var aResponse: NetworkJSONResponse?

        let transform = imageTransform.store(fileName: "custom_flower_crop.jpg",
                                             location: .s3,
                                             path: "my/custom/path/",
                                             container: "filestack-web-demo",
                                             region: "us-east-1",
                                             access: .public,
                                             base64Decode: true) { fileLink, response in

            aFileLink = fileLink
            aResponse = response

            expectation.fulfill()
        }

        XCTAssertEqual(transform.url, expectedURL)

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(aResponse?.request?.url, expectedURL)
        XCTAssertEqual(aResponse?.response?.statusCode, 200)
        XCTAssertNil(aResponse?.error)

        XCTAssertNotNil(aFileLink)
        XCTAssertEqual(aFileLink?.apiKey, "MY-API-KEY")
        XCTAssertEqual(aFileLink?.handle, "lv3P2Q4QN2aluHLGhgAV")
        XCTAssertEqual(aFileLink?.security, security)
    }

    func testFailedStoreImageTransformation() {

        stub(condition: processStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 500, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let expectation = self.expectation(description: "request should complete")

        let imageTransform = client.imageTransform(handle: "MY-HANDLE")
            .crop(x: 301, y: 269, width: 1226, height: 1100)

        let expectedURL = Config.processURL
            .appendingPathComponent("store")
            .appendingPathComponent("crop=dim:[301,269,1226,1100]")
            .appendingPathComponent("MY-HANDLE")

        var aFileLink: FileLink?
        var aResponse: NetworkJSONResponse?

        imageTransform.store() { fileLink, response in

            aFileLink = fileLink
            aResponse = response

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(aResponse?.request?.url, expectedURL)
        XCTAssertEqual(aResponse?.response?.statusCode, 500)
        XCTAssertNotNil(aResponse?.error)

        XCTAssertNil(aFileLink)
    }

}
