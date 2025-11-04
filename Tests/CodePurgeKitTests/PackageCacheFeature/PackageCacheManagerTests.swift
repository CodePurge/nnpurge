//
//  PackageCacheManagerTests.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import Foundation
import CodePurgeTesting
@testable import CodePurgeKit

struct PackageCacheManagerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, delegate) = makeSUT()

        #expect(delegate.deletedFolders.isEmpty)
        #expect(delegate.openedURL == nil)
    }
}


// MARK: - Load Folders Tests
extension PackageCacheManagerTests {
    @Test("Loads folders from package cache path using delegate")
    func loadsFoldersFromPackageCachePathUsingDelegate() throws {
        let folders = [
            makePurgeFolder(name: "Package1"),
            makePurgeFolder(name: "Package2")
        ]
        let (sut, _) = makeSUT(foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.count == folders.count)
        guard loadedFolders.count >= 2 else { return }
        #expect(loadedFolders[0].name == folders[0].name)
        #expect(loadedFolders[1].name == folders[1].name)
    }

    @Test("Returns empty array when no packages available")
    func returnsEmptyArrayWhenNoPackagesAvailable() throws {
        let (sut, _) = makeSUT(foldersToLoad: [])

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.isEmpty)
    }

    @Test("Propagates load folders error from delegate")
    func propagatesLoadFoldersErrorFromDelegate() throws {
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.loadFolders()
        }
    }
}


// MARK: - Delete All Packages Tests
extension PackageCacheManagerTests {
    @Test("Loads all packages and deletes them when deleting all")
    func loadsAllPackagesAndDeletesThemWhenDeletingAll() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let package3 = makePurgeFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let (sut, delegate) = makeSUT(foldersToLoad: packages)

        try sut.deleteAllPackages()

        #expect(delegate.deletedFolders.count == packages.count)
        #expect(delegate.deletedFolders.contains(where: { $0.name == package1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == package2.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == package3.name }))
    }

    @Test("Deletes no packages when none exist")
    func deletesNoPackagesWhenNoneExist() throws {
        let (sut, delegate) = makeSUT(foldersToLoad: [])

        try sut.deleteAllPackages()

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates load error during delete all operation")
    func propagatesLoadErrorDuringDeleteAllOperation() throws {
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteAllPackages()
        }
    }
}


// MARK: - Delete Specific Folders Tests
extension PackageCacheManagerTests {
    @Test("Deletes specified packages in correct order")
    func deletesSpecifiedPackagesInCorrectOrder() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let packagesToDelete = [package1, package2]
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders(packagesToDelete)

        #expect(delegate.deletedFolders.count == 2)
        guard delegate.deletedFolders.count >= 2 else { return }
        #expect(delegate.deletedFolders[0].name == package1.name)
        #expect(delegate.deletedFolders[1].name == package2.name)
    }

    @Test("Deletes single package successfully")
    func deletesSinglePackageSuccessfully() throws {
        let package = makePurgeFolder(name: "SinglePackage")
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([package])

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == package.name)
    }

    @Test("Completes successfully when given empty folder list")
    func completesSuccessfullyWhenGivenEmptyFolderList() throws {
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([])

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let package = makePurgeFolder(name: "ErrorPackage")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([package])
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let (sut, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([package1, package2])
        }

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Open Folder Tests
extension PackageCacheManagerTests {
    @Test("Opens folder at specified URL")
    func opensFolderAtSpecifiedURL() throws {
        let url = URL(fileURLWithPath: "/test/path/to/packages")
        let (sut, delegate) = makeSUT()

        try sut.openFolder(at: url)

        #expect(delegate.openedURL == url)
    }

    @Test("Propagates open folder error from delegate")
    func propagatesOpenFolderErrorFromDelegate() throws {
        let url = URL(fileURLWithPath: "/test/path")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.openFolder(at: url)
        }
    }
}


// MARK: - Progress Handler Tests
extension PackageCacheManagerTests {
    @Test("Calls progress handler for each package when deleting all")
    func callsProgressHandlerForEachPackageWhenDeletingAll() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let package3 = makePurgeFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(foldersToLoad: packages)

        try sut.deleteAllPackages(progressHandler: progressHandler)

        #expect(progressHandler.deletedFolders.count == packages.count)
        guard progressHandler.deletedFolders.count >= 3 else { return }
        #expect(progressHandler.deletedFolders[0].name == package1.name)
        #expect(progressHandler.deletedFolders[1].name == package2.name)
        #expect(progressHandler.deletedFolders[2].name == package3.name)
    }

    @Test("Calls progress handler for each specified package")
    func callsProgressHandlerForEachSpecifiedPackage() throws {
        let package1 = makePurgeFolder(name: "Alpha")
        let package2 = makePurgeFolder(name: "Beta")
        let package3 = makePurgeFolder(name: "Gamma")
        let packagesToDelete = [package1, package2, package3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packagesToDelete, progressHandler: progressHandler)

        #expect(progressHandler.deletedFolders.count == 3)
        guard progressHandler.deletedFolders.count >= 3 else { return }
        #expect(progressHandler.deletedFolders[0].name == package1.name)
        #expect(progressHandler.deletedFolders[1].name == package2.name)
        #expect(progressHandler.deletedFolders[2].name == package3.name)
    }

    @Test("Does not call progress handler when no packages to delete")
    func doesNotCallProgressHandlerWhenNoPackagesToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(foldersToLoad: [])

        try sut.deleteAllPackages(progressHandler: progressHandler)

        #expect(progressHandler.deletedFolders.isEmpty)
    }

    @Test("Calls progress handler in correct deletion order")
    func callsProgressHandlerInCorrectDeletionOrder() throws {
        let package1 = makePurgeFolder(name: "First")
        let package2 = makePurgeFolder(name: "Second")
        let package3 = makePurgeFolder(name: "Third")
        let package4 = makePurgeFolder(name: "Fourth")
        let packages = [package1, package2, package3, package4]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packages, progressHandler: progressHandler)

        #expect(progressHandler.deletedFolders.count == 4)
        guard progressHandler.deletedFolders.count == 4 else { return }
        for (index, package) in packages.enumerated() {
            #expect(progressHandler.deletedFolders[index].name == package.name)
        }
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let package = makePurgeFolder(name: "TestPackage")
        let (sut, delegate) = makeSUT(foldersToLoad: [package])

        try sut.deleteAllPackages(progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == package.name)
    }

    @Test("Works correctly using convenience method without progress handler")
    func worksCorrectlyUsingConvenienceMethodWithoutProgressHandler() throws {
        let package1 = makePurgeFolder(name: "ConveniencePackage1")
        let package2 = makePurgeFolder(name: "ConveniencePackage2")
        let packages = [package1, package2]
        let (sut, delegate) = makeSUT(foldersToLoad: packages)

        try sut.deleteAllPackages()

        #expect(delegate.deletedFolders.count == 2)
    }
}


// MARK: - SUT
private extension PackageCacheManagerTests {
    func makeSUT(
        throwError: Bool = false,
        foldersToLoad: [PurgeFolder] = []
    ) -> (sut: PackageCacheManager, delegate: MockPurgeDelegate) {
        let delegate = MockPurgeDelegate(throwError: throwError, foldersToLoad: foldersToLoad)
        let sut = PackageCacheManager(delegate: delegate)

        return (sut, delegate)
    }
}
