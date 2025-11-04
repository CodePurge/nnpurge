//
//  ProjectDependencyFinder.swift
//  Nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

/// Service for finding and parsing Package.resolved files
public protocol ProjectDependencyFinder {
    /// Finds and parses Package.resolved in the specified directory
    /// - Parameter path: Directory path to search (defaults to current directory)
    /// - Returns: Parsed project dependencies
    /// - Throws: Error if Package.resolved not found or parsing fails
    func findDependencies(in path: String?) throws -> ProjectDependencies
}

public struct DefaultProjectDependencyFinder: ProjectDependencyFinder {
    public init() {}

    public func findDependencies(in path: String?) throws -> ProjectDependencies {
        let searchPath = path ?? FileManager.default.currentDirectoryPath
        let resolvedPath = (searchPath as NSString).appendingPathComponent("Package.resolved")

        guard FileManager.default.fileExists(atPath: resolvedPath) else {
            throw ProjectDependencyError.packageResolvedNotFound(path: searchPath)
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: resolvedPath))
        let decoder = JSONDecoder()

        return try decoder.decode(ProjectDependencies.self, from: data)
    }
}

public enum ProjectDependencyError: Error, CustomStringConvertible {
    case packageResolvedNotFound(path: String)

    public var description: String {
        switch self {
        case .packageResolvedNotFound(let path):
            return "Package.resolved not found in: \(path)"
        }
    }
}
