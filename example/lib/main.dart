// Needed for a terminal app
// ignore_for_file: avoid_print

import 'package:drizzle/drizzle.dart';

void main(List<String> args) async {
  final drizzle = Drizzle(
    dataStore: DrizzleFileDataStore(
      basePath: '.data',
    ),
  );

  await drizzle.load();

  if (args.isEmpty) {
    final values = drizzle.query('values', {});
    for (final value in values) {
      print(value);
    }
  } else if (args[0] == 'add') {
    final id = drizzle.add('values', {'value': args.last});

    print(id);
  }

  await drizzle.pendingOperations();
}
