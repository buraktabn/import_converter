# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2023-03-28

### Added

- Initial release of the import_converter package.
- Functionality to convert package imports to path imports.
- Functionality to revert path imports back to package imports.
- Exclude files in the `test` folder from the import conversion process.
- Retrieves the project name from the `pubspec.yaml` file.
- Command-line options for specifying the path and revert action.