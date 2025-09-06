import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:walter_test_flutter/screens/user_list_screen.dart';
import 'package:walter_test_flutter/models/user.dart';
import 'package:walter_test_flutter/models/address.dart';

Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw Exception('Finder $finder not found within $timeout');
}

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

  testWidgets('Crear usuario desde formulario y aparece en lista', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: UserListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Abre formulario
      await tester.tap(find.byKey(const Key('fab_add_user')));
      await tester.pumpAndSettle();

      // Rellenar
      await tester.enterText(find.byKey(const Key('firstName')), 'Walter');
      await tester.enterText(find.byKey(const Key('lastName')), 'Garcia');
      await tester.enterText(find.byKey(const Key('birthDate')), '1985-04-07');

      // Dirección
      await tester.tap(find.byKey(const Key('add_address_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('addr_country')), 'Colombia');
      await tester.enterText(find.byKey(const Key('addr_department')), 'Caldas');
      await tester.enterText(find.byKey(const Key('addr_city')), 'Manizales');
      await tester.enterText(find.byKey(const Key('addr_street')), 'Calle 123');
      await tester.tap(find.byKey(const Key('dialog_add_address_button')));
      await tester.pumpAndSettle();

      // Guardar
      await tester.ensureVisible(find.byKey(const Key('save_user_button')));
      await tester.tap(find.byKey(const Key('save_user_button')));
      await tester.pumpAndSettle();

      // Debug directo en Hive: ¿se guardó?
      final box = Hive.box<User>('users_box');
      final saved = box.values.any((u) => u.fullName.trim() == 'Walter Garcia');
      expect(saved, true, reason: 'El usuario no fue guardado en Hive; revisar repo.add() o _save()');

      // Si se guardó, esperar UI
      await pumpUntilFound(tester, find.textContaining('Walter'), timeout: const Duration(seconds: 10));
      expect(find.textContaining('Walter'), findsWidgets);
    });
  });
}
