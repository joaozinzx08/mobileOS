import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobos/main_setorial.dart';
import 'package:mobos/setorial/services/setorial_repository.dart';

void main() {
  testWidgets('Home do setor oferece abertura e consulta de OS', (tester) async {
    tester.view.physicalSize = const Size(1474, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(GestaoOSSetorialApp(repository: DemoSetorialRepository()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Abrir nova OS'), findsOneWidget);
    expect(find.text('Últimas ordens'), findsOneWidget);
    await tester.tap(find.text('Abrir nova OS'));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('Quem está abrindo a OS?'), findsOneWidget);
  });

  test('Credencial de demonstração não é um login de produção', () async {
    final repo = DemoSetorialRepository();
    final ok = await repo.validatePin('04218', '1234');
    final rejected = await repo.validatePin('04218', '0000');
    expect(ok?.firstName, 'João');
    expect(rejected, isNull);
  });
}
