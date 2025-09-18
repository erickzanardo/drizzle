import 'package:uuid/uuid.dart';

/// {@template drizzle_data_store}
///
/// Interface for data persistence for [Drizzle].
///
/// {@endtemplate}
abstract class DrizzleDataStore {
  /// Save an entity to the data store.
  Future<void> saveEntity(
    String entityName,
    Map<String, Map<String, dynamic>> entity,
  );

  /// Delete an entity from the data store.
  Future<void> deleteEntity(String entityName);

  /// Read all entities from the data store.
  Future<Map<String, Map<String, Map<String, dynamic>>>> readAllEntities();
}

/// The field used to store metadata.
const drizzleMetadataField = '__drizzle__';

/// The key used to store the last sync time.
const drizzleLastSyncKey = '__drizzle_last_sync__';

/// Metadata about the data stored in [Drizzle].
class DrizzleMetadata {
  /// Creates a new instance of [DrizzleMetadata].
  DrizzleMetadata({
    required this.lastSync,
  });

  /// The last time the data was synced.
  final DateTime lastSync;
}

/// {@template drizzle}
/// A simple package to persist and query small dataset of data
/// {@endtemplate}
class Drizzle {
  /// {@macro drizzle}
  Drizzle({
    required DrizzleDataStore dataStore,
  }) : _dataStore = dataStore;

  static const _uuid = Uuid();

  final DrizzleDataStore _dataStore;

  final Map<String, Map<String, Map<String, dynamic>>> _data = {};

  var _initialized = false;

  final _operations = <Future<dynamic>>[];

  void _syncEntity(String entity) {
    final data = {
      ..._data[entity]!,
      drizzleMetadataField: {
        drizzleLastSyncKey: DateTime.now().toIso8601String()
      },
    };

    final operation = _dataStore.saveEntity(entity, data);

    _operations.add(
      operation.then(
        (value) => _operations.remove(operation),
      ),
    );
  }

  /// Returns a [Future] that completes when all pending operations are done.
  Future<void> pendingOperations() {
    return Future.wait(_operations);
  }

  /// Loads data from a [DrizzleDataStore].
  Future<DrizzleMetadata> load() async {
    assert(!_initialized, 'Drizzle is already initialized');
    final data = await _dataStore.readAllEntities();

    final metadataEntry = data[drizzleMetadataField] ?? {};

    final metadata = DrizzleMetadata(
      lastSync: metadataEntry[drizzleLastSyncKey] != null
          ? DateTime.parse(metadataEntry[drizzleLastSyncKey]! as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );

    data.remove(drizzleMetadataField);

    _data.addAll(data);
    _initialized = true;

    return metadata;
  }

  /// Returns a list of entities.
  List<String> entities() {
    return _data.keys.toList();
  }

  /// Adds a document to the given [entity], returning its ID.
  String add(String entity, Map<String, dynamic> data) {
    final id = _uuid.v4();
    _data[entity] ??= {};
    _data[entity]![id] = data;

    _syncEntity(entity);

    return id;
  }

  /// Gets a document from the given [entity] by its [id].
  Map<String, dynamic>? get(String entity, String id) {
    final data = _data[entity]?[id];

    if (data != null) {
      return {
        'id': id,
        ...data,
      };
    }

    return null;
  }

  /// Deletes a document from the given [entity] by its [id].
  void delete(String entity, String id) {
    _data[entity]?.remove(id);
    _syncEntity(entity);
  }

  /// Updates a document from the given [entity] by its [id].
  void update(String entity, String id, Map<String, dynamic> data) {
    _data[entity] ??= {};
    _data[entity]?[id] = data;
    _syncEntity(entity);
  }

  /// Queries the given [entity] with the given [where] clause.
  ///
  /// Comparison between where
  List<Map<String, dynamic>> query(String entity, Map<String, dynamic> where) {
    final data = _data[entity]?.entries ?? [];

    return data.where((element) {
      final entries = where.entries;

      if (entries.isEmpty) return true;

      return entries.every((entry) {
        return entry.value == element.value[entry.key];
      });
    }).map((e) {
      return {
        'id': e.key,
        ...e.value,
      };
    }).toList();
  }

  /// Purges all data from the data store.
  ///
  /// WARNING: This is a destructive operation.
  Future<void> purgeData() async {
    final entities = _data.keys.toList();

    final deleteOperations = entities.map(_dataStore.deleteEntity);
    _operations.addAll(deleteOperations);

    _data.clear();

    return pendingOperations();
  }
}
