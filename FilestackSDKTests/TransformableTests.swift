//
//  TransformableTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import OHHTTPStubs
import XCTest

@testable import FilestackSDK

class TransformableTests: XCTestCase {
    private let processStubConditions = isScheme(Config.processURL.scheme!) && isHost(Config.processURL.host!)
    private let client = Client(apiKey: "My-API-KEY")

    private var transformable: Transformable!

    override func setUp() {
        transformable = client.transformable(handle: "MY-HANDLE")
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testASCIITransformationUrl() {
        transformable.add(transform: ASCIITransform().background(.red).foreground(.blue).size(50))

        let expectedUrl = Config.processURL
            .appendingPathComponent("ascii=background:FF0000FF,foreground:0000FFFF,size:50")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testASCIIWithReverseTransformationUrl() {
        transformable.add(transform: ASCIITransform().background(.red).foreground(.blue).reverse())

        let expectedUrl = Config.processURL
            .appendingPathComponent("ascii=background:FF0000FF,foreground:0000FFFF,colored:true,reverse:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testBlurFacesTransformationUrl() {
        transformable.add(transform: BlurFacesTransform().amount(30))

        let expectedUrl = Config.processURL
            .appendingPathComponent("blur_faces=amount:30.0")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testCacheTransformationUrl() {
        transformable.add(transform: CacheTransform().expiry(3600))

        let expectedUrl = Config.processURL
            .appendingPathComponent("cache=expiry:3600")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testCacheTransformationWithMaxExpiryUrl() {
        transformable.add(transform: CacheTransform().maxExpiry())

        let expectedUrl = Config.processURL
            .appendingPathComponent("cache=expiry:max")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testTurningOffCacheTransformationUrl() {
        transformable.add(transform: CacheTransform().maxExpiry().turnOff())

        let expectedUrl = Config.processURL
            .appendingPathComponent("cache=false")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testCollageTransformationUrl() {
        let collection = CollageTransformCollection().add(["HANDLE-1", "HANDLE-2"])
        transformable.add(transform: CollageTransform(size: CGSize(width: 15, height: 35), collection: collection).margin(40).color(.red).cropFit().autorotate())

        let expectedUrl = Config.processURL
            .appendingPathComponent("collage=width:15,height:35,files:[\"HANDLE-1\",\"HANDLE-2\"],margin:40,color:FF0000FF,fit:crop,autorotate:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testCompressTransformationUrl() {
        transformable.add(transform: CompressTransform().metadata(true))

        let expectedUrl = Config.processURL
            .appendingPathComponent("compress=metadata:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testEnhanceTransformationUrl() {
        transformable.add(transform: EnhanceTransform())

        let expectedUrl = Config.processURL
            .appendingPathComponent("enhance")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testModulateTransformationUrl() {
        transformable.add(transform: ModulateTransform().brightness(50).hue(60).saturation(200))

        let expectedUrl = Config.processURL
            .appendingPathComponent("modulate=brightness:50,hue:60,saturation:200")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testNegativeTransformationUrl() {
        transformable.add(transform: NegativeTransform())

        let expectedUrl = Config.processURL
            .appendingPathComponent("negative")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testOilPaintTransformationUrl() {
        transformable.add(transform: OilPaintTransform().amount(13))

        let expectedUrl = Config.processURL
            .appendingPathComponent("oil_paint=amount:13")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testPartialBlurTransformationUrl() {
        let firstObj = CGRect(x: 10, y: 20, width: 30, height: 40)
        let secondObj = CGRect(x: 11, y: 21, width: 31, height: 41)
        transformable.add(transform: PartialBlurTransform(objects: [firstObj, secondObj]))

        let expectedUrl = Config.processURL
            .appendingPathComponent("partial_blur=objects:[[10,20,30,40],[11,21,31,41]]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testPartialPixelateTransformationUrl() {
        let firstObj = CGRect(x: 10, y: 20, width: 30, height: 40)
        let secondObj = CGRect(x: 11, y: 21, width: 31, height: 41)
        transformable.add(transform: PartialPixelateTransform(objects: [firstObj, secondObj]))

        let expectedUrl = Config.processURL
            .appendingPathComponent("partial_pixelate=objects:[[10,20,30,40],[11,21,31,41]]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testProgressiveJPEGTransformationUrl() {
        transformable.add(transform: ProgressiveJPEGTransform().quality(15).metadata(true))

        let expectedUrl = Config.processURL
            .appendingPathComponent("pjpg=quality:15,metadata:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testRedEyeRemovalTransformationUrl() {
        transformable.add(transform: RedEyeRemovalTransform())

        let expectedUrl = Config.processURL
            .appendingPathComponent("redeye")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testUpscaleTransformationUrl() {
        transformable.add(transform: UpscaleTransform().noise(.low).style(.artwork).noUpscale())

        let expectedUrl = Config.processURL
            .appendingPathComponent("upscale=noise:low,style:artwork,upscale:false")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testURLScreenshotTransformationUrl() {
        transformable.add(transform: URLScreenshotTransform().mobileAgent().windowMode().width(1).height(2).delay(5).orientation(.landscape).device("test"))

        let expectedUrl = Config.processURL
            .appendingPathComponent("urlscreenshot=agent:mobile,mode:window,width:1,height:2,delay:5,orientation:landscape,device:test")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedUrl)
    }

    func testResizeTransformationURL() {
        transformable.add(transform: ResizeTransform().width(50).height(25).fit(.crop).align(.bottom))

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testResizeTransformationWithOptionalsURL() {
        transformable.add(transform: ResizeTransform().width(50).fit(.crop).align(.center))

        let expectedURL = Config.processURL
            .appendingPathComponent("resize=width:50,fit:crop,align:center")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCropTransformationURL() {
        transformable.add(transform: CropTransform(x: 20, y: 30, width: 150, height: 250))

        let expectedURL = Config.processURL
            .appendingPathComponent("crop=dim:[20,30,150,250]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testSecureForWorkTransformationURL() {
        transformable.add(transform: SecureForWorkTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("sfw")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testTagsTransformationURL() {
        transformable.add(transform: TagsTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("tags")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRotateTransformationURL() {
        transformable.add(transform: RotateTransform(deg: 320).exif(true).background(.white))

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:320,exif:true,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRotateDegExifTransformationURL() {
        transformable.add(transform: RotateTransform().exif(false).background(.red))

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:exif,exif:false,background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRotateTransformationWithOptionalsURL() {
        transformable.add(transform: RotateTransform(deg: 150))

        let expectedURL = Config.processURL
            .appendingPathComponent("rotate=deg:150")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testFlipTransformationURL() {
        transformable.add(transform: FlipTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("flip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testFlopTransformationURL() {
        transformable.add(transform: FlopTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("flop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testWatermarkTransformationURL() {
        transformable.add(transform: WatermarkTransform(file: "WATERMARK-HANDLE").size(50).position(.top))

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[top]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testWatermarkTransformationWithPairedPositionURL() {
        transformable.add(transform: WatermarkTransform(file: "WATERMARK-HANDLE").size(50).position([.top, .left]))

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE,size:50,position:[top,left]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testWatermarkTransformationWithPairedPositionAndOptionalsURL() {
        transformable.add(transform: WatermarkTransform(file: "WATERMARK-HANDLE"))

        let expectedURL = Config.processURL
            .appendingPathComponent("watermark=file:WATERMARK-HANDLE")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testDetectFacesTransformationURL() {
        transformable.add(transform: DetectFacesTransform().minSize(0.25).maxSize(0.55).color(.white).export(true))

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=minsize:0.25,maxsize:0.55,color:FFFFFFFF,export:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testDetectFacesTransformationWithOptionalsURL() {
        transformable.add(transform: DetectFacesTransform().color(.red))

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces=color:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testDetectFacesTransformationWithoutArgumentsURL() {
        transformable.add(transform: DetectFacesTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("detect_faces")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCropFacesTransformationURL() {
        transformable.add(transform: CropFacesTransform().mode(.fill).width(250).height(150).faces([4]))

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[4]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCropFacesTransformationWithOptionalsURL() {
        transformable.add(transform: CropFacesTransform().mode(.thumb).faces([1]))

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:thumb,faces:[1]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCropFacesTransformationWithOptionals2URL() {
        transformable.add(transform: CropFacesTransform().mode(.crop))

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:crop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCropFacesTransformationWithFacesArrayURL() {
        transformable.add(transform: CropFacesTransform().mode(.fill).width(250).height(150).faces([1, 2, 3, 4]))

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:[1,2,3,4]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCropFacesTransformationWithFacesAllURL() {
        transformable.add(transform: CropFacesTransform().mode(.fill).width(250).height(150).allFaces())

        let expectedURL = Config.processURL
            .appendingPathComponent("crop_faces=mode:fill,width:250,height:150,faces:all")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPixelateFacesTransformationURL() {
        transformable.add(transform: PixelateFacesTransform()
            .faces([3])
            .minSize(0.25)
            .maxSize(0.45)
            .buffer(200)
            .blur(0.25)
            .type(.oval))

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[3],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPixelateFacesTransformationWithFacesArrayURL() {
        transformable.add(transform: PixelateFacesTransform()
            .faces([1, 3, 5])
            .minSize(0.25)
            .maxSize(0.45)
            .buffer(200)
            .blur(0.25)
            .type(.oval))

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[1,3,5],minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPixelateFacesTransformationWithFacesAllURL() {
        transformable.add(transform: PixelateFacesTransform()
            .allFaces()
            .minSize(0.25)
            .maxSize(0.45)
            .buffer(200)
            .blur(0.25)
            .type(.oval))

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:all,minsize:0.25,maxsize:0.45,buffer:200,blur:0.25,type:oval")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionalsURL() {
        transformable.add(transform: PixelateFacesTransform()
            .faces([4])
            .buffer(250))

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[4],buffer:250")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionals2URL() {
        transformable.add(transform: PixelateFacesTransform()
            .faces([1, 3, 5])
            .buffer(320))

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:[1,3,5],buffer:320")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPixelateFacesTransformationWithOptionals3URL() {
        transformable.add(transform: PixelateFacesTransform()
            .allFaces()
            .buffer(220))

        let expectedURL = Config.processURL
            .appendingPathComponent("pixelate_faces=faces:all,buffer:220")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRoundedCornersTransformationURL() {
        transformable.add(transform: RoundedCornersTransform().radius(150).blur(0.8).background(.black))

        let expectedURL = Config.processURL
            .appendingPathComponent("rounded_corners=radius:150,blur:0.8,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRoundedCornersTransformationWithoutArgumentsURL() {
        transformable.add(transform: RoundedCornersTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("rounded_corners")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRoundedCornersMaxRadiusTransformationURL() {
        transformable.add(transform: RoundedCornersTransform().maxRadius().blur(0.25).background(.white))

        let expectedURL = Config.processURL
            .appendingPathComponent("rounded_corners=radius:max,blur:0.25,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testRoundedCornersMaxRadiusTransformationWithoutArgumentsURL() {
        transformable.add(transform: RoundedCornersTransform().maxRadius())

        let expectedURL = Config.processURL
            .appendingPathComponent("rounded_corners=radius:max")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testVignetteTransformationURL() {
        transformable.add(transform: VignetteTransform().amount(80).blurMode(.gaussian).background(.black))

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette=amount:80,blurmode:gaussian,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testVignetteTransformationWithoutArgumentsURL() {
        transformable.add(transform: VignetteTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testVignetteTransformationWithOptionalsURL() {
        transformable.add(transform: VignetteTransform().amount(35))

        let expectedURL = Config.processURL
            .appendingPathComponent("vignette=amount:35")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPolaroidTransformationURL() {
        transformable.add(transform: PolaroidTransform().color(.white).rotate(33).background(.black))

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid=color:FFFFFFFF,rotate:33,background:000000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPolaroidTransformationWithoutArgumentsURL() {
        transformable.add(transform: PolaroidTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPolaroidTransformationWithOptionalsURL() {
        transformable.add(transform: PolaroidTransform().rotate(45))

        let expectedURL = Config.processURL
            .appendingPathComponent("polaroid=rotate:45")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testTornEdgesTransformationURL() {
        transformable.add(transform: TornEdgesTransform().spread(start: 5, end: 25).background(.blue))

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges=spread:[5,25],background:0000FFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testTornEdgesTransformationWithoutArgumentsURL() {
        transformable.add(transform: TornEdgesTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testTornEdgesTransformationWithOptionalsURL() {
        transformable.add(transform: TornEdgesTransform().spread(start: 5, end: 25))

        let expectedURL = Config.processURL
            .appendingPathComponent("torn_edges=spread:[5,25]")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testShadowTransformationURL() {
        transformable.add(transform: ShadowTransform()
            .blur(10)
            .opacity(35)
            .vector(x: 30, y: 30)
            .color(.black)
            .background(.white))

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow=blur:10,opacity:35,vector:[30,30],color:000000FF,background:FFFFFFFF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testShadowTransformationWithoutArgumentsURL() {
        transformable.add(transform: ShadowTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testShadowTransformationWithOptionalsURL() {
        transformable.add(transform: ShadowTransform().blur(15).opacity(20))

        let expectedURL = Config.processURL
            .appendingPathComponent("shadow=blur:15,opacity:20")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCircleTransformationURL() {
        transformable.add(transform: CircleTransform().background(.red))

        let expectedURL = Config.processURL
            .appendingPathComponent("circle=background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testCircleTransformationWithoutArgumentsURL() {
        transformable.add(transform: CircleTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("circle")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBorderTransformationURL() {
        transformable.add(transform: BorderTransform().width(3).color(.white).background(.red))

        let expectedURL = Config.processURL
            .appendingPathComponent("border=width:3,color:FFFFFFFF,background:FF0000FF")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBorderTransformationWithoutArgumentsURL() {
        transformable.add(transform: BorderTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("border")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBorderTransformationWithOptionalsURL() {
        transformable.add(transform: BorderTransform().width(5))

        let expectedURL = Config.processURL
            .appendingPathComponent("border=width:5")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testSharpenTransformationURL() {
        transformable.add(transform: SharpenTransform().amount(3))

        let expectedURL = Config.processURL
            .appendingPathComponent("sharpen=amount:3")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testSharpenTransformationWithoutArgumentsURL() {
        transformable.add(transform: SharpenTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("sharpen")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBlurTransformationURL() {
        transformable.add(transform: BlurTransform().amount(5))

        let expectedURL = Config.processURL
            .appendingPathComponent("blur=amount:5")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBlurTransformationWithoutArgumentsURL() {
        transformable.add(transform: BlurTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("blur")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testMonochromeTransformationURL() {
        transformable.add(transform: MonochromeTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("monochrome")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBlackAndWhiteTransformationURL() {
        transformable.add(transform: BlackAndWhiteTransform().threshold(45))

        let expectedURL = Config.processURL
            .appendingPathComponent("blackwhite=threshold:45")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testBlackAndWhiteTransformationWithoutArgumentsURL() {
        transformable.add(transform: BlackAndWhiteTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("blackwhite")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testSepiaTransformationURL() {
        transformable.add(transform: SepiaTransform().tone(85))

        let expectedURL = Config.processURL
            .appendingPathComponent("sepia=tone:85")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testSepiaTransformationWithoutArgumentsURL() {
        transformable.add(transform: SepiaTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("sepia")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testConvertTransformationURL() {
        transformable.add(transform: ConvertTransform()
            .format(.pdf)
            .background(.white)
            .page(1)
            .density(100)
            .compress()
            .quality(85)
            .strip()
            .colorSpace(.input)
            .secure()
            .docInfo()
            .pageFormat(.letter)
            .pageOrientation(.portrait))

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "output=format:pdf,background:FFFFFFFF,page:1,density:100,compress:true,quality:85,strip:true," +
                    "colorspace:input,secure:true,docinfo:true,pageformat:letter,pageorientation:portrait"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testConvertTransformationWithOptionalsURL() {
        transformable.add(transform: ConvertTransform()
            .format(.jpg)
            .compress()
            .strip()
            .colorSpace(.input))

        let expectedURL = Config.processURL
            .appendingPathComponent("output=format:jpg,compress:true,strip:true,colorspace:input")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testConvertPreservingInputQualityTransformationURL() {
        transformable.add(transform: ConvertTransform()
            .format(.jpg)
            .compress()
            .preserveInputQuality()
            .colorSpace(.input))

        let expectedURL = Config.processURL
            .appendingPathComponent("output=format:jpg,compress:true,quality:input,colorspace:input")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testNoMetadataTransformationURL() {
        transformable.add(transform: NoMetadataTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("no_metadata")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testQualityTransformationURL() {
        transformable.add(transform: QualityTransform(value: 88))

        let expectedURL = Config.processURL
            .appendingPathComponent("quality=value:88")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testZipTransformationURL() {
        transformable.add(transform: ZipTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("zip")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testVideoConvertTransformationURL() {
        transformable.add(transform: AVTransform()
            .preset("h264")
            .force(false)
            .width(1080)
            .height(720)
            .title("Chapter 1")
            .extName("mp4")
            .fileName("chapter_1")
            .location(.s3)
            .path("/myfiles/chapter_1.mp4")
            .access(.public)
            .container("user-videos")
            .upscale(false)
            .aspectMode(.preserve)
            .twoPass(true)
            .videoBitRate(3200)
            .fps(30)
            .keyframeInterval(250)
            .audioBitRate(320)
            .audioSampleRate(44100)
            .audioChannels(2)
            .clipLength("00:02:30")
            .clipOffset("00:00:05")
            .watermarkURL(URL(string: "https://SOME-EXTERNAL-URL")!)
            .watermarkTop(20)
            .watermarkRight(20)
            .watermarkWidth(256)
            .watermarkHeight(256))

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

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testVideoConvertWithTitleIncludingCommasTransformationURL() {
        let title = "Chapters 1,2,3 and 4"
        transformable.add(transform: AVTransform().preset("h264").title(title))

        let allowedCharacters = CharacterSet(charactersIn: ",").inverted
        let escapedTitle = title.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!

        let expectedURL = Config.processURL
            .appendingPathComponent("video_convert=preset:h264,title:\(escapedTitle)")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testAudioConvertTransformationURL() {
        transformable
            .add(transform: AVTransform()
                .preset("m4a")
                .force(false)
                .title("Chapter 1")
                .extName("m4a")
                .fileName("chapter_1")
                .location(.s3)
                .path("/myfiles/chapter_1.m4a")
                .access(.public)
                .container("user-audios")
                .audioBitRate(320)
                .audioSampleRate(44100)
                .audioChannels(2)
                .clipLength("00:02:30")
                .clipOffset("00:00:05"))

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "video_convert=preset:m4a,force:false,title:Chapter 1," +
                    "extname:m4a,filename:chapter_1,location:S3,path:/myfiles/chapter_1.m4a," +
                    "access:public,container:user-audios," +
                    "audio_bitrate:320,audio_samplerate:44100,audio_channels:2," +
                    "clip_length:00:02:30,clip_offset:00:00:05"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testDebugTransformationURL() {
        transformable.add(transform: FlipTransform())
            .add(transform: FlopTransform())
            .debug()

        let expectedURL = Config.processURL
            .appendingPathComponent("debug")
            .appendingPathComponent("flip")
            .appendingPathComponent("flop")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testChainedTransformationsURL() {
        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)

        let transformable = client.transformable(handle: "MY-HANDLE")
            .add(transform: ResizeTransform().width(50).height(25).fit(.crop).align(.bottom))
            .add(transform: CropTransform(x: 20, y: 30, width: 150, height: 250))
            .add(transform: FlipTransform())
            .add(transform: FlopTransform())
            .add(transform: WatermarkTransform(file: "WATERMARK-HANDLE").size(50).position([.bottom, .right]))
            .add(transform: DetectFacesTransform().minSize(0.25).maxSize(0.55).color(.white).export(true))
            .add(transform: CropFacesTransform().mode(.fill).width(250).height(150).faces([4]))
            .add(transform: PixelateFacesTransform()
                .faces([3])
                .minSize(0.25)
                .maxSize(0.45)
                .buffer(200)
                .blur(0.25)
                .type(.oval))
            .add(transform: RoundedCornersTransform().radius(150).blur(0.8).background(.black))
            .add(transform: VignetteTransform().amount(80).blurMode(.gaussian).background(.black))
            .add(transform: PolaroidTransform().color(.white).rotate(33).background(.black))
            .add(transform: TornEdgesTransform().spread(start: 5, end: 25).background(.blue))
            .add(transform: ShadowTransform()
                .blur(10)
                .opacity(35)
                .vector(x: 30, y: 30)
                .color(.black)
                .background(.white))
            .add(transform: CircleTransform().background(.red))
            .add(transform: BorderTransform().width(3).color(.white).background(.red))
            .add(transform: SharpenTransform().amount(3))
            .add(transform: BlurTransform().amount(5))
            .add(transform: MonochromeTransform())
            .add(transform: BlackAndWhiteTransform().threshold(45))
            .add(transform: SepiaTransform().tone(85))
            .add(transform: ConvertTransform()
                .format(.jpg)
                .compress()
                .strip()
                .colorSpace(.input))
            .add(transform: NoMetadataTransform())
            .add(transform: QualityTransform(value: 88))
            .add(transform: ZipTransform())
            .add(transform: AVTransform()
                .preset("h264")
                .force(false)
                .width(1080)
                .height(720)
                .title("Chapter 1")
                .extName("mp4"))
            .add(transform: AVTransform()
                .preset("m4a")
                .extName("m4a")
                .fileName("audio_1")
                .audioBitRate(320)
                .audioSampleRate(44100))
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
            .appendingPathComponent("rounded_corners=radius:150,blur:0.8,background:000000FF")
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

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testTransfomationURLWithExternalURL() {
        let client = Client(apiKey: "MY-API-KEY")

        let transformable = client.transformable(externalURL: URL(string: "https://SOME-EXTERNAL-URL/photo.jpg")!)
            .add(transform: ResizeTransform().width(50).height(25).fit(.crop).align(.bottom))

        let expectedURL = Config.processURL
            .appendingPathComponent("MY-API-KEY")
            .appendingPathComponent("resize=width:50,height:25,fit:crop,align:bottom")
            .appendingPathComponent("https://SOME-EXTERNAL-URL/photo.jpg")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testChainedTransformationsURLWithExternalURL() {
        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)

        let transformable = client.transformable(externalURL: URL(string: "https://SOME-EXTERNAL-URL/photo.jpg")!)
            .add(transform: ResizeTransform().width(50).height(25).fit(.crop).align(.bottom))
            .add(transform: CropTransform(x: 20, y: 30, width: 150, height: 250))
            .add(transform: FlipTransform())
            .add(transform: FlopTransform())
            .add(transform: WatermarkTransform(file: "WATERMARK-HANDLE").size(50).position([.bottom, .right]))
            .add(transform: DetectFacesTransform().minSize(0.25).maxSize(0.55).color(.white).export(true))
            .add(transform: CropFacesTransform().mode(.fill).width(250).height(150).faces([4]))
            .add(transform: PixelateFacesTransform()
                .faces([3])
                .minSize(0.25)
                .maxSize(0.45)
                .buffer(200)
                .blur(0.25)
                .type(.oval))
            .add(transform: RoundedCornersTransform().radius(150).blur(0.8).background(.black))
            .add(transform: VignetteTransform().amount(80).blurMode(.gaussian).background(.black))
            .add(transform: PolaroidTransform().color(.white).rotate(33).background(.black))
            .add(transform: TornEdgesTransform().spread(start: 5, end: 25).background(.blue))
            .add(transform: ShadowTransform()
                .blur(10)
                .opacity(35)
                .vector(x: 30, y: 30)
                .color(.black)
                .background(.white))
            .add(transform: CircleTransform().background(.red))
            .add(transform: BorderTransform().width(3).color(.white).background(.red))
            .add(transform: SharpenTransform().amount(3))
            .add(transform: BlurTransform().amount(5))
            .add(transform: MonochromeTransform())
            .add(transform: BlackAndWhiteTransform().threshold(45))
            .add(transform: SepiaTransform().tone(85))
            .add(transform: ConvertTransform()
                .format(.jpg)
                .compress()
                .strip()
                .colorSpace(.input))
            .add(transform: NoMetadataTransform())
            .add(transform: QualityTransform(value: 88))
            .add(transform: ZipTransform())
            .add(transform: AVTransform()
                .preset("h264")
                .force(false)
                .width(1080)
                .height(720)
                .title("Chapter 1")
                .extName("mp4"))
            .add(transform: AVTransform()
                .preset("m4a")
                .extName("m4a")
                .fileName("audio_1")
                .audioBitRate(320)
                .audioSampleRate(44100))
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
            .appendingPathComponent("rounded_corners=radius:150,blur:0.8,background:000000FF")
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

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testStoreImageTransformation() {
        stub(condition: processStubConditions) { _ in

            let json: [String: Any] = [
                "container": "filestack-web-demo",
                "filename": "custom_flower_crop.jpg",
                "width": 1226,
                "height": 1100,
                "size": 215_693,
                "key": "my/custom/path/lv3P2Q4QN2aluHLGhgAV_custom_flower_crop.jpg",
                "type": "image/jpeg",
                "url": "https://cdn.filestackcontent.com/lv3P2Q4QN2aluHLGhgAV",
            ]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let expectation = self.expectation(description: "request should complete")

        let transformable = client.transformable(handle: "MY-HANDLE")
            .add(transform: CropTransform(x: 301, y: 269, width: 1226, height: 1100))

        let storageOptions = StorageOptions(location: .s3,
                                            region: "us-east-1",
                                            container: "filestack-web-demo",
                                            path: "my/custom/path/",
                                            filename: "custom_flower_crop.jpg",
                                            access: .public)

        let expectedURL = Config.processURL
            .appendingPathComponent("store=location:S3,region:us-east-1,container:filestack-web-demo,path:my/custom/path/,filename:custom_flower_crop.jpg,access:public,base64decode:true")
            .appendingPathComponent("crop=dim:[301,269,1226,1100]")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("MY-HANDLE")

        let transform = transformable.store(using: storageOptions, base64Decode: true) { fileLink, response in
            expectation.fulfill()

            XCTAssertEqual(response.request?.url, expectedURL)
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNil(response.error)

            XCTAssertNotNil(fileLink)
            XCTAssertEqual(fileLink?.apiKey, "MY-API-KEY")
            XCTAssertEqual(fileLink?.handle, "lv3P2Q4QN2aluHLGhgAV")
            XCTAssertEqual(fileLink?.security, security)
        }

        XCTAssertEqual(transform.url, expectedURL)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testFailedStoreImageTransformation() {
        stub(condition: processStubConditions) { _ in
            OHHTTPStubsResponse(data: Data(), statusCode: 500, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let expectation = self.expectation(description: "request should complete")

        let transformable = client.transformable(handle: "MY-HANDLE")
            .add(transform: CropTransform(x: 301, y: 269, width: 1226, height: 1100))

        let storageOptions = StorageOptions(location: .s3, access: .public)

        let expectedURL = Config.processURL
            .appendingPathComponent("store=location:S3,access:public,base64decode:false")
            .appendingPathComponent("crop=dim:[301,269,1226,1100]")
            .appendingPathComponent("MY-HANDLE")

        transformable.store(using: storageOptions, base64Decode: false) { fileLink, response in
            expectation.fulfill()

            XCTAssertNil(fileLink)
            XCTAssertEqual(response.request?.url, expectedURL)
            XCTAssertEqual(response.response?.statusCode, 500)
            XCTAssertNotNil(response.error)
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPDFInfoDocumentTransformationURL() {
        transformable.add(transform: ConvertTransform()
            .format(.pdf))

        transformable.add(transform: PDFInfoTransform()
            .colorInfo())

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "output=format:pdf/" +
                    "pdfinfo=colorinfo:true"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPDFConvertDocumentTransformationURL() {
        transformable.add(transform: ConvertTransform()
            .format(.pdf))

        transformable.add(transform: PDFConvertTransform()
            .pageOrientation(.landscape)
            .pageFormat(.a3)
            .pages([2, 3, 4]))

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "output=format:pdf/" +
                    "pdfconvert=pageorientation:landscape,pageformat:a3,pages:[2,3,4]"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testPDFMonochromeDocumentTransformationURL() {
        transformable.add(transform: ConvertTransform()
            .format(.pdf))

        transformable.add(transform: PDFConvertTransform()
            .pageOrientation(.landscape)
            .pageFormat(.a3)
            .pages([2, 3, 4]))

        transformable.add(transform: PDFMonochromeTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "output=format:pdf/" +
                    "pdfconvert=pageorientation:landscape,pageformat:a3,pages:[2,3,4]/" +
                    "monochrome"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testDocumentDetectionTransformationURL() {
        transformable.add(transform: DocumentDetectionTransform()
            .coords(false)
            .preprocess(true))

        let expectedURL = Config.processURL
            .appendingPathComponent(
                "doc_detection=coords:false,preprocess:true"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testDocumentDetectionTransformationURLWithSecurityAndExternalURL() {
        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)

        let transformable = client.transformable(externalURL: URL(string: "https://SOME-EXTERNAL-URL/photo.jpg")!)
            .add(transform: DocumentDetectionTransform().coords(false).preprocess(true))

        let expectedURL = Config.processURL
            .appendingPathComponent("MY-API-KEY")
            .appendingPathComponent("doc_detection=coords:false,preprocess:true")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("https://SOME-EXTERNAL-URL/photo.jpg")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testFallbackTransformationURL() {
        transformable.add(transform: FallbackTransform()
            .cache(10)
            .handle("MY-FALLBACK-HANDLE"))

        transformable.add(transform: DocumentDetectionTransform()
            .coords(false)
            .preprocess(true))

        let expectedURL = Config.processURL
            .appendingPathComponent("fallback=cache:10,handle:MY-FALLBACK-HANDLE")
            .appendingPathComponent("doc_detection=coords:false,preprocess:true")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testFallbackTransformationURLWithSecurityAndExternalURL() {
        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)

        let transformable = client.transformable(externalURL: URL(string: "https://SOME-EXTERNAL-URL/photo.jpg")!)

        transformable.add(transform: FallbackTransform()
            .cache(10)
            .handle("MY-FALLBACK-HANDLE"))

        transformable.add(transform: DocumentDetectionTransform()
            .coords(false)
            .preprocess(true))

        let expectedURL = Config.processURL
            .appendingPathComponent("MY-API-KEY")
            .appendingPathComponent("fallback=cache:10,handle:MY-FALLBACK-HANDLE")
            .appendingPathComponent("doc_detection=coords:false,preprocess:true")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("https://SOME-EXTERNAL-URL/photo.jpg")

        XCTAssertEqual(transformable.url, expectedURL)
    }

    func testImageSizeTransformationURL() {
        transformable.add(transform: ImageSizeTransform())

        let expectedURL = Config.processURL
            .appendingPathComponent("imagesize")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(transformable.url, expectedURL)
    }
}
