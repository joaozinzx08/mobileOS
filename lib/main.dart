import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'setorial/controller.dart';
import 'setorial/screens/setorial_root.dart';
import 'setorial/services/setorial_repository.dart';
import 'setorial/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Modo imersivo para tablet compartilhado (não é bloqueio de quiosque).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const GestaoOSSetorialApp());
}

/// App do tablet setorial, mantendo o repositório atual (demo ou API).
class GestaoOSSetorialApp extends StatefulWidget {
  const GestaoOSSetorialApp({super.key, this.repository});

  final SetorialRepository? repository;

  @override
  State<GestaoOSSetorialApp> createState() => _GestaoOSSetorialAppState();
}

class _GestaoOSSetorialAppState extends State<GestaoOSSetorialApp> {
  late final SetorialController controller = SetorialController(
    widget.repository ?? DemoSetorialRepository(),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestaoOS Setorial',
      debugShowCheckedModeBanner: false,
      // A fonte Poppins é definida globalmente em setorial/theme.dart.
      theme: buildSetorialTheme(),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => controller.touch(),
          child: SetorialRoot(controller: controller),
        ),
      ),
    );
  }
}
