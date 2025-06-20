//
//  FileTrasher.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation

/// Abstraction used for moving files to the Trash.
protocol FileTrasher {
    /// Moves the item at the provided URL to the Trash.
    func trashItem(at url: URL, resultingItemURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws
}

extension FileManager: FileTrasher {}
