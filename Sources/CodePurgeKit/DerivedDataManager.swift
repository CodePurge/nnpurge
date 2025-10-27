//
//  DerivedDataManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

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
    func loadFolders() -> [PurgeFolder] {
        return delegate.loadFolders()
    }

    func deleteAllDerivedData() throws {
        let allFolders = loadFolders()
        
        try deleteFolders(allFolders)
    }

    func deleteFolders(_ folders: [PurgeFolder]) throws {
        for folder in folders {
            try delegate.deleteFolder(folder)
            // TODO: - update progress?
        }
        
        // TODO: - save purge record?
    }
}


// MARK: - Dependencies
protocol PurgeRecordStore {
    
}

protocol DerivedDataDelegate {
    func loadFolders() -> [PurgeFolder]
    func deleteFolder(_ folder: PurgeFolder) throws
}

struct DefaultPurgeRecordStore: PurgeRecordStore { }
struct DefaultDerivedDataDelegate: DerivedDataDelegate {
    func loadFolders() -> [PurgeFolder] {
        return [] // TODO: -
    }
    
    func deleteFolder(_ folder: PurgeFolder) throws {
        // TODO: -
    }
}
