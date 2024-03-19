import 'dart:convert';
import 'dart:io';

import 'package:drizzle/drizzle.dart';
import 'package:path/path.dart' as path;

/// {@template drizzle_file_data_store}
/// A [DrizzleDataStore] that persists data to a file.
///
/// Where each entity is saved in its own file.
///
/// [DrizzleFileDataStore] allows more than one instance to be created in the
/// same folder, by providing a unique instanceName for each.
///
/// By default the `_drizzle` instanceName is used.
/// {@endtemplate}
class DrizzleFileDataStore extends DrizzleDataStore {
  /// {@macro drizzle_file_data_store}
  DrizzleFileDataStore({
    required String basePath,
    String instanceName = '_drizzle',
  })  : _basePath = basePath,
        _instanceName = instanceName;

  final String _basePath;
  final String _instanceName;

  String? _storagePath;

  Future<String> _path() async {
    if (_storagePath != null) return _storagePath!;

    _storagePath = path.join(
      _basePath,
      _instanceName,
    );

    final dir = Directory(_storagePath!);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return _storagePath!;
  }

  @override
  Future<Map<String, Map<String, Map<String, dynamic>>>>
      readAllEntities() async {
    final dir = Directory(await _path());

    return dir
        .list()
        .where((f) => f is File)
        .cast<File>()
        .asyncMap((file) async {
      final entityName = path.basenameWithoutExtension(file.path);
      return (
        entityName,
        await file.readAsString(),
      );
    }).fold<Map<String, Map<String, Map<String, dynamic>>>>(
      {},
      (entities, entity) {
        final map = jsonDecode(entity.$2) as Map<String, dynamic>;
        entities[entity.$1] = map.cast<String, Map<String, dynamic>>();

        return entities;
      },
    );
  }

  @override
  Future<void> saveEntity(
    String entityName,
    Map<String, Map<String, dynamic>> entity,
  ) async {
    await File(
      path.join(await _path(), '$entityName.json'),
    ).writeAsString(jsonEncode(entity));
  }

  @override
  Future<void> deleteEntity(String entityName) async {
    await File(
      path.join(await _path(), '$entityName.json'),
    ).delete();
  }
}
