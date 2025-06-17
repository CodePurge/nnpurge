import Files

protocol DerivedDataManaging {
    func loadDerivedDataFolders() throws -> [Folder]
    func moveFoldersToTrash(_ folders: [Folder]) throws
}
