// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import '../lib/setorial/services/setorial_repository.dart';

void main() {
  testWidgets('Etapa 07 - Início e fluxo básico', (tester) async {
    tester.view.physicalSize = const Size(1180, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(GestaoOSSetorialApp(repository: DemoSetorialRepository()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Abrir nova OS'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink()); // Cancela timers do controlador.
  });

  test('PIN fictício para demonstração', () async {
    final repo = DemoSetorialRepository();
    expect((await repo.validatePin('04218', '1234'))?.firstName, 'João');
    expect(await repo.validatePin('04218', '0000'), isNull);
  });
}
