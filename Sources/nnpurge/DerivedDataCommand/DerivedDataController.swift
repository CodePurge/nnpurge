//
//  DerivedDataController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import SwiftPicker
import CodePurgeKit

struct DerivedDataController {
    private let picker: CommandLinePicker
    private let manager: DerivedDataManager
    
    init(picker: CommandLinePicker, manager: DerivedDataManager) {
        self.picker = picker
        self.manager = manager
    }
}


// MARK: - Actions
extension DerivedDataController {
    func deleteDerivedData(deleteAll: Bool) throws {
        // TODO: - 
    }
}
