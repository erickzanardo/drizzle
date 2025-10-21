// Not needed for tests
// ignore_for_file: prefer_const_constructors
import 'package:drizzle/drizzle.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDrizzleDataStore extends Mock implements DrizzleDataStore {}

void main() {
  group('Drizzle', () {
    late DrizzleDataStore dataStore;
    late Drizzle drizzle;

    setUp(() {
      dataStore = _MockDrizzleDataStore();
      drizzle = Drizzle(dataStore: dataStore);
    });

    test('can be instantiated', () {
      expect(
        Drizzle(dataStore: _MockDrizzleDataStore()),
        isNotNull,
      );
    });

    test('can loads the data from the dataStore', () async {
      when(dataStore.readAllEntities).thenAnswer(
        (_) async => {
          'people': {
            '1': {'name': 'Luke Skywalker'},
            '2': {'name': 'C-3PO'},
          },
        },
      );
      await drizzle.load();
      verify(
        dataStore.readAllEntities,
      ).called(1);

      final people = drizzle.query('people', {});
      expect(people, isNotNull);
      expect(people.length, 2);
      expect(people[0]['name'], 'Luke Skywalker');
      expect(people[1]['name'], 'C-3PO');
    });

    test('loads the metadata', () async {
      when(dataStore.readAllEntities).thenAnswer(
        (_) async => {
          'people': {
            '1': {'name': 'Luke Skywalker'},
            '2': {'name': 'C-3PO'},
          },
          drizzleMetadataField: {
            drizzleLastSyncKey: {'value': '2024-01-01T12:00:00.000Z'},
          },
        },
      );
      final metadata = await drizzle.load();
      expect(
        metadata.lastSync,
        DateTime.parse('2024-01-01T12:00:00.000Z'),
      );
    });

    test('list all entities', () async {
      when(dataStore.readAllEntities).thenAnswer(
        (_) async => {
          'people': {
            '1': {'name': 'Luke Skywalker'},
            '2': {'name': 'C-3PO'},
          },
        },
      );
      await drizzle.load();
      final entities = drizzle.entities();
      expect(entities, equals(['people']));
    });

    test('adds a document to an entity', () async {
      when(() => dataStore.saveEntity(any(), any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      final id = drizzle.add('people', {'name': 'Luke Skywalker'});

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  equals(
                    {'name': 'Luke Skywalker'},
                  ),
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final result = drizzle.get('people', id);

      expect(result, isNotNull);
      expect(result?['name'], equals('Luke Skywalker'));
    });

    test('updates a document in an entity', () async {
      when(() => dataStore.saveEntity(any(), any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      final id = drizzle.add('people', {'name': 'Luke Skywalker'});

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  equals(
                    {'name': 'Luke Skywalker'},
                  ),
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final result = drizzle.get('people', id);

      expect(result, isNotNull);
      expect(result?['name'], equals('Luke Skywalker'));

      drizzle.update('people', id, {'name': 'Darth Vader'});

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  equals(
                    {'name': 'Darth Vader'},
                  ),
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final updatedResult = drizzle.get('people', id);

      expect(updatedResult, isNotNull);
      expect(updatedResult?['name'], equals('Darth Vader'));
    });

    test('updates a document to static id', () async {
      when(() => dataStore.saveEntity(any(), any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      const id = 'sith_lord';

      final result = drizzle.get('people', id);

      expect(result, isNull);

      drizzle.update('people', id, {'name': 'Darth Vader'});

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  equals(
                    {'name': 'Darth Vader'},
                  ),
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final updatedResult = drizzle.get('people', id);

      expect(updatedResult, isNotNull);
      expect(updatedResult?['name'], equals('Darth Vader'));
    });

    test('deletes a document from an entity', () async {
      when(() => dataStore.saveEntity(any(), any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      final id = drizzle.add('people', {'name': 'Luke Skywalker'});

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  equals(
                    {'name': 'Luke Skywalker'},
                  ),
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final result = drizzle.get('people', id);

      expect(result, isNotNull);
      expect(result?['name'], equals('Luke Skywalker'));

      drizzle.delete('people', id);

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  isNull,
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final deletedResult = drizzle.get('people', id);

      expect(deletedResult, isNull);
    });

    test('queries a document by a field', () async {
      when(dataStore.readAllEntities).thenAnswer(
        (_) async => {
          'people': {
            '1': {'name': 'Luke Skywalker'},
            '2': {'name': 'C-3PO'},
          },
        },
      );
      await drizzle.load();
      verify(
        dataStore.readAllEntities,
      ).called(1);

      final people = drizzle.query('people', {'name': 'Luke Skywalker'});
      expect(people, isNotNull);
      expect(people.length, 1);
      expect(people[0]['name'], 'Luke Skywalker');
    });

    test('pending operations resolves', () async {
      when(() => dataStore.saveEntity(any(), any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      final id = drizzle.add('people', {'name': 'Luke Skywalker'});

      verify(
        () => dataStore.saveEntity(
          'people',
          any(
            that: isA<Map<String, Map<String, dynamic>>>()
                .having(
                  (v) => v[id],
                  '',
                  equals(
                    {'name': 'Luke Skywalker'},
                  ),
                )
                .having(
                  (v) => v[drizzleMetadataField],
                  '',
                  isA<Map<String, dynamic>>().having(
                    (m) => m[drizzleLastSyncKey],
                    '',
                    isA<Map<String, dynamic>>(),
                  ),
                ),
          ),
        ),
      ).called(1);

      final result = drizzle.get('people', id);

      expect(result, isNotNull);
      expect(result?['name'], equals('Luke Skywalker'));

      await expectLater(drizzle.pendingOperations(), completes);
    });

    test('purges the dataStore', () async {
      when(dataStore.readAllEntities).thenAnswer(
        (_) async => {
          'people': {
            '1': {'name': 'Luke Skywalker'},
            '2': {'name': 'C-3PO'},
          },
          'spaceship': {
            '1': {'name': 'X-Wing'},
            '2': {'name': 'Tiefighter'},
          },
        },
      );

      when(() => dataStore.deleteEntity(any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      await drizzle.load();
      await drizzle.purgeData();

      verify(
        () => dataStore.deleteEntity('people'),
      ).called(1);
      verify(
        () => dataStore.deleteEntity('spaceship'),
      ).called(1);
      expect(drizzle.entities(), isEmpty);
    });
  });
}
