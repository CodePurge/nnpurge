//
//  DefaultContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

struct DefaultContextFactory: ContextFactory {
    func makePicker() -> any CommandLinePicker {
        return InteractivePicker()
    }

    func makeUserDefaults() -> any DerivedDataStore {
        return UserDefaults.standard
    }

    func makeDerivedDataService(path: String) -> any DerivedDataService {
        return DerivedDataManager(path: path)
    }
}


// MARK: - Extension Depdencies
extension UserDefaults: DerivedDataStore { }
