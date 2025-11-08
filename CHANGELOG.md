# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2025-11-08

### Removed
- Progress bar display during deletion operations

## [0.2.0] - 2025-11-06

### Added
- Delete stale package caches (older than 30 days) option
- `package-cache clean` subcommand to delete project dependency caches
- Xcode running detection with option to force quit before deletion or cancel operations
- Progress bar with percentage display during deletion operations
- `derived-data path` subcommand to view, set, and reset custom locations

### Changed
- DerivedData path management moved from standalone `sdp` command to `derived-data path` subcommand
- Command structure modernized: `ddd` → `derived-data`, `dspc` → `package-cache`

### Fixed
- Package cache folder name parsing to correctly extract branch IDs

## [0.1.1] - 2025-10-20

### Added
- Version display with `--version` flag
- Open DerivedData folder in Finder with `ddd --open` command
- Open Swift Package cache folder in Finder with `dspc --open` command

### Changed
- Minimum macOS version lowered from macOS 14 to macOS 13
- Removed SwiftShell dependency to reduce external dependencies

## [0.1.0] - 2025-06-19

### Added
- Interactive DerivedData folder deletion with `ddd` command
- Batch deletion of all DerivedData folders with `--all` flag
- Open DerivedData folder in Finder with `--open` flag
- Swift Package cache management with `dspc` command
- Interactive selection of package cache repositories to delete
- Batch deletion of all package caches with `--all` flag
- Open package cache folder in Finder with `--open` flag
- Custom DerivedData path configuration with `sdp` command
- Protocol-oriented architecture for testability
- Factory pattern for dependency injection
- Unit tests with Swift Testing framework
