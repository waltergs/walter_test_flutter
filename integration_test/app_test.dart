import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walter_test_flutter/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:walter_test_flutter/models/user.dart';
import 'package:walter_test_flutter/models/address.dart';

Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw Exception('Finder $finder not found within $timeout');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AddressAdapter());
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>('users_box');
    final box = Hive.box<User>('users_box');
    await box.clear();
  });

  tearDownAll(() async {
    final box = Hive.box<User>('users_box');
    await box.clear();
    await box.close();
  });

  testWidgets('E2E crear usuario y ver detalle', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Ir a formulario
    await tester.tap(find.byKey(const Key('fab_add_user')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('firstName')), 'Integration');
    await tester.enterText(find.byKey(const Key('lastName')), 'Test');
   // Tocar el campo de fecha
    await tester.tap(find.byKey(const Key('birthDate')));
    await tester.pumpAndSettle();

    // Esperar a que aparezca el DatePicker
    final datePickerOkButton = find.text('OK');
    final datePickerDay = find.text('5');

    // Seleccionar día (ejemplo: 5)
    await tester.tap(datePickerDay);
    await tester.pumpAndSettle();

    // Confirmar selección
    await tester.tap(datePickerOkButton);
    await tester.pumpAndSettle();

    // Añadir dirección
    await tester.tap(find.byKey(const Key('add_address_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('addr_country')), 'Colombia');
    await tester.enterText(find.byKey(const Key('addr_department')), 'Caldas');
    await tester.enterText(find.byKey(const Key('addr_city')), 'Manizales');
    await tester.tap(find.byKey(const Key('dialog_add_address_button')));
    await tester.pumpAndSettle(); 

    // Guardar
    await tester.ensureVisible(find.byKey(const Key('save_user_button')));
    await tester.tap(find.byKey(const Key('save_user_button')));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Ver que aparece en lista
    await pumpUntilFound(tester, find.text('Integration Test'));
    expect(find.text('Integration Test'), findsOneWidget);

    // Abrir detalle
    await tester.tap(find.text('Integration Test'));
    await tester.pumpAndSettle();

    expect(find.text('Addresses / Direcciones'), findsOneWidget);
    await pumpUntilFound(tester, find.textContaining('Manizales'));
    expect(find.textContaining('Manizales'), findsOneWidget);
  });
}
