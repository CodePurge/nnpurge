////
////  DeletePackageCache.swift
////  nnpurge
////
////  Created by Nikolai Nobadi on 6/17/25.
////
//
//import Foundation
//import ArgumentParser
//
//extension Nnpurge {
//    struct DeletePackageCache: ParsableCommand {
//        static let configuration = CommandConfiguration(
//            commandName: "spm",
//            abstract: "Deletes cached Swift Package repositories"
//        )
//        
//        @Flag(name: .shortAndLong, help: "Deletes all cached package repositories.")
//        var all: Bool = false
//        
//        @Flag(name: .shortAndLong, help: "Opens the cached package repositories folder.")
//        var open: Bool = false
//        
//        func run() throws {
//            if open {
//                try openPackageCacheFolder()
//                return
//            }
//            
//            let picker = Nnpurge.makePicker()
//            let manager = Nnpurge.makePackageCacheManager()
//            var foldersToDelete = try manager.loadPackageFolders()
//            
//            if all {
//                try picker.requiredPermission(prompt: "Are you sure you want to delete all cached package repositories?")
//            } else {
//                let selection = try picker.requiredSingleSelection("What would you like to do?", items: PackageCacheAction.allCases)
//                
//                switch selection {
//                case .deleteAll:
//                    try picker.requiredPermission(prompt: "Are you sure you want to delete all cached package repositories?")
//                case .deleteSelectFolder:
//                    foldersToDelete = picker.multiSelection("Select the repositories to delete.", items: foldersToDelete)
//                case .openFolder:
//                    try openPackageCacheFolder()
//                    return
//                }
//            }
//            
//            try manager.moveFoldersToTrash(foldersToDelete)
//        }
//    }
//}
//
//// MARK: - Private Methods
//private extension Nnpurge.DeletePackageCache {
//    func openPackageCacheFolder() throws {
//        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
//        let expandedPath = NSString(string: path).expandingTildeInPath
//        
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
//        process.arguments = [expandedPath]
//        try process.run()
//        process.waitUntilExit()
//    }
//}
