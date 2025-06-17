//
//  ContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

protocol ContextFactory {
    func makePicker() -> Picker
    func makeUserDefaults() -> UserDefaultsProtocol
    func makeDerivedDataManager(defaults: UserDefaultsProtocol) -> DerivedDataManaging
}
