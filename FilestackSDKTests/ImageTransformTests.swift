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
            .rotate(deg: 320, exif: true, background: UIColor.white)

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:320,exif:true,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testRotateDegExifTransformationURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .rotateDegExif(exif: false, background: UIColor.red)

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
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: UIColor.white, export: true)

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }

    func testDetectFacesTransformationWithOptionalsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .detectFaces(color:UIColor.red)

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

    func testChainedTransformationsURL() {

        let client = Client(apiKey: "MY-API-KEY")

        let imageTransform = client.imageTransform(for: "MY-HANDLE")
            .resize(width: 50, height: 25, fit: .crop, align: .bottom)
            .crop(x: 20, y: 30, width: 150, height: 250)
            .flip()
            .flop()
            .watermark(file: "WATERMARK-HANDLE", size: 50, position: [.bottom, .right])
            .detectFaces(minSize: 0.25, maxSize: 0.55, color: UIColor.white, export: true)
            .cropFaces(mode: .fill, width: 250, height: 150, faces: 4)

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("flip")
            .appendingPathComponent("flop")
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[bottom,right]")
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:4")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(imageTransform.url, expectedURL)
    }
}
