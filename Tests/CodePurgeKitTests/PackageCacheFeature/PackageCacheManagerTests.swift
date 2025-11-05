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
    }
}


// MARK: - Load Folders Tests
extension PackageCacheManagerTests {
    @Test("Loads folders from package cache path using loader")
    func loadsFoldersFromPackageCachePathUsingLoader() throws {
        let folders = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
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

    @Test("Propagates load folders error from loader")
    func propagatesLoadFoldersErrorFromLoader() throws {
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.loadFolders()
        }
    }
}


// MARK: - Delete Specific Folders Tests
extension PackageCacheManagerTests {
    @Test("Deletes specified packages in correct order")
    func deletesSpecifiedPackagesInCorrectOrder() throws {
        let package1 = makePackageCacheFolder(name: "Package1")
        let package2 = makePackageCacheFolder(name: "Package2")
        let packagesToDelete = [package1, package2]
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders(packagesToDelete, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 2)
        guard delegate.deletedFolders.count >= 2 else { return }
        #expect(delegate.deletedFolders[0].name == package1.name)
        #expect(delegate.deletedFolders[1].name == package2.name)
    }

    @Test("Deletes single package successfully")
    func deletesSinglePackageSuccessfully() throws {
        let package = makePackageCacheFolder(name: "SinglePackage")
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([package], progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == package.name)
    }

    @Test("Completes successfully when given empty folder list")
    func completesSuccessfullyWhenGivenEmptyFolderList() throws {
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([], progressHandler: nil)

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let package = makePackageCacheFolder(name: "ErrorPackage")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([package], progressHandler: nil)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let package1 = makePackageCacheFolder(name: "Package1")
        let package2 = makePackageCacheFolder(name: "Package2")
        let (sut, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([package1, package2], progressHandler: nil)
        }

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Progress Handler Tests
extension PackageCacheManagerTests {
    @Test("Calls progress handler for each specified package")
    func callsProgressHandlerForEachSpecifiedPackage() throws {
        let package1 = makePackageCacheFolder(name: "Alpha")
        let package2 = makePackageCacheFolder(name: "Beta")
        let package3 = makePackageCacheFolder(name: "Gamma")
        let packagesToDelete = [package1, package2, package3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packagesToDelete, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(package1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(package2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(package3.name))
    }

    @Test("Calls progress handler in correct deletion order")
    func callsProgressHandlerInCorrectDeletionOrder() throws {
        let package1 = makePackageCacheFolder(name: "First")
        let package2 = makePackageCacheFolder(name: "Second")
        let package3 = makePackageCacheFolder(name: "Third")
        let package4 = makePackageCacheFolder(name: "Fourth")
        let packages = [package1, package2, package3, package4]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packages, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 4)
        guard progressHandler.progressUpdates.count == 4 else { return }
        for (index, package) in packages.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(package.name))
        }
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let package = makePackageCacheFolder(name: "TestPackage")
        let (sut, delegate) = makeSUT(foldersToLoad: [package])

        let folders = try sut.loadFolders()
        try sut.deleteFolders(folders, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == package.name)
    }

    @Test("Calls complete on progress handler after all deletions")
    func callsCompleteOnProgressHandlerAfterAllDeletions() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packages, progressHandler: progressHandler)

        #expect(progressHandler.didComplete)
    }

    @Test("Does not call progress handler when no packages to delete")
    func doesNotCallProgressHandlerWhenNoPackagesToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(foldersToLoad: [])

        try sut.deleteFolders([], progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.isEmpty)
    }
}


// MARK: - Find Dependencies Tests
extension PackageCacheManagerTests {
    @Test("Finds dependencies in specified path")
    func findsDependenciesInSpecifiedPath() throws {
        let path = "/test/project/path"
        let (sut, _) = makeSUT()

        let dependencies = try sut.findDependencies(in: path)

        #expect(dependencies.pins.isEmpty)
    }

    @Test("Uses current directory when path is nil")
    func usesCurrentDirectoryWhenPathIsNil() throws {
        let (sut, _) = makeSUT()

        let dependencies = try sut.findDependencies(in: nil)

        #expect(dependencies.pins.isEmpty)
    }

    @Test("Throws error when Package resolved not found")
    func throwsErrorWhenPackageResolvedNotFound() throws {
        let (sut, _) = makeSUT(packageResolvedExists: false)

        #expect(throws: PackageCacheError.self) {
            try sut.findDependencies(in: "/nonexistent/path")
        }
    }
}


// MARK: - SUT
private extension PackageCacheManagerTests {
    func makeSUT(
        throwError: Bool = false,
        foldersToLoad: [PackageCacheFolder] = [],
        packageResolvedExists: Bool = true
    ) -> (sut: PackageCacheManager, delegate: MockPackageCacheDelegate) {
        let mockFolders = foldersToLoad.map { MockPurgeFolder(folder: $0) }
        let loader = MockPurgeFolderLoader(throwError: throwError, foldersToLoad: mockFolders)
        let delegate = MockPackageCacheDelegate(throwError: throwError)
        let fileSystemDelegate = MockFileSystemDelegate(packageResolvedExists: packageResolvedExists)
        let sut = PackageCacheManager(loader: loader, delegate: delegate, fileSystemDelegate: fileSystemDelegate)

        return (sut, delegate)
    }
}


// MARK: - Mock Dependencies

private final class MockPackageCacheDelegate: PackageCacheDelegate {
    private let throwError: Bool
    private(set) var deletedFolders: [PackageCacheFolder] = []

    init(throwError: Bool) {
        self.throwError = throwError
    }

    func deleteFolder(_ folder: PackageCacheFolder) throws {
        if throwError {
            throw NSError(domain: "Test", code: 0)
        }

        deletedFolders.append(folder)
    }
}

private final class MockFileSystemDelegate: FileSystemDelegate {
    var currentDirectoryPath: String = "/test"
    private let packageResolvedExists: Bool

    init(packageResolvedExists: Bool = true) {
        self.packageResolvedExists = packageResolvedExists
    }

    func fileExists(atPath path: String) -> Bool {
        return packageResolvedExists
    }

    func appendingPathComponent(_ path: String, _ component: String) -> String {
        return (path as NSString).appendingPathComponent(component)
    }

    func readData(atPath path: String) throws -> Data {
        let emptyDependencies = """
        {
            "pins": [],
            "version": 2
        }
        """
        return emptyDependencies.data(using: .utf8)!
    }
}
