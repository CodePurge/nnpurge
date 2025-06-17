//
//  FileManagerProtocol.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation

protocol FileManagerProtocol {
    func trashItem(at url: URL, resultingItemURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws
}

extension FileManager: FileManagerProtocol {}
