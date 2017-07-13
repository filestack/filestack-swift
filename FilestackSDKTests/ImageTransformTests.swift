//
//  ImageTransformTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class ImageTransformTests: XCTestCase {
    
    func testResizeTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testResizeTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .resize(width: 50, fit: .crop, align: .center)

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,fit:crop,align:center")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .crop(x: 20, y: 30, width: 150, height: 250)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .rotate(deg: 320, exif: true, background: .white)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:320,exif:true,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateDegExifTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .rotateDegExif(exif: false, background: .red)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:exif,exif:false,background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .rotate(deg: 150)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:150")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testFlipTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .flip()

        let expectedURL = Config.processURL
            .appendingPathComponent("flip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testFlopTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .flop()

        let expectedURL = Config.processURL
            .appendingPathComponent("flop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testWatermarkTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: .top)

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:top")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testWatermarkTransformationWithPairedPositionURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.top, .left])

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[top,left]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testWatermarkTransformationWithPairedPositionAndOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .watermark(file: "WATERMARK-HANDLE")

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: .white, export: true)

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .detectFaces(color:.red)

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=color:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .detectFaces()

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .cropFaces(mode: .fill, width: 250, height: 150, faces: 4)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:4")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .cropFaces(mode: .thumb, faces: 1)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:thumb,faces:1")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithOptionals2URL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .cropFaces(mode: .crop)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:crop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithFacesArrayURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .cropFaces(mode: .fill, width: 250, height: 150, faces: [1,2,3,4])

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[1,2,3,4]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCropFacesTransformationWithFacesAllURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .cropFacesAll(mode: .fill, width: 250, height: 150)

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:all")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .pixelateFaces(faces: 3, minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:3,minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithFacesArrayURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .pixelateFaces(faces: [1,3,5], minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[1,3,5],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithFacesAllURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .pixelateFacesAll(minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:all,minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .pixelateFaces(faces: 4, buffer: 250)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:4,buffer:250")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionals2URL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .pixelateFaces(faces: [1,3,5], buffer: 320)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[1,3,5],buffer:320")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionals3URL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .pixelateFacesAll(buffer:220)

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:all,buffer:220")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .roundCorners(radius: 150, blur: 0.8, background: .black)

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners=radius:150,blur:0.8,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .roundCorners()

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersMaxRadiusTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .roundCornersMaxRadius(blur: 0.25, background: .white)

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners=radius:max,blur:0.25,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRoundCornersMaxRadiusTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .roundCornersMaxRadius()

        let expectedURL = Config.processURL
            .appendingPathComponent("round_corners=radius:max")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVignetteTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .vignette(amount: 80, blurMode: .gaussian, background: .black)

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette=amount:80,blurmode:gaussian,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVignetteTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .vignette()

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testVignetteTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .vignette(amount: 35)

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette=amount:35")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPolaroidTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .polaroid(color: .white, rotate: 33, background: .black)

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid=color:FFFFFFFF,rotate:33,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPolaroidTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .polaroid()

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testPolaroidTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .polaroid(rotate: 45)

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid=rotate:45")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTornEdgesTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .tornEdges(spread: [5, 25], background: .blue)

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges=spread:[5,25],background:0000FFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTornEdgesTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .tornEdges()

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testTornEdgesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .tornEdges(spread: [5, 25])

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges=spread:[5,25]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testShadowTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .shadow(blur: 10, opacity: 35, vector: [30, 30], color: .black, background: .white)

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow=blur:10,opacity:35,vector:[30,30],color:000000FF,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testShadowTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .shadow()

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testShadowTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .shadow(blur: 15, opacity: 20)

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow=blur:15,opacity:20")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCircleTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .circle(background: .red)

        let expectedURL = Config.processURL
            .appendingPathComponent("circle=background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testCircleTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .circle()

        let expectedURL = Config.processURL
            .appendingPathComponent("circle")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBorderTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .border(width: 3, color: .white, background: .red)

        let expectedURL = Config.processURL
            .appendingPathComponent("border=width:3,color:FFFFFFFF,background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBorderTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .border()

        let expectedURL = Config.processURL
            .appendingPathComponent("border")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBorderTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .border(width: 5)

        let expectedURL = Config.processURL
            .appendingPathComponent("border=width:5")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSharpenTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .sharpen(amount: 3)

        let expectedURL = Config.processURL
            .appendingPathComponent("sharpen=amount:3")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSharpenTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .sharpen()

        let expectedURL = Config.processURL
            .appendingPathComponent("sharpen")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlurTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .blur(amount: 5)

        let expectedURL = Config.processURL
            .appendingPathComponent("blur=amount:5")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlurTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .blur()

        let expectedURL = Config.processURL
            .appendingPathComponent("blur")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testMonochromeTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .monochrome()

        let expectedURL = Config.processURL
            .appendingPathComponent("monochrome")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlackAndWhiteTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .blackAndWhite(threshold: 45)

        let expectedURL = Config.processURL
            .appendingPathComponent("blackwhite=threshold:45")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testBlackAndWhiteTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .blackAndWhite()

        let expectedURL = Config.processURL
            .appendingPathComponent("blackwhite")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSepiaTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .sepia(tone: 85)

        let expectedURL = Config.processURL
            .appendingPathComponent("sepia=tone:85")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testSepiaTransformationWithoutArgumentsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .sepia()

        let expectedURL = Config.processURL
            .appendingPathComponent("sepia")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testConvertTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .convert(format: "pdf",
                     background: .white,
                     page: 1,
                     density: 100,
                     compress: true,
                     quality: 85,
                     strip: true,
                     noMetadata: false,
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

    func testConvertTransformationWithoutMetadataURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .convert(format: "pdf",
                     background: .white,
                     page: 1,
                     density: 100,
                     compress: true,
                     quality:85,
                     strip: true,
                     noMetadata: true,
                     colorSpace: ImageTransformColorSpace.input,
                     secure: true,
                     docInfo: true,
                     pageFormat: ImageTransformPageFormat.letter,
                     pageOrientation: ImageTransformPageOrientation.portrait)

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "output=format:pdf,background:FFFFFFFF,page:1,density:100,compress:true,quality:85,strip:true," +
                "no_metadata,colorspace:input,secure:true,docinfo:true,pageformat:letter,pageorientation:portrait"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testConvertTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .convert(format: "jpg",
                     compress: true,
                     strip: true,
                     noMetadata: true,
                     colorSpace: .input)

        let expectedURL = Config.processURL
            .appendingPathComponent("output=format:jpg,compress:true,strip:true,no_metadata,colorspace:input")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testConvertPreservingInputQualityTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .convertPreservingInputQuality(format: "jpg",
                                           compress: true,
                                           noMetadata: true,
                                           colorSpace: .input)

        let expectedURL = Config.processURL
            .appendingPathComponent("output=format:jpg,compress:true,quality:input,no_metadata,colorspace:input")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testQualityTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .quality(value: 88)

        let expectedURL = Config.processURL
            .appendingPathComponent("quality=value:88")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testZipTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .zip()

        let expectedURL = Config.processURL
            .appendingPathComponent("zip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testChainedTransformationsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)
            .crop(x: 20, y: 30, width: 150, height: 250)
            .flip()
            .flop()
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.bottom, .right])
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: .white, export: true)
            .cropFaces(mode: .fill, width: 250, height: 150, faces: 4)
            .pixelateFaces(faces: 3, minSize: 0.25, maxSize: 0.45, buffer: 200, blur: 0.25, type: .oval)
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
            .convert(format: "jpg", compress: true, strip: true, noMetadata: true, colorSpace: .input)
            .quality(value: 88)
            .zip()

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("flip")
            .appendingPathComponent("flop")
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[bottom,right]")
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:4")
            .appendingPathComponent("pixelate_faces=faces:3,minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
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
            .appendingPathComponent("output=format:jpg,compress:true,strip:true,no_metadata,colorspace:input")
            .appendingPathComponent("quality=value:88")
            .appendingPathComponent("zip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }
}
