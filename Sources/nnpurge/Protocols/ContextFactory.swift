import SwiftPicker

protocol ContextFactory {
    func makePicker() -> Picker
    func makeUserDefaults() -> UserDefaultsProtocol
    func makeDerivedDataManager(defaults: UserDefaultsProtocol) -> DerivedDataManaging
}
