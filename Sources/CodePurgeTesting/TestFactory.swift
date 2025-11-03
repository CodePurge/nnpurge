//
//  TestFactory.swift
//  CodePurgeTesting
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit

public func makePurgeFolder(name: String = "TestFolder", path: String = "/path/to/folder", size: Int = 1000) -> PurgeFolder {
    let url = URL(fileURLWithPath: path).appendingPathComponent(name)
    
    return .init(url: url, name: name, path: path, size: size)
}
