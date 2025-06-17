import Foundation
import SwiftPicker

struct DefaultContextFactory: ContextFactory {
    func makePicker() -> Picker {
        return SwiftPicker()
    }
    
    func makeUserDefaults() -> UserDefaultsProtocol {
        return UserDefaults.standard
    }

    func makeDerivedDataManager(defaults: UserDefaultsProtocol) -> DerivedDataManaging {
        return DerivedDataManager(userDefaults: defaults)
    }
}
