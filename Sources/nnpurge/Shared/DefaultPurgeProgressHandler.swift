//
//  DefaultPurgeProgressHandler.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import ANSITerminal
import CodePurgeKit

public final class ConsoleProgressBar: PurgeProgressHandler {
    private let width: Int
    
    private var current = 0
    private var firstUpdate = true

    public init(width: Int = 50) {
        self.width = width
    }

    public func updateProgress(current: Int, total: Int, message: String) {
        self.current = current
        let total = total
        let progress = Double(current) / Double(total)
        let filled = Int(progress * Double(width))
        let empty = width - filled
        let bar = String(repeating: "█", count: filled) + String(repeating: "-", count: empty)
        let percent = String(format: "%.2f%%", progress * 100)

        if !firstUpdate { print("\u{1B}[2A", terminator: "") }
        else { firstUpdate = false }

        print("\u{1B}[2K\(message)")
        print("\u{1B}[2K\(bar) \(percent)")
        fflush(stdout)
    }

    public func complete(message: String? = nil) {
        if let message = message {
            print("\n\(message)")
        } else {
            print("\n✅ Completed.")
        }
    }
}
