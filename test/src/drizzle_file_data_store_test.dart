import 'dart:io';

import 'package:drizzle/drizzle.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('DrizzleFileDataStore', () {
    late DrizzleFileDataStore dataStore;
    late final basePath = path.join(
      Directory.systemTemp.path,
      '_drizzle_test',
    );

    setUp(() async {
      dataStore = DrizzleFileDataStore(
        basePath: basePath,
      );
    });

    tearDown(() async {
      await Directory(basePath).delete(recursive: true);
    });

    test('saves an entity', () async {
      await dataStore.saveEntity('people', {
        'a': {'name': 'Luke Skywalker'},
        'b': {'name': 'C-3PO'},
      });

      final result = await dataStore.readAllEntities();
      expect(result, isNotNull);
      expect(result['people']?['a']?['name'], 'Luke Skywalker');
      expect(result['people']?['b']?['name'], 'C-3PO');
    });

    test('delete an entity', () async {
      await dataStore.saveEntity('people', {
        'a': {'name': 'Luke Skywalker'},
        'b': {'name': 'C-3PO'},
      });

      await dataStore.deleteEntity('people');

      final result = await dataStore.readAllEntities();
      expect(result, isNotNull);
      expect(result['people'], isNull);
    });
  });
}
