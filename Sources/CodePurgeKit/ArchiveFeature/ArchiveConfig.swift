//
//  ArchiveConfig.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation

struct ArchiveConfig {
    let path: String
    let calculateSize: Bool
    let includeImageData: Bool
}


// MARK: - Helpers
extension ArchiveConfig {
    static var defaultConfig: ArchiveConfig {
        return .init(path: NSString(string: "~/Library/Developer/Xcode/Archives").expandingTildeInPath, calculateSize: false, includeImageData: false)
    }
}
