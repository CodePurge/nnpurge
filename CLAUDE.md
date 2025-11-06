# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

nnpurge is a Swift command-line utility for macOS that manages Xcode's DerivedData folders and Swift Package caches. It provides interactive and batch deletion capabilities with safety features.

## Development Commands

### Build
```bash
swift build                    # Debug build
swift build -c release        # Release build
swift build --show-bin-path    # Show output path
```

### Test
```bash
swift test                     # Run all tests
swift test -l                  # List available tests
swift test --filter <pattern>  # Run specific tests
swift test --skip <pattern>    # Skip specific tests
```

### Run
```bash
swift run nnpurge --help                      # Show help
swift run nnpurge --version                   # Show version
swift run nnpurge derived-data delete         # Delete DerivedData (interactive)
swift run nnpurge derived-data path           # View/set custom DerivedData path
swift run nnpurge package-cache delete        # Delete Swift Package cache (interactive)
swift run nnpurge package-cache clean         # Clean project dependency caches
```

## Architecture

### Core Components

**Command Structure**: Built on Swift Argument Parser with subcommands:
- `derived-data` - Manages DerivedData folders
  - `delete` - Delete DerivedData folders (interactive or `--all`)
  - `path` - View, set (`--set`), or reset (`--reset`) custom DerivedData location
- `package-cache` - Manages Swift Package caches
  - `delete` - Delete package cache repositories (interactive or `--all`)
  - `clean` - Clean project dependency caches (optionally `--path`)
- `archive` - (Currently disabled) Manages Xcode archives

**Note**: Legacy command names (`ddd`, `dspc`, `sdp`) were used in versions prior to 0.2.0

**Dependency Injection**: Uses factory pattern via `ContextFactory` protocol:
- `DefaultContextFactory` - Production implementation
- `MockContextFactory` - Test implementation (in Tests/nnpurgeTests/Mocks/)

**Manager Layer**: Core business logic in managers:
- `DerivedDataManager` - Handles DerivedData operations
- `PackageCacheManager` - Handles package cache operations

**Protocol Abstractions**: Key protocols for testability:
- `DerivedDataStore` - UserDefaults abstraction
- `FolderLoader` - File system operations
- `FileTrasher` - File deletion operations
- `DerivedDataDelegate` / `PackageCacheDelegate` - Manager interfaces

### Key Dependencies

- **SwiftPicker** - Interactive CLI prompts and selections
- **Files** - File system operations
- **SwiftShell** - Shell command execution
- **Swift Argument Parser** - Command-line interface

### Factory Pattern Usage

The main command (`nnpurge`) exposes factory methods:
- `makePicker()` - Creates interactive picker
- `makeUserDefaults()` - Creates data store
- `makeDerivedDataManager()` - Creates DerivedData manager
- `makePackageCacheManager()` - Creates package cache manager

### Testing Strategy

Tests use mocks from `Tests/nnpurgeTests/Mocks/`:
- `MockContextFactory` - Provides test implementations
- `MockUserDefaults` - Simulates UserDefaults storage

All core services are protocol-based for easy mocking and verification.

## File Structure

```
Sources/nnpurge/
├── Commands/           # CLI command implementations
├── Extensions/         # Protocol extensions
├── Factories/          # Dependency injection
├── Manager/            # Business logic
├── Models/             # Data models and enums
└── Protocols/          # Interface definitions
```