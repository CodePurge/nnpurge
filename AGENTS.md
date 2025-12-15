# Repository Guidelines

## Project Structure & Module Organization
- Sources: `Sources/nnpurge` holds CLI entry points and subcommands, `Sources/CodePurgeKit` houses core services/protocols (DerivedData, package cache, filesystem helpers), `Sources/CodePurgeTesting` provides mocks/factories for tests.
- Tests: `Tests/CodePurgeKitTests` and `Tests/nnpurgeTests` cover kit behaviors and CLI flows; add new suites alongside related modules.
- Assets & configs: SwiftPM manifest in `Package.swift`; keep product additions modular and isolated per target.

## Build, Test, and Development Commands
- Build: `swift build` for debug, `swift build -c release` for distribution. Favor incremental changes and keep parameters on single lines for readability.
- Run: `swift run nnpurge --help` to inspect commands; use `swift run nnpurge derived-data delete --all` for quick smoke checks.
- Test: `swift test` to execute the full suite; `swift test --filter <CaseName>` for focused runs. Only run tests when requested; do not auto-trigger after edits.

## Coding Style & Naming Conventions
- Swift 6, protocol-first design; prefer small, composable types with clear responsibilities.
- Indentation: 4 spaces; keep argument lists and parameter declarations on one line when feasible.
- File headers in Swift must credit Nikolai Nobadi; avoid attributing authorship to tools.
- Naming: favor verbs for commands/actions (`DerivedDataController`, `FileTrasher`), nouns for models/options (`DerivedDataDeleteOption`, `XcodeRunningOption`). Tests follow `test<Behavior>_<Expectation>()`.
- Documentation: add concise doc comments to public APIs and command descriptions; keep inline comments sparse and purposeful.

## Testing Guidelines
- Frameworks: XCTest with helpers from `CodePurgeTesting` and `SwiftPickerTesting` for mocks and picker interactions.
- Isolation: mock filesystem and user defaults via provided protocols; avoid hitting real DerivedData or caches in tests.
- Structure: mirror production namespaces in test targets; group fixtures under lightweight factories.
- Coverage: prioritize edge cases around deletion safety, path overrides, and interactive prompts; add regression tests when fixing bugs.

## Commit & Pull Request Guidelines
- Commits are short, imperative statements (`update swift picker convenience methods`, `refactor: migrate from SwiftPicker to SwiftPickerKit`). Use prefixes like `fix:`, `feat:`, or `refactor:` when scoping helps.
- Keep changes modular per commit; mention impacted commands or services in the body if non-obvious.
- PRs should outline intent, key changes, and manual verification steps; link issues when available. Include CLI examples or screenshots for UX-affecting updates.

## Safety & Configuration Tips
- Default paths target Xcode’s DerivedData and SwiftPM caches; confirm paths before destructive operations and prefer interactive flows when uncertain.
- Scripts should be idempotent, use `set -e`, and emit colored INFO/SUCCESS/WARNING/ERROR messages when added.
- Back up user-facing configs with timestamps before overwriting; source shared utilities when available in the environment.

## Resource Requests
- Ask before loading `~/.codex/guidelines/shared/shared-formatting-codex.md` when editing Swift code style or formatting guidance.
- Ask before loading `~/.codex/guidelines/testing/base_unit_testing_guidelines.md` when discussing or editing tests.
- Ask before loading `~/.codex/guidelines/testing/CLI_TESTING_GUIDE_CODEX.md` when working on CLI test plans or coverage.
- Ask before loading `~/.codex/guidelines/cli/SwiftPickerKit-usage.md` when adjusting SwiftPickerKit interactions in the CLI.
- Ask before loading `~/.codex/guidelines/cli/SwiftPickerTesting-usage.md` when adding or modifying SwiftPickerKit-driven tests.

## CLI Design
- Single-responsibility commands with clear, predictable argument handling and defaults.
- Keep logging minimal and purposeful; prefer concise stdout messages and explicit stderr for errors.
- Favor protocol-backed services and dependency injection for filesystem and user input abstractions.
- Prefer absolute paths for any shell interactions; avoid implicit environment dependencies.

## CLI Testing
- Use behavior-driven tests for command logic; cover both success and error paths.
- Apply a `makeSUT` pattern where useful; rely on mocks for filesystem and picker interactions.
- Verify output formatting (stdout/stderr) and exit behaviors for each command option.
- Use SwiftPickerTesting helpers for interactive flows; isolate tests from real DerivedData or caches.
