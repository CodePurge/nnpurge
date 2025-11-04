//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public protocol DerivedDataService: PurgeService {
    func deleteAllDerivedData(progressHandler: PurgeProgressHandler?) throws
}

public extension DerivedDataService {
    func deleteAllDerivedData() throws {
        try deleteAllDerivedData(progressHandler: nil)
    }

    // Default implementation of PurgeService.deleteAllFolders using deleteAllDerivedData
    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        try deleteAllDerivedData(progressHandler: progressHandler)
    }
}
