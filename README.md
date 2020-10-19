[![Code Climate][code_climate_badge]][code_climate] [![Build Status](https://travis-ci.org/filestack/filestack-swift.svg?branch=master)](https://travis-ci.org/filestack/filestack-swift)

# Filestack Swift SDK
<a href="https://www.filestack.com"><img src="https://www.filestack.com/docs/images/fs-logo-dark.svg" align="left" hspace="10" vspace="6"></a>
This is the official Swift SDK for Filestack - API and content management system that makes it easy to add powerful file uploading and transformation capabilities to any web or mobile application.

## Resources

* [Filestack](https://www.filestack.com)
* [Documentation](https://www.filestack.com/docs)
* [API Reference](https://filestack.github.io/filestack-swift/)

## Requirements

* Xcode 10.2+ (*Xcode 12+ required for SPM support*)
* Swift 4.2+ / Objective-C
* iOS 11.0+

## Installing

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

```shell
$ gem install cocoapods
```

To integrate FilestackSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'FilestackSDK', '~> 2.5.1'
end
```

Then, run the following command:

```shell
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```shell
$ brew update
$ brew install carthage
```

To integrate FilestackSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

`github "filestack/filestack-swift" ~> 2.5.1`

Run `carthage update` to build the framework and drag the built `FilestackSDK.framework` into your Xcode project. Additionally, add  `Alamofire.framework`  to the embedded frameworks build phase of your app's target.

### Swift Package Manager

Add `https://github.com/filestack/filestack-swift.git` as a [Swift Package Manager](https://swift.org/package-manager/) dependency to your Xcode project.

Alternatively, if you are adding `FilestackSDK` to your own Swift Package, declare the dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/filestack/filestack-swift.git", .upToNextMajor(from: "2.5.1"))
]
```

### Manually

#### Embedded Framework

Open up Terminal, cd into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```shell
$ git init
```

Add FilestackSDK and its dependencies as git submodules by running the following commands:

```shell
$ git submodule add https://github.com/filestack/filestack-swift.git
$ git submodule add https://github.com/Alamofire/Alamofire.git
```

Open the new `filestack-swift` folder, and drag the `FilestackSDK.xcodeproj` into the Project Navigator of your application's Xcode project.

It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
Select the `FilestackSDK.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.

Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.

In the tab bar at the top of that window, open the "General" panel.

Click on the + button under the "Embedded Binaries" section and choose the `FilestackSDK.framework` for iOS.

Repeat the same process for adding `Alamofire`.

## Usage

<details>
<summary>Integration into a Swift project</summary>

1. Import the framework into your code:

    ```swift
    import FilestackSDK
    ```

2. Instantiate a `Client` object by providing your API key and, optionally, a `Security` object:

    ```swift
    // Initialize a `Policy` with the expiry time and permissions you need.
    let oneDayInSeconds: TimeInterval = 60 * 60 * 24 // expires tomorrow
    let policy = Policy(// Set your expiry time (24 hours in our case)
                        expiry: Date(timeIntervalSinceNow: oneDayInSeconds),
                        // Set the permissions you want your policy to have
                        call: [.pick, .read, .store])

    // Initialize a `Security` object by providing a `Policy` object and your app secret.
    // You can find and/or enable your app secret in the Developer Portal.
    guard let security = try? Security(policy: policy, appSecret: "YOUR-APP-SECRET") else {
        return
    }

    // Initialize your `Client` object by passing a valid API key, and security options.
    let client = Client(apiKey: "YOUR-API-KEY", security: security)
    ```

</details>

<details>
<summary>Integration into an Objective-C project</summary>

1. Import the framework into your code:

    ```objective-c
    @import FilestackSDK;
    ```

2. Instantiate a `FSClient` object by providing your API key and, optionally, a `FSSecurity` object:

    ```objective-c
    // Initialize a `FSPolicy` object with the expiry time and permissions you need.
    NSTimeInterval oneDayInSeconds = 60 * 60 * 24; // expires tomorrow
    NSDate *expiryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:oneDayInSeconds];
    FSPolicyCall permissions = FSPolicyCallPick | FSPolicyCallRead | FSPolicyCallStore;

    FSPolicy *policy = [[FSPolicy alloc] initWithExpiry:expiryDate
                                                   call:permissions];

    NSError *error;

    // Initialize a `Security` object by providing a `FSPolicy` object and your app secret.
    // You can find and/or enable your app secret in the Developer Portal.
    FSSecurity *security = [[FSSecurity alloc] initWithPolicy:policy
                                                    appSecret:@"YOUR-APP-SECRET"
                                                        error:&error];

    if (error != nil) {
        NSLog(@"Error instantiating policy object: %@", error.localizedDescription);
        return;
    }

    // Initialize your `Client` object by passing a valid API key, and security options.
    FSClient *client = [[FSClient alloc] initWithApiKey:@"YOUR-API-KEY"
                                               security:security];
    ```

For more information, please consult our [API Reference](https://filestack.github.io/filestack-swift/).
</details>

<details>
<summary>Uploading files directly to a storage location</summary>

Both regular and Intelligent Ingestion uploads use the same API function available in the `Client` class. However, if your account has Intelligent Ingestion support enabled and you prefer using the regular uploading mechanism, you could disable it by setting the `useIntelligentIngestionIfAvailable` argument to `false` (see the relevant examples below.)

<details>
<summary>Swift Example</summary>

```swift
// Define upload options (see `UploadOptions` for all the available options)
// Here we use `.defaults` which implies:
// * preferIntelligentIngestion = true
// * startImmediately = true
// * deleteTemporaryFilesAfterUpload = false
// * storeOptions = StorageOptions(location: .s3, access: .private)
// * defaultPartUploadConcurrency = 5
// * defaultChunkUploadConcurrency = 8
// * chunkSize = 5mbs 
let uploadOptions = UploadOptions.defaults
// For instance, if you don't want to use Intelligent Ingestion regardless of whether it is available:
uploadOptions.preferIntelligentIngestion = false
// You may also easily override the default store options:
uploadOptions.storeOptions = StorageOptions(// Store location (e.g. S3, Dropbox, Rackspace, Azure, Google Cloud Storage)
                                            location: .s3,
                                            // AWS Region for S3 (e.g. "us-east-1", "eu-west-1", "ap-northeast-1", etc.)
                                            region: "us-east-1",
                                            // The name of your S3 bucket
                                            container: "YOUR-S3-BUCKET",
                                            // Destination path in the store.
                                            // You may use a path to a folder (e.g. /public/) or,
                                            // alternatively a path containing a filename (e.g. /public/oncorhynchus.jpg).
                                            // When using a path to a folder, the uploaded file will be stored at that folder using a
                                            // filename derived from the original filename.
                                            // When using a path to a filename, the uploaded file will be stored at the given path
                                            // using the filename indicated in the path.
                                            path: "/public/oncorhynchus.jpg",
                                            // Custom MIME type (useful when uploadable has no way of knowing its MIME type)
                                            mimeType: "image/jpg",
                                            // Access permissions (either public or private)
                                            access: .public,
                                            // An array of workflow IDs to trigger for each upload
                                            workflows: ["WF-1", "WF-2"]
                                            )

let uploadable = URL(...) // may also be Data or arrays of URL or Data.

// Call the function in your `Client` instance that takes care of uploading your Uploadable.
// Please notice that most arguments have sensible defaults and may be ommited.
let uploader = client.upload(// You may pass an URL, Data or arrays of URL or Data
                             using: uploadable,
                             // Set the upload options here. If none given, `UploadOptions.defaults` 
                             // is assumed.
                             options: uploadOptions,
                             // Set the dispatch queue where you want your upload progress
                             // and completion handlers to be called.
                             // Remember that any UI updates should be performed on the
                             // main queue.
                             // You can omit this parameter, and the main queue will be
                             // used by default.
                             queue: .main,
                             // Set your upload progress handler here (optional)
                             uploadProgress: { progress in
                                 // Here you may update the UI to reflect the upload progress.
                                 print("Progress: \(progress)")
                             }) { response in
                                 // Try to obtain Filestack handle
                                 if let json = response?.json, let handle = json["handle"] as? String {
                                     // Use Filestack handle
                                 } else if let error = response?.error {
                                     // Handle error
                                 }
                             }

// Start upload (only useful when `startImmediately` option is `false`)
uploader.start()

// Cancel ongoing upload.
uploader.cancel()

// Query progress.
uploader.progress // returns a `Progress` object
```
</details>

<details>
<summary>Objective-C Example</summary>

```objective-c
// Define upload options (see `FSUploadOptions` for all the available options)
// Here we use `.defaults` which implies:
// * preferIntelligentIngestion = true
// * startImmediately = true
// * deleteTemporaryFilesAfterUpload = false
// * storeOptions = FSStorageOptions.defaults (= location:S3, access:private)
// * defaultPartUploadConcurrency = 5
// * defaultChunkUploadConcurrency = 8
// * chunkSize = 5mbs
FSUploadOptions *uploadOptions = FSUploadOptions.defaults;

// For instance, if you don't want to use Intelligent Ingestion regardless of whether it is available:
uploadOptions.preferIntelligentIngestion = NO;

// You may also easily override the default store options:
uploadOptions.storeOptions = [[FSStorageOptions alloc] initWithLocation:FSStorageLocationS3 access:FSStorageAccessPrivate];
// AWS Region for S3 (e.g. "us-east-1", "eu-west-1", "ap-northeast-1", etc.)
uploadOptions.storeOptions.region = @"us-east-1";
// The name of your S3 bucket
uploadOptions.storeOptions.container = @"YOUR-S3-BUCKET";
// Destination path in the store.
// You may use a path to a folder (e.g. /public/) or,
// alternatively a path containing a filename (e.g. /public/oncorhynchus.jpg).
// When using a path to a folder, the uploaded file will be stored at that folder using a
// filename derived from the original filename.
// When using a path to a filename, the uploaded file will be stored at the given path
// using the filename indicated in the path.
uploadOptions.storeOptions.path = @"/public/oncorhynchus.jpg";
// Custom MIME type (useful when uploadable has no way of knowing its MIME type)
uploadOptions.storeOptions.mimeType = @"image/jpg";
// An array of workflow IDs to trigger for each upload
uploadOptions.storeOptions.workflows = @[@"WF-1", @"WF-2"];

// Some local URL to be uploaded
NSURL *someURL = ...;

FSUploader *uploader = [client uploadURLUsing:someURL
                                      options:uploadOptions
                                        queue:dispatch_get_main_queue()
                               uploadProgress:^(NSProgress * _Nonnull progress) {
                                   // Here you may update the UI to reflect the upload progress.
                                   NSLog(@"Progress: %@", progress);
                               }
                              completionHandler:^(FSNetworkJSONResponse * _Nullable response) {
         NSDictionary *jsonResponse = response.json;
         NSString *handle = jsonResponse[@"handle"];
         NSError *error = response.error;

         if (handle) {
             // Use Filestack handle
             NSLog(@"Handle is: %@", handle);
         } else if (error) {
             // Handle error
             NSLog(@"Error is: %@", error);
         }
     }
];

// Other alternative uploading methods are available in `FSClient`:
// - For multiple URL uploading: `uploadMultipleURLs:options:queue:uploadProgress:completionHandler:)`
// - For data uploading: `uploadDataUsing:options:queue:uploadProgress:completionHandler:)`
// - For multiple data uploading: `uploadMultipleDataUsing:options:queue:uploadProgress:completionHandler:)`

// Start upload (only useful when `startImmediately` option is `false`)
[uploader start];

// Cancel ongoing upload.
[uploader cancel];

// Query progress.
uploader.progress // returns an `NSProgress` object
```
</details>
</details>

<details>
<summary>Enabling background upload support</summary>

New in version `2.3`, we added support for uploading files in a background session. In order to activate this feature, please do the following:

```swift
// Set `UploadService.shared.useBackgroundSession` to true to allow uploads in the background.
FilestackSDK.UploadService.shared.useBackgroundSession = true
```
</details>

## Versioning

Filestack Swift SDK follows the [Semantic Versioning](http://semver.org/).

## Issues

If you have problems, please create a [Github Issue](https://github.com/filestack/filestack-swift/issues).

## Contributing

Please see [CONTRIBUTING.md](https://github.com/filestack/filestack-swift/blob/master/CONTRIBUTING.md) for details.

## Credits

Thank you to all the [contributors](https://github.com/filestack/filestack-swift/graphs/contributors).

[code_climate]: https://codeclimate.com/github/filestack/filestack-swift
[code_climate_badge]: https://codeclimate.com/github/filestack/filestack-swift.png
