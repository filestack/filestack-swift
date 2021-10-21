//
//  AppDelegate.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import UIKit
import FilestackSDK
import BGUploader

private let fsClient: Client = {
    // Set your Filestack's API key here.
    let filestackAPIKey = ""

    // Set your Filestack's app secret here.
    let filestackAppSecret = ""

    if filestackAPIKey.isEmpty { assertionFailure("Filestack API key must be present") }
    if filestackAppSecret.isEmpty { assertionFailure("Filestack App Secret must be present") }

    let policy = Policy(expiry: .distantFuture, call: [.store])
    let security = try! Security(policy: policy, appSecret: filestackAppSecret)

    // IMPORTANT: If your Filestack account does not have security setting enabled, you should set `security` to `nil`
    // and, optionally, you may remove `filestackAppSecret`, `policy` and `security` variables above.
    return Client(apiKey: filestackAPIKey, security: security)
}()

/// Background upload service defined in `BGUploader` framework.
/// Initialize it by passing a Filestack client setup with your API key and security settings.
let bgUploadService = BGUploadService(fsClient: fsClient)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var uploadAlertController: UIAlertController?
    var responses = [StoreResponse]()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set `bgUploadService` upon launching the app.
        bgUploadService.delegate = self

        return true
    }

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        if identifier == bgUploadService.backgroundIdentifer {
            // Set `bgUploadService` delegate and resume pending uploads.
            bgUploadService.delegate = self
            bgUploadService.resumePendingUploads(completionHandler: completionHandler)
        }
    }
}

extension AppDelegate: BGUploadServiceDelegate {
    /// Called after an upload task completes (either successfully or failing.)
    ///
    /// You may query `url` to determine the file `URL` that was uploaded and `status` to determine completion status
    /// on the returned `BackgroundUploadTaskResult` object.
    func uploadService(_ uploadService: BGUploadService, didCompleteWith result: BackgroundUploadTaskResult) {
        // Present alert showing completed and failed uploads.
        let alertController = presentedAlertController()

        switch result.status {
        case let .completed(response):
            // Collect successful responses, se we can display them as part of our alert message.
            responses.append(response)

            // Just for the purposes of this demo, we'll be deleting the files uploaded to Filestack right after they
            // finished uploading to prevent piling up useless files on the final storage destination.
            fsClient.fileLink(for: response.handle).delete { _ in
                print("Deleted \(response.handle) from Filestack.")
            }

            // Update alert title and message signaling a completed response.
            let message = responses
                .enumerated()
                .map { "(\($0.offset + 1)) \($0.element.filename) -> \($0.element.handle)" }
                .joined(separator: "\n")

            alertController.title = "Got response"
            alertController.message = message
        case let .failed(error):
            // Update alert title and message signaling an error occurred.
            alertController.title = "Got error"
            alertController.message = error.localizedDescription
            // TODO: Retry upload for `result.url` if necessary.
        default:
            break
        }
    }
}

extension AppDelegate {
    // Present an alert, if it is not already present.
    func presentedAlertController() -> UIAlertController {
        if let alertController = uploadAlertController { return alertController }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true) {
                self.uploadAlertController = nil
                // Clear successful responses.
                self.responses = []
            }
        })

        self.uploadAlertController = alertController

        window?.rootViewController?.present(alertController, animated: true)

        return alertController
    }
}
