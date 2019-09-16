//
//  MirroredProgress.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Holds a mirrored copy of itself and its children, so the copy may be publicly returned by classes that report
/// progress instead of returning the original.
///
/// It also sets observers on `isCancelled` and `isPaused` on the mirrored `Progress`, so the original may be
/// cancelled or paused by the mirror.
///
/// Typically, the `MirroredProgress` object will be private, while the `mirror` may be publicly exposed by using
/// a lazy property:
///
/// ```
/// private let masterProcess = MirroredProgress()
///
/// public lazy var progress: Progress = {
///    masterProgress.mirror
/// }()
/// ```
class MirroredProgress: Progress {
    let mirror = Progress(totalUnitCount: 0)

    var isPausedObserver: NSKeyValueObservation?
    var isCancelledObserver: NSKeyValueObservation?

    // MARK: - Overrides

    override init(parent parentProgressOrNil: Progress?, userInfo userInfoOrNil: [ProgressUserInfoKey: Any]? = nil) {
        super.init(parent: parentProgressOrNil, userInfo: userInfoOrNil)
        setMirrorObservers()
    }

    override var completedUnitCount: Int64 {
        didSet { mirror.completedUnitCount = completedUnitCount }
    }

    override var totalUnitCount: Int64 {
        didSet { mirror.totalUnitCount = totalUnitCount }
    }

    override func addChild(_ child: Progress, withPendingUnitCount inUnitCount: Int64) {
        super.addChild(child, withPendingUnitCount: inUnitCount)

        if let child = child as? MirroredProgress {
            mirror.addChild(child.mirror, withPendingUnitCount: inUnitCount)
        }
    }

    // MARK: - Private Functions

    private func setMirrorObservers() {
        isPausedObserver = mirror.observe(\.isPaused, options: [.new]) { _, change in
            if change.newValue == true {
                self.pause()
            } else {
                self.resume()
            }
        }

        isCancelledObserver = mirror.observe(\.isCancelled, options: [.new]) { _, change in
            if change.newValue == true {
                self.cancel()
            }
        }
    }
}
