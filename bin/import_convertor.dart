import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addSeparator(
        'Import Converter   A Dart command-line tool for converting package imports to path imports and vice versa in a Dart project.')
    ..addSeparator('')
    ..addOption('path',
        abbr: 'p', help: 'Path to the directory containing your Dart project. Defaults to current directory')
    ..addFlag('revert',
        abbr: 'r', help: 'Revert path imports back to package imports', defaultsTo: false, negatable: false)
    ..addFlag('help', abbr: 'h', help: 'Print this usage information', defaultsTo: false, negatable: false);

  final argResults = parser.parse(arguments);

  if (argResults['help'] ?? false) {
    print(parser.usage);
    return;
  }

  String path = argResults['path'] ?? Directory.current.path;
  // if (path.startsWith('./')) path = path.replaceFirst('./', '');
  final revert = argResults['revert'] ?? false;

  final projectName = await _getProjectName(path);
  if (projectName == null) {
    print('Error: Could not read project name from pubspec.yaml');
    exit(1);
  }

  if (revert) {
    await _revertImports(path, projectName);
    return;
  }

  await _convertImports(path, projectName);
}

Future<String?> _getProjectName(String path) async {
  final pubspecFile = File('$path/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return null;
  }

  final pubspecContent = await pubspecFile.readAsString();
  final pubspecYaml = loadYaml(pubspecContent);
  return pubspecYaml['name']?.toString();
}

Future<void> _convertImports(String path, String projectName) async {
  final directory = Directory(path);
  final testFolderPath = p.join(path, 'test');
  final files = directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart') && !entity.path.startsWith(testFolderPath));

  final projectLibPath = p.join(path, 'lib');

  for (final file in files) {
    final fileContent = await (file as File).readAsString();
    final importRegex = RegExp("import 'package:$projectName/(.+.dart)';");

    final newFileContent = fileContent.replaceAllMapped(
      importRegex,
      (match) {
        final importedFilePath = p.join(projectLibPath, match.group(1)!);
        final relativePath = p.relative(importedFilePath, from: p.dirname(file.path));
        return "import '$relativePath';";
      },
    );

    if (newFileContent != fileContent) {
      await file.writeAsString(newFileContent);
      print('Converted package import: ${file.path}');
    }
  }
}

Future<void> _revertImports(String path, String projectName) async {
  final directory = Directory(path);
  final testFolderPath = p.join(path, 'test');
  final files = directory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart') && !entity.path.startsWith(testFolderPath));

  final projectLibPath = p.join(path, 'lib');

  for (final file in files) {
    final fileContent = await (file as File).readAsString();
    final importRegex = RegExp(r"import '(?!package:)((?:\.{0,2}/)?[^']+\.dart)';");

    final newFileContent = fileContent.replaceAllMapped(
      importRegex,
      (match) {
        final importedFilePath = p.normalize(p.join(p.dirname(file.path), match.group(1)!));
        if (p.isWithin(projectLibPath, importedFilePath)) {
          final packagePath = p.relative(importedFilePath, from: projectLibPath);
          return "import 'package:$projectName/$packagePath';";
        }
        return match.group(0)!;
      },
    );

    if (newFileContent != fileContent) {
      await file.writeAsString(newFileContent);
      print('Reverted path import: ${file.path}');
    }
  }
}
