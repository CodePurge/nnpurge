//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

// Type alias for progress handler to maintain API compatibility
public typealias DerivedDataProgressHandler = PurgeProgressHandler

// DerivedDataService now inherits from PurgeService
public protocol DerivedDataService: PurgeService {
    func deleteAllDerivedData(progressHandler: DerivedDataProgressHandler?) throws
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
