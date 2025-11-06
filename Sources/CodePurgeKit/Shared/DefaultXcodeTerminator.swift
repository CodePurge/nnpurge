//
//  DefaultXcodeTerminator.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation
import AppKit

struct DefaultXcodeTerminator: XcodeTerminator {
    func terminateXcode() -> Bool {
        let xcodeApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dt.Xcode")

        guard let xcode = xcodeApps.first else {
            return false
        }

        return xcode.terminate()
    }
}
