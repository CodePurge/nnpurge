//
//  ConsoleProgressBar.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import ANSITerminal
import CodePurgeKit

public final class ConsoleProgressBar {
    private let width: Int
    
    private var current = 0
    private var firstUpdate = true
    
    public init(width: Int = 50) {
        self.width = width
    }
}


// MARK: - PurgeProgressHandler
extension ConsoleProgressBar: PurgeProgressHandler {
    public func complete(message: String? = nil) {
        if let message = message {
            print("\n\u{1B}[32m✅ \(message)\u{1B}[0m")
        } else {
            print("\n\u{1B}[32m✅ Completed.\u{1B}[0m")
        }
    }

    public func updateProgress(current: Int, total: Int, message: String) {
        self.current = current
        let total = total
        let progress = Double(current) / Double(total)
        let filled = Int(progress * Double(width))
        let empty = width - filled
        let greenBar = "\u{1B}[32m" + String(repeating: "█", count: filled) + "\u{1B}[0m"
        let emptyBar = String(repeating: "-", count: empty)
        let bar = greenBar + emptyBar
        let percent = "\u{1B}[32m\(String(format: "%.2f%%", progress * 100))\u{1B}[0m"

        if !firstUpdate { print("\u{1B}[2A", terminator: "") }
        else { firstUpdate = false }

        print("\u{1B}[2K\(message)")
        print("\u{1B}[2K\(bar) \(percent)")
        fflush(stdout)
    }
}
