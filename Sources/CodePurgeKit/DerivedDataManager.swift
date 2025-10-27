//
//  DerivedDataManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Files

public struct DerivedDataManager {
    private let store: PurgeRecordStore
    private let delegate: DerivedDataDelegate
    
    init(store: PurgeRecordStore, delegate: DerivedDataDelegate) {
        self.store = store
        self.delegate = delegate
    }
}


// MARK: - Init
public extension DerivedDataManager {
    init() {
        self.init(store: DefaultPurgeRecordStore(), delegate: DefaultDerivedDataDelegate())
    }
}


// MARK: - Actions
public extension DerivedDataManager {
    func loadFolders() -> [Folder] {
        return [] // TODO: -
    }
    
    func deleteAllDerivedData() throws {
        // TODO: - 
    }
    
    func deleteFolders(_ folders: [Folder]) throws {
        // TODO: -
    }
}


// MARK: - Dependencies
protocol PurgeRecordStore {
    
}

protocol DerivedDataDelegate {
    
}

struct DefaultPurgeRecordStore: PurgeRecordStore { }
struct DefaultDerivedDataDelegate: DerivedDataDelegate { }
