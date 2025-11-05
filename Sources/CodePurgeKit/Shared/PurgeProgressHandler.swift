//
//  PurgeProgressHandler.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

public protocol PurgeProgressHandler {
    func complete(message: String?)
    func updateProgress(current: Int, total: Int, message: String)
}
