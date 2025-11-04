//
//  DefaultPurgeProgressHandler.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import ANSITerminal
import CodePurgeKit

struct DefaultPurgeProgressHandler: PurgeProgressHandler {
    func didDeleteFolder(_ folder: PurgeFolder) {
        print("\("✓".green) Moved to trash: \(folder.name)")
    }
}
