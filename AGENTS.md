# AGENTS.md

## Purpose

- This repository is `get_cli`, a Dart CLI package for generating and maintaining GetX project code.
- The main entrypoint is `bin/get.dart`; the public library surface is `lib/get_cli.dart` and `lib/extensions.dart`.
- Most changes land in command parsing, file/code generation, import sorting/formatting, routing helpers, translations,
  or filesystem utilities.
- Expect the working tree to be dirty; do not revert unrelated user changes while making focused edits.

## Rule Sources

- No `.cursorrules` file was present during this scan.
- No files were present under `.cursor/rules/` during this scan.
- No `.github/copilot-instructions.md` file was present during this scan.
- Treat this file as the active repository-specific guidance unless new rule files are added later.

## Repository Map

- `bin/get.dart`: CLI startup, top-level exception handling, and update check.
- `lib/commands/`: command registry, base command interface, and concrete commands.
- `lib/core/`: command resolution, structure helpers, i18n bootstrap, generated locale source.
- `lib/functions/`: code generation, import sorting, path conversion, route helpers, misc file operations.
- `lib/common/utils/`: logger, pubspec helpers, shell helpers, JSON/model generation support.
- `lib/samples/`: templates used by generators.
- `translations/`: locale JSON files; source of truth for user-facing translations.
- `test/path/test.dart`: current automated test coverage.

## Environment And Dependency Notes

- Use Dart 3.x. `pubspec.yaml` allows `>=3.0.0 <4.0.0`; the checked-in lockfile was generated with Dart
  `>=3.10.0 <4.0.0`.
- `pubspec.lock` is checked in. If you change dependency constraints, update the lockfile coherently instead of deleting
  or ignoring it.
- This repo has a history of dependency drift around `test` and `dart_style`; if `dart pub get` fails, inspect package
  compatibility before changing source code.
- If analysis or tests reference `file:///E:/flutter_pub_cache/...` or another stale cache path, regenerate
  `.dart_tool/` locally and rerun `dart pub get`; do not edit `.dart_tool/package_config.json` by hand.

## Core Commands

### Setup

```bash
dart pub get
```

- Run this first after pulling changes or when package resolution is stale.

### Lint / Static Analysis

```bash
dart analyze
```

- Lint rules come from `package:lints/recommended.yaml` via `analysis_options.yaml`.
- The only repo-wide override is `constant_identifier_names: false`, mainly for generated locale keys.

### Tests

```bash
dart test
```

- Run the full suite with `dart test`.
- The current test layout is non-standard: the only discovered test file is `test/path/test.dart`, not a `*_test.dart`
  filename.

### Run One Test File

```bash
dart test test/path/test.dart
```

- Use the actual path; do not assume `_test.dart` naming in this repo.

### Run One Exact Test Case

```bash
dart test test/path/test.dart --plain-name "replace import to relative"
```

- Prefer `--plain-name` with the exact test description for single-test execution.

### CLI Smoke Test

```bash
dart run bin/get.dart help
```

- This is the quickest end-to-end check that command resolution still works.

### Build The CLI Binary

```bash
dart compile exe bin/get.dart -o build/get
```

- Use this when you need an actual build artifact.
- `build/` is ignored by git.

### Repo-Specific Formatting / Import Sorting

```bash
dart run bin/get.dart sort lib
```

- `get sort` is a repo-native operation that sorts imports and formats Dart files.
- Useful flags: `--skipRename` skips separator renaming; `--relative` converts project package imports to relative
  imports where appropriate.

## Code Style

### Imports

- Inside `lib/`, prefer relative imports such as `../../core/generator.dart`.
- Use `package:` imports for public exports, code outside `lib/` (`bin/`, tests), or files intentionally targeting the
  public API.
- Keep imports in the same order used by `lib/functions/sorter_imports/sort.dart`: `library` directives, `dart:`
  imports, `package:flutter/...`, third-party `package:`, project `package:get_cli/...`, relative imports, then `export`
  lines.
- Alphabetize within each bucket and leave a blank line between buckets.
- If you create or rewrite Dart files, prefer paths and imports that can still be normalized by `sortImports()` and
  `writeFile()`.

### Formatting

- Use standard Dart formatting; do not hand-align whitespace.
- `writeFile()` already runs `sortImports()` and `DartFormatter` for `.dart` files unless explicitly skipped.
- Keep file-level ignores rare and local. Match existing style: only add ignores when a generated file or unavoidable
  implementation detail requires one.
- Do not rewrite large files purely for style if there is no behavioral change requested.

### Types And Nullability

- Follow sound null safety throughout.
- Use explicit nullable types where absence is real (`String?`, `bool?`, nullable AST nodes, nullable options).
- Prefer `final` for values that do not change; use `var` for short-lived locals or genuinely mutable variables.
- Keep constructors and data carriers simple; this codebase favors lightweight models over heavy abstraction.
- Match existing method signatures before introducing new wrapper types or generic abstractions.

### Naming

- File names are snake_case.
- Types, enums, and extensions use PascalCase.
- Methods, getters, local variables, and parameters use lowerCamelCase.
- Private members use a leading underscore.
- Command classes should continue the existing `...Command` naming pattern.
- Preserve legacy misspellings in existing identifiers and file names unless the task is an intentional refactor across
  all call sites. Examples: `commads_export.dart`, `frommatter_dart_file.dart`, `shel.utils.dart`, `NotFoundComannd`.

### Control Flow And Architecture

- Prefer small helpers and getters over large monolithic methods when extending existing code.
- Keep command behavior close to the command class; shared mechanics belong in `lib/functions/`, `lib/core/`, or
  `lib/common/utils/`.
- Reuse the existing command pipeline: argument parsing in `ArgsMixin`, validation in `Command.validate()`, execution in
  `execute()`.
- When adding generators, prefer the existing `Sample` + `Structure.model(...)` + `handleFileCreate()` flow.

## Error Handling And Logging

- For CLI usage or domain errors, throw `CliException` with a helpful message and `codeSample` when relevant.
- Let `ExceptionHandler` own final user-facing exception presentation.
- Use targeted `try on Exception catch` blocks around filesystem, formatting, YAML, JSON, shell, or network operations
  when recovery or better context is possible.
- Do not swallow exceptions silently.
- Use `LogService.error`, `LogService.success`, and `LogService.info` instead of ad hoc `print()` calls.
- If a file already uses a local `print` ignore for CLI output, follow the existing pattern rather than inventing a new
  logging path.

## User-Facing Text And Internationalization

- Prefer translated user-facing messages via `LocaleKeys` and `.tr`, `.trArgs(...)`, or `.trPlural(...)`.
- Add or update locale keys in `translations/*.json`, using `translations/en.json` as the baseline for key coverage.
- Do not hardcode new user-facing CLI strings when a translation key belongs in the locale files.
- Treat `lib/core/locales.g.dart` as generated output.

## File Generation And Filesystem Writes

- Prefer `writeFile()` for Dart file writes; it handles formatting, import sorting, separator renaming, and success
  logging.
- Prefer `handleFileCreate()` and `Structure.model(...)` when adding generator behavior.
- Be aware that `pubspec.yaml` may define `get_cli.separator` and `get_cli.sub_folder`, which affect generated paths and
  filenames.
- Do not bypass the existing generator pipeline unless there is a clear reason and the task specifically calls for
  low-level file handling.
- This codebase uses synchronous filesystem APIs heavily; match surrounding style unless you are intentionally
  refactoring a subsystem.

## Generated Files

- Do not hand-edit files with `DO NOT EDIT` headers unless the task explicitly requires changing the generator that
  produces them.
- Generated locale output and sample/template outputs should usually be updated by changing their source templates or
  translation inputs, not by direct manual edits.
- If you must touch generated output for a targeted fix, note the generator or source file that should also be updated.

## Practical Change Checklist

- Read the surrounding command, helper, or template before changing style or structure.
- Keep edits minimal and local to the requested behavior.
- Preserve checked-in lockfile intent when adjusting dependencies.
- Run the narrowest useful validation first: single test, relevant CLI smoke test, then broader analysis/tests if
  needed.
- If tooling fails because of local cache or package resolution issues, document that in your handoff instead of
  patching around it in source.
