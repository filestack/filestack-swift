Change Log
==========

Version 2.0 *(2019-06-15)*
----------------------------

- Added synchronous document transformations support.
- Added workflows support.
- Added several missing typealiases to `Transform`.
- Fixed multipart upload failure during the complete operation stage (PR #12.)
- Fixed some memory leaks in multipart uploads.
- Deprecated `store(fileName:,location:,path:,container:,region:,access:,base64Decode:,queue:,completionHandler:)` (now `store(using:,base64Decode:,queue:,completionHandler:)`) in `Transformable` class.
- `RoundedCornersTransform` transformation is now working as expected (was `RoundCornersTransform` before.)
- Deprecated `AsciiTransform` (now `ASCIITransform`).
- Deprecated `ProgressiveJpegTransform` (now `ProgressiveJPEGTransform`).
- Deprecated `RoundCornersTransform` (now `RoundedCornersTransform`).
- Deprecated `UrlScreenshotTransform` (now `URLScreenshotTransform`).
- Dropped support for iOS versions earlier than 11.0.
- Dropped support for Swift versions earlier than 4.2.

Version 1.2.7 *(2018-07-18)*
----------------------------

- Fix test target.

Version 1.2.6 *(2018-06-20)*
----------------------------

- Added new image content detection transforms.

Version 1.2.5 *(2018-06-18)*
----------------------------

- Added new Transforms.
- Moved some Transform related string to enums.


Version 1.2.4 *(2018-06-11)*
----------------------------

- Added `MultifileUpload` class.


Version 1.2.3 *(2018-06-01)*
----------------------------

- Updated CryptoSwift to version 0.10.0.

Version 1.2.2 *(2017-12-19)*
----------------------------

- Added @objc decorator to MultipartUpload's `cancel()` function.

Version 1.2.1 *(2017-12-19)*
----------------------------

- Updated CryptoSwift and Alamofire dependencies.
- Upgraded code to Swift 4.

Version 1.2 *(2017-11-20)*
----------------------------

- Migrated from Arcane to CryptoSwift.

Version 1.1 *(2017-11-03)*
----------------------------

- Added support for store options to uploads functionality.
- Improved upload error reporting.

Version 1.0.2 *(2017-11-01)*
----------------------------

- Disabled new Xcode build system to prevent issues with Carthage builds.
- Updated Arcane dependency to version 1.0.
- Updated Alamofire dependency to version 4.5.1.

Version 1.0.1 *(2017-10-31)*
----------------------------

- Added `startUploadImmediately` argument and turning `localURL` into an optional argument in `Client` `multipartUpload` function.
- Declared `MultipartUpload` `uploadFile()` function public.
- Added `StorageOptions` class.

Version 1.0 *(2017-08-23)*
----------------------------

Initial release.
