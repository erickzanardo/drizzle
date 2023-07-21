// ignore_for_file: prefer_const_constructors
import 'package:drizzle/drizzle.dart';
import 'package:test/test.dart';

void main() {
  group('Drizzle', () {
    test('can be instantiated', () {
      expect(Drizzle(), isNotNull);
    });
  });
}
