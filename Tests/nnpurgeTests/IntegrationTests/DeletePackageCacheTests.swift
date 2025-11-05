//
//  DeletePackageCacheTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import Foundation
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

@MainActor
final class DeletePackageCacheTests {
    @Test("Deletes all packages when all flag passed", arguments: ["-a", "--all"])
    func deletesAllPackagesWhenAllFlagPassed(deleteAllArg: String) throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (factory, service) = makeSUT(packageCacheFoldersToLoad: packages)

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete", deleteAllArg])

        #expect(service.deletedPackageCacheFolders.count == packages.count)
    }

    @Test("Deletes all packages when option is selected from picker input")
    func deletesAllPackagesFromPickerInput() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (factory, service) = makeSUT(
            packageCacheFoldersToLoad: packages,
            selectionResult: .init(defaultIndex: 0)
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(service.deletedPackageCacheFolders.count == packages.count)
    }

    @Test("Deletes selected packages when selectFolders option chosen")
    func deletesSelectedPackagesWhenSelectFoldersOptionChosen() throws {
        let package1 = makePackageCacheFolder(name: "Alamofire-1a2b3c4d")
        let package2 = makePackageCacheFolder(name: "SwiftyJSON-5e6f7g8h")
        let package3 = makePackageCacheFolder(name: "Kingfisher-9i0j1k2l")
        let packages = [package1, package2, package3]
        let selectedIndices = [0, 2]
        let (factory, service) = makeSUT(
            packageCacheFoldersToLoad: packages,
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(service.deletedPackageCacheFolders.count == 2)
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == package1.name }))
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == package3.name }))
    }

    @Test("Deletes no packages when user selects none during package selection")
    func deletesNoPackagesWhenUserSelectsNoneDuringPackageSelection() throws {
        let packages = [
            makePackageCacheFolder(name: "Alamofire-1a2b3c4d"),
            makePackageCacheFolder(name: "SwiftyJSON-5e6f7g8h"),
            makePackageCacheFolder(name: "Kingfisher-9i0j1k2l")
        ]
        let (factory, service) = makeSUT(
            packageCacheFoldersToLoad: packages,
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(service.deletedPackageCacheFolders.isEmpty)
    }

    @Test("Deletes stale packages when deleteStale option selected")
    func deleteStalePackagesWhenDeleteStaleOptionSelected() throws {
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())
        let recentDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        let stalePackage1 = makePackageCacheFolder(name: "OldPackage1", modificationDate: oldDate)
        let stalePackage2 = makePackageCacheFolder(name: "OldPackage2", modificationDate: oldDate)
        let recentPackage = makePackageCacheFolder(name: "RecentPackage", modificationDate: recentDate)
        let (factory, service) = makeSUT(
            packageCacheFoldersToLoad: [stalePackage1, stalePackage2, recentPackage],
            selectionResult: .init(defaultIndex: 1)
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(service.deletedPackageCacheFolders.count == 2)
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == stalePackage1.name }))
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == stalePackage2.name }))
    }
}


// MARK: - SUT
private extension DeletePackageCacheTests {
    func makeSUT(
        packageCacheFoldersToLoad: [PackageCacheFolder] = [],
        selectionResult: MockSelectionResult = .init()
    ) -> (factory: MockContextFactory, service: MockPurgeService) {
        let service = MockPurgeService(packageCacheFoldersToLoad: packageCacheFoldersToLoad)
        let picker = makePicker(selectionResult: selectionResult)
        let factory = MockContextFactory(
            picker: picker,
            packageCacheService: service
        )

        return (factory, service)
    }

    func makePicker(selectionResult: MockSelectionResult) -> MockSwiftPicker {
        return .init(
            permissionResult: .init(grantByDefault: true, type: .ordered([])),
            selectionResult: selectionResult
        )
    }

    func makePackageCacheFolder(name: String, modificationDate: Date? = nil) -> PackageCacheFolder {
        let url = URL(fileURLWithPath: "/path/to/PackageCache/\(name)")
        let date = modificationDate ?? Date()

        return .init(
            url: url,
            name: name,
            path: url.path,
            creationDate: date,
            modificationDate: date,
            branchId: "main",
            lastFetchedDate: nil
        )
    }
}
