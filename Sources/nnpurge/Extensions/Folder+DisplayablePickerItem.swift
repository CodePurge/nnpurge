import Files
import SwiftPicker

extension Folder: @retroactive DisplayablePickerItem {
    public var displayName: String {
        name
    }
}
