//
//  MockPackageCacheProgressHandler.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
@testable import CodePurgeKit

final class MockPackageCacheProgressHandler: @unchecked Sendable, PackageCacheProgressHandler {
    private(set) var deletedFolders: [PurgeFolder] = []

    func didDeleteFolder(_ folder: PurgeFolder) {
        deletedFolders.append(folder)
    }
}
