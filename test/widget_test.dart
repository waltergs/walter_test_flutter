// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:walter_test_flutter/main.dart';
import 'package:walter_test_flutter/models/user.dart';
import 'package:walter_test_flutter/models/address.dart';

void main() {
  setUpAll(() async {
    final testPath = Directory.systemTemp.createTempSync().path;
    Hive.init(testPath);
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>('users_box');
    await Hive.box<User>('users_box').clear();
  });

  tearDownAll(() async {
    final box = Hive.box<User>('users_box');
    await box.clear();
    await box.close();
  });

  testWidgets('App builds and shows add user FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fab_add_user')), findsOneWidget);
  });
}
