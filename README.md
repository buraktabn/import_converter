# Import Converter

A Dart command-line tool for converting package imports to path imports and vice versa in a Dart project.

## Features

- Automatically scans all `.dart` files within the project and converts package imports to path imports.
- Supports reverting path imports back to package imports.
- Excludes processing files in the `test` folder.
- Retrieves the project name from the `pubspec.yaml` file.

## Installation
Activate the `import_converter` package globally:

```
dart pub global activate import_converter
```

## Running

1. Convert package imports to path imports:

```
import_converter --path /path/to/your/dart/project
```

2. Convert path imports back to package imports:

```
import_converter --path /path/to/your/dart/project --revert
```

## Command Line Options

- `--path` or `-p`: The path to the directory containing your Dart project.
- `--revert` or `-r`: Revert path imports back to package imports. By default, the program converts package imports to path imports.

## Limitations

- This tool assumes a standard Dart project structure with a `lib` folder containing the source code and a `pubspec.yaml` file.
- It does not currently support custom import prefixes or aliasing.