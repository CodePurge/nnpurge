//
//  DefaultXcodeStatusChecker.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation
import AppKit

struct DefaultXcodeStatusChecker: XcodeStatusChecker {
    func isXcodeRunning() -> Bool {
        return NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dt.Xcode").isEmpty == false
    }
}
