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

        #expect(delegate.deletedURLs.isEmpty)
    }
}


// MARK: - Load Folders Tests
extension PackageCacheManagerTests {
    @Test("Loads folders from package cache path using loader")
    func loadsFoldersFromPackageCachePathUsingLoader() throws {
        let folders = [
            makeMockPurgeFolder(name: "Package1-abc123"),
            makeMockPurgeFolder(name: "Package2-def456")
        ]
        let (sut, _) = makeSUT(foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.count == folders.count)
        guard loadedFolders.count >= 2 else { return }
        #expect(loadedFolders[0].name == "Package1")
        #expect(loadedFolders[0].branchId == "abc123")
        #expect(loadedFolders[1].name == "Package2")
        #expect(loadedFolders[1].branchId == "def456")
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

    @Test("Filters out folders without valid branch ID format")
    func filtersOutFoldersWithoutValidBranchIdFormat() throws {
        let folders = [
            makeMockPurgeFolder(name: "ValidPackage-abc123"),
            makeMockPurgeFolder(name: "InvalidPackage")
        ]
        let (sut, _) = makeSUT(foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.count == 1)
        guard loadedFolders.count >= 1 else { return }
        #expect(loadedFolders[0].name == "ValidPackage")
        #expect(loadedFolders[0].branchId == "abc123")
    }
}


// MARK: - Delete Specific Folders Tests
extension PackageCacheManagerTests {
    @Test("Deletes specified packages in correct order")
    func deletesSpecifiedPackagesInCorrectOrder() throws {
        let package1 = makePackageCacheFolder(name: "Package1", branchId: "abc123")
        let package2 = makePackageCacheFolder(name: "Package2", branchId: "def456")
        let packagesToDelete = [package1, package2]
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders(packagesToDelete, force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 2)
        guard delegate.deletedURLs.count >= 2 else { return }
        #expect(delegate.deletedURLs[0] == package1.url)
        #expect(delegate.deletedURLs[1] == package2.url)
    }

    @Test("Deletes single package successfully")
    func deletesSinglePackageSuccessfully() throws {
        let package = makePackageCacheFolder(name: "SinglePackage", branchId: "xyz789")
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([package], force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
        guard delegate.deletedURLs.count >= 1 else { return }
        #expect(delegate.deletedURLs[0] == package.url)
    }

    @Test("Completes successfully when given empty folder list")
    func completesSuccessfullyWhenGivenEmptyFolderList() throws {
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([], force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let package = makePackageCacheFolder(name: "ErrorPackage", branchId: "err123")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([package], force: false, progressHandler: nil)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let package1 = makePackageCacheFolder(name: "Package1", branchId: "abc123")
        let package2 = makePackageCacheFolder(name: "Package2", branchId: "def456")
        let (sut, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([package1, package2], force: false, progressHandler: nil)
        }

        #expect(delegate.deletedURLs.isEmpty)
    }
}


// MARK: - Progress Handler Tests
extension PackageCacheManagerTests {
    @Test("Calls progress handler for each specified package")
    func callsProgressHandlerForEachSpecifiedPackage() throws {
        let package1 = makePackageCacheFolder(name: "Alpha", branchId: "a1")
        let package2 = makePackageCacheFolder(name: "Beta", branchId: "b2")
        let package3 = makePackageCacheFolder(name: "Gamma", branchId: "g3")
        let packagesToDelete = [package1, package2, package3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packagesToDelete, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(package1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(package2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(package3.name))
    }

    @Test("Calls progress handler in correct deletion order")
    func callsProgressHandlerInCorrectDeletionOrder() throws {
        let package1 = makePackageCacheFolder(name: "First", branchId: "f1")
        let package2 = makePackageCacheFolder(name: "Second", branchId: "s2")
        let package3 = makePackageCacheFolder(name: "Third", branchId: "t3")
        let package4 = makePackageCacheFolder(name: "Fourth", branchId: "f4")
        let packages = [package1, package2, package3, package4]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packages, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 4)
        guard progressHandler.progressUpdates.count == 4 else { return }
        for (index, package) in packages.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(package.name))
        }
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let mockFolder = makeMockPurgeFolder(name: "TestPackage-test123")
        let (sut, delegate) = makeSUT(foldersToLoad: [mockFolder])

        let folders = try sut.loadFolders()
        try sut.deleteFolders(folders, force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
        guard delegate.deletedURLs.count >= 1 else { return }
        #expect(delegate.deletedURLs[0] == mockFolder.url)
    }

    @Test("Calls complete on progress handler after all deletions")
    func callsCompleteOnProgressHandlerAfterAllDeletions() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1", branchId: "p1"),
            makePackageCacheFolder(name: "Package2", branchId: "p2")
        ]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(packages, force: false, progressHandler: progressHandler)

        #expect(progressHandler.didComplete)
    }

    @Test("Does not call progress handler when no packages to delete")
    func doesNotCallProgressHandlerWhenNoPackagesToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(foldersToLoad: [])

        try sut.deleteFolders([], force: false, progressHandler: progressHandler)

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


// MARK: - Xcode Running Check Tests
extension PackageCacheManagerTests {
    @Test("Prevents deletion when Xcode is running and force is false")
    func preventsDeletionWhenXcodeIsRunningAndForceIsFalse() throws {
        let package = makePackageCacheFolder(name: "TestPackage", branchId: "abc123")
        let (sut, _) = makeSUT(xcodeRunningStatus: true)

        #expect(throws: PackageCacheError.xcodeIsRunning) {
            try sut.deleteFolders([package], force: false, progressHandler: nil)
        }
    }

    @Test("Bypasses Xcode check when force is true")
    func bypassesXcodeCheckWhenForceIsTrue() throws {
        let package1 = makePackageCacheFolder(name: "Package1", branchId: "abc123")
        let package2 = makePackageCacheFolder(name: "Package2", branchId: "def456")
        let packages = [package1, package2]
        let (sut, delegate) = makeSUT(xcodeRunningStatus: true)

        try sut.deleteFolders(packages, force: true, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 2)
        guard delegate.deletedURLs.count >= 2 else { return }
        #expect(delegate.deletedURLs[0] == package1.url)
        #expect(delegate.deletedURLs[1] == package2.url)
    }

    @Test("Allows deletion when Xcode is not running")
    func allowsDeletionWhenXcodeIsNotRunning() throws {
        let package = makePackageCacheFolder(name: "TestPackage", branchId: "xyz789")
        let (sut, delegate) = makeSUT(xcodeRunningStatus: false)

        try sut.deleteFolders([package], force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
        guard delegate.deletedURLs.count >= 1 else { return }
        #expect(delegate.deletedURLs[0] == package.url)
    }

    @Test("Checks Xcode status before attempting deletion")
    func checksXcodeStatusBeforeAttemptingDeletion() throws {
        let package1 = makePackageCacheFolder(name: "Package1", branchId: "p1")
        let package2 = makePackageCacheFolder(name: "Package2", branchId: "p2")
        let package3 = makePackageCacheFolder(name: "Package3", branchId: "p3")
        let packages = [package1, package2, package3]
        let (sut, delegate) = makeSUT(xcodeRunningStatus: true)

        #expect(throws: PackageCacheError.xcodeIsRunning) {
            try sut.deleteFolders(packages, force: false, progressHandler: nil)
        }

        #expect(delegate.deletedURLs.isEmpty)
    }

    @Test("Does not call progress handler when Xcode running check fails")
    func doesNotCallProgressHandlerWhenXcodeRunningCheckFails() throws {
        let package = makePackageCacheFolder(name: "Package", branchId: "xyz")
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(xcodeRunningStatus: true)

        #expect(throws: PackageCacheError.xcodeIsRunning) {
            try sut.deleteFolders([package], force: false, progressHandler: progressHandler)
        }

        #expect(progressHandler.progressUpdates.isEmpty)
        #expect(!progressHandler.didComplete)
    }

    @Test("Deletes multiple packages when force is true despite Xcode running")
    func deletesMultiplePackagesWhenForceIsTrueDespiteXcodeRunning() throws {
        let package1 = makePackageCacheFolder(name: "Package1", branchId: "a1")
        let package2 = makePackageCacheFolder(name: "Package2", branchId: "b2")
        let package3 = makePackageCacheFolder(name: "Package3", branchId: "c3")
        let packages = [package1, package2, package3]
        let (sut, delegate) = makeSUT(xcodeRunningStatus: true)

        try sut.deleteFolders(packages, force: true, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 3)
        #expect(delegate.deletedURLs.contains(package1.url))
        #expect(delegate.deletedURLs.contains(package2.url))
        #expect(delegate.deletedURLs.contains(package3.url))
    }
}


// MARK: - Close Xcode Tests
extension PackageCacheManagerTests {
    @Test("Closes Xcode successfully when termination succeeds")
    func closesXcodeSuccessfullyWhenTerminationSucceeds() throws {
        let (sut, _) = makeSUT(xcodeRunningStatus: false, xcodeTerminationSucceeds: true)

        try sut.closeXcodeAndVerify(timeout: 0.1)
    }

    @Test("Throws error when Xcode termination fails")
    func throwsErrorWhenXcodeTerminationFails() throws {
        let (sut, _) = makeSUT(xcodeTerminationSucceeds: false)

        #expect(throws: PackageCacheError.xcodeFailedToClose) {
            try sut.closeXcodeAndVerify(timeout: 0.1)
        }
    }

    @Test("Throws error when Xcode still running after timeout")
    func throwsErrorWhenXcodeStillRunningAfterTimeout() throws {
        let (sut, _) = makeSUT(xcodeRunningStatus: true, xcodeTerminationSucceeds: true)

        #expect(throws: PackageCacheError.xcodeFailedToClose) {
            try sut.closeXcodeAndVerify(timeout: 0.1)
        }
    }

    @Test("Verifies Xcode closure after successful termination")
    func verifiesXcodeClosureAfterSuccessfulTermination() throws {
        let (sut, _) = makeSUT(xcodeRunningStatus: false, xcodeTerminationSucceeds: true)

        try sut.closeXcodeAndVerify(timeout: 1.0)
    }
}


// MARK: - SUT
private extension PackageCacheManagerTests {
    func makeSUT(
        throwError: Bool = false,
        foldersToLoad: [MockPurgeFolder] = [],
        packageResolvedExists: Bool = true,
        xcodeRunningStatus: Bool = false,
        xcodeTerminationSucceeds: Bool = true
    ) -> (sut: PackageCacheManager, delegate: MockPackageCacheDelegate) {
        let loader = MockPurgeFolderLoader(throwError: throwError, foldersToLoad: foldersToLoad)
        let delegate = MockPackageCacheDelegate(throwError: throwError)
        let fileSystemDelegate = MockFileSystemDelegate(packageResolvedExists: packageResolvedExists)
        let xcodeChecker = MockXcodeStatusChecker(xcodeRunningStatus: xcodeRunningStatus)
        let xcodeTerminator = MockXcodeTerminator(terminationSucceeds: xcodeTerminationSucceeds)
        let sut = PackageCacheManager(loader: loader, delegate: delegate, fileSystemDelegate: fileSystemDelegate, xcodeChecker: xcodeChecker, xcodeTerminator: xcodeTerminator)

        return (sut, delegate)
    }

    func makeMockPurgeFolder(name: String) -> MockPurgeFolder {
        return MockPurgeFolder(name: name)
    }

    func makePackageCacheFolder(name: String, branchId: String) -> PackageCacheFolder {
        let url = URL(fileURLWithPath: "/test/path/\(name)-\(branchId)")
        return PackageCacheFolder(
            url: url,
            name: name,
            path: url.path,
            creationDate: Date(),
            modificationDate: Date(),
            branchId: branchId,
            lastFetchedDate: "/test/path/\(name)-\(branchId)/FETCH_HEAD"
        )
    }
}


// MARK: - Mock Dependencies

private final class MockPackageCacheDelegate: PackageCacheDelegate {
    private let throwError: Bool

    private(set) var deletedURLs: [URL] = []

    init(throwError: Bool) {
        self.throwError = throwError
    }

    func deleteFolder(_ folder: PackageCacheFolder) throws {
        try deleteItem(at: folder.url)
    }

    func deleteItem(at url: URL) throws {
        if throwError {
            throw NSError(domain: "Test", code: 0)
        }
        deletedURLs.append(url)
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

private struct MockXcodeStatusChecker: XcodeStatusChecker {
    let xcodeRunningStatus: Bool

    init(xcodeRunningStatus: Bool = false) {
        self.xcodeRunningStatus = xcodeRunningStatus
    }

    func isXcodeRunning() -> Bool {
        return xcodeRunningStatus
    }
}

private struct MockXcodeTerminator: XcodeTerminator {
    let terminationSucceeds: Bool

    init(terminationSucceeds: Bool = true) {
        self.terminationSucceeds = terminationSucceeds
    }

    func terminateXcode() -> Bool {
        return terminationSucceeds
    }
}
