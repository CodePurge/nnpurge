//
//  DeletePackageCacheTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

@MainActor
final class DeletePackageCacheTests {
    @Test("Deletes all packages when all flag passed", arguments: ["-a", "--all"])
    func deletesAllPackagesWhenAllFlagPassed(deleteAllArg: String) throws {
        let (factory, service) = makeSUT()

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete", deleteAllArg])

        #expect(service.didDeleteAllPackages)
    }

    @Test("Deletes all packages when option is selected from picker input")
    func deletesAllPackagesFromPickerInput() throws {
        let (factory, service) = makeSUT(
            selectionResult: .init(defaultIndex: 0)
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(service.didDeleteAllPackages)
    }

    @Test("Deletes selected packages when selectFolders option chosen")
    func deletesSelectedPackagesWhenSelectFoldersOptionChosen() throws {
        let package1 = makePurgeFolder(name: "Alamofire-1a2b3c4d")
        let package2 = makePurgeFolder(name: "SwiftyJSON-5e6f7g8h")
        let package3 = makePurgeFolder(name: "Kingfisher-9i0j1k2l")
        let packages = [package1, package2, package3]
        let selectedIndices = [0, 2]
        let (factory, service) = makeSUT(
            foldersToLoad: packages,
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([selectedIndices])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(!service.didDeleteAllPackages)
        #expect(service.deletedFolders.count == 2)
        #expect(service.deletedFolders.contains(where: { $0.name == package1.name }))
        #expect(service.deletedFolders.contains(where: { $0.name == package3.name }))
    }

    @Test("Deletes no packages when user selects none during package selection")
    func deletesNoPackagesWhenUserSelectsNoneDuringPackageSelection() throws {
        let packages = [
            makePurgeFolder(name: "Alamofire-1a2b3c4d"),
            makePurgeFolder(name: "SwiftyJSON-5e6f7g8h"),
            makePurgeFolder(name: "Kingfisher-9i0j1k2l")
        ]
        let (factory, service) = makeSUT(
            foldersToLoad: packages,
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[]])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["package-cache", "delete"])

        #expect(!service.didDeleteAllPackages)
        #expect(service.deletedFolders.isEmpty)
    }
}


// MARK: - SUT
private extension DeletePackageCacheTests {
    func makeSUT(
        foldersToLoad: [PurgeFolder] = [],
        selectionResult: MockSelectionResult = .init()
    ) -> (factory: MockContextFactory, service: MockPurgeService) {
        let service = MockPurgeService(foldersToLoad: foldersToLoad)
        let picker = makePicker(selectionResult: selectionResult)
        let factory = MockContextFactory(
            picker: picker,
            purgeService: service
        )

        return (factory, service)
    }

    func makePicker(selectionResult: MockSelectionResult) -> MockSwiftPicker {
        return MockSwiftPicker(
            permissionResult: .init(grantByDefault: true, type: .ordered([])),
            selectionResult: selectionResult
        )
    }
}
