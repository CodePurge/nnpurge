# nnpurge

![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platform](https://img.shields.io/badge/Platform-macOS%2013%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

## Overview

**nnpurge** is a command-line utility for macOS that safely and interactively manages Xcode's DerivedData folders. It provides developers with a streamlined way to delete DerivedData directories, either in bulk or selectively, helping reclaim disk space and eliminate corrupted build caches.

Built with modular testable components and leveraging Swift Argument Parser, SwiftPicker, and Files for efficient CLI interactions.

## Features

- **DerivedData Management**
  - Delete all or selected DerivedData folders
  - View, set, and reset custom DerivedData path
  - Xcode running detection with force quit option
- **Swift Package Cache Management**
  - Delete all or selected Swift Package cache repositories
  - Clean project-specific dependency caches
  - Delete stale package caches (older than 30 days)
- **Safety & User Experience**
  - Interactive prompts using `SwiftPicker`
  - Progress bars with percentage display during deletion
  - Fully testable with mock dependencies
  - Lightweight abstraction over `UserDefaults` and filesystem operations

## Installation

### Using Swift Package Manager

```bash
git clone https://github.com/CodePurge/nnpurge.git
cd nnpurge
swift build -c release
```

Then add `.build/release/nnpurge` to your PATH.

## Usage

### Check the version

```bash
nnpurge --version
```

### DerivedData Management

**View, set, or reset custom DerivedData path:**

```bash
nnpurge derived-data path              # View current path
nnpurge derived-data path --set ~/Custom/DerivedData
nnpurge derived-data path --reset      # Reset to default
```

**Delete DerivedData folders:**

```bash
nnpurge derived-data delete            # Interactive selection
nnpurge derived-data delete --all      # Delete all folders
```

### Swift Package Cache Management

**Delete package cache repositories:**

```bash
nnpurge package-cache delete           # Interactive selection
nnpurge package-cache delete --all     # Delete all repositories
```

**Clean project dependency caches:**

```bash
nnpurge package-cache clean            # Clean current project
nnpurge package-cache clean --path ~/Projects/MyApp
```

## Documentation

- The project includes extensive inline documentation in the source files.
- Developers can explore the `nnpurge` root command to understand available subcommands and behaviors.

## Architecture Notes

- **Protocol-oriented**: Core services (e.g., `DerivedDataStore`, `FolderLoader`, `FileTrasher`) are defined as protocols for easy mocking and substitution.
- **Factory Pattern**: Uses `ContextFactory` for dependency injection, aiding testing and modularity.
- **Swift Argument Parser**: Powers the command-line interface.
- **SwiftPicker**: Drives interactive prompts and folder selection.

## Acknowledgments

This project uses the following open-source libraries:

- [Files](https://github.com/JohnSundell/Files)
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
- [SwiftPicker](https://github.com/nikolainobadi/SwiftPicker)

## About This Project

**nnpurge** was created to simplify the cleanup of Xcode’s DerivedData folders by providing a safe, testable, and interactive CLI utility. It aims to improve development workflows for macOS and Xcode users by offering precise control over DerivedData management.

## Contributing

Contributions are welcome! Feel free to open issues, suggest enhancements, or submit pull requests via [GitHub](https://github.com/CodePurge/nnpurge).

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/CodePurge/nnpurge/blob/main/LICENSE) file for details.
