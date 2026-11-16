import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'setorial/controller.dart';
import 'setorial/screens/setorial_root.dart';
import 'setorial/services/setorial_repository.dart';
import 'setorial/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Oculta temporariamente barras: não é Android Lock Task / kiosk de segurança.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const GestaoOSSetorialApp());
}

/// Entrada separada. Não modifica o main.dart do app pessoal.
class GestaoOSSetorialApp extends StatefulWidget {
  const GestaoOSSetorialApp({super.key, this.repository});
  final SetorialRepository? repository;
  @override
  State<GestaoOSSetorialApp> createState() => _GestaoOSSetorialAppState();
}
class _GestaoOSSetorialAppState extends State<GestaoOSSetorialApp> {
  late final SetorialController controller = SetorialController(widget.repository ?? DemoSetorialRepository());
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    const systemFont = bool.fromEnvironment('GESTAOOS_SYSTEM_FONT', defaultValue: false);
    return MaterialApp(
    title: 'GestaoOS Setorial', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: SColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: SColors.primary),
      textTheme: (systemFont ? ThemeData.light().textTheme : GoogleFonts.poppinsTextTheme())
        .apply(bodyColor: SColors.ink, displayColor: SColors.ink)),
    home: AnimatedBuilder(animation: controller, builder: (_, _) =>
      Listener(behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => controller.touch(),
        child: SetorialRoot(controller: controller))),
  );
  }
}
