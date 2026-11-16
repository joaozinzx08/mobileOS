import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/setorial_models.dart';

/// Guarda apenas preferências do dispositivo.
/// Não guarda credenciais, PINs, tokens ou permissões administrativas.
class TabletSettingsStore {
  static const _key = 'gestaoos_setorial_tablet_settings_v1';

  Future<TabletSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null) return TabletSettings();

    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return TabletSettings();
      final defaults = TabletSettings();
      final idle = data['inactivitySeconds'];
      return TabletSettings(
        sector: _nonEmpty(data['sector'], defaults.sector),
        location: _nonEmpty(data['location'], defaults.location),
        deviceName: _nonEmpty(data['deviceName'], defaults.deviceName),
        inactivitySeconds: idle is int && <int>{30, 60, 120, 300}.contains(idle)
            ? idle
            : defaults.inactivitySeconds,
        kioskMode: _boolean(data['kioskMode'], defaults.kioskMode),
        requirePin: _boolean(data['requirePin'], defaults.requirePin),
        showSectorOrders: _boolean(
          data['showSectorOrders'],
          defaults.showSectorOrders,
        ),
        allowPhotos: _boolean(data['allowPhotos'], defaults.allowPhotos),
      );
    } catch (_) {
      // Dados antigos/corrompidos não impedem o tablet de abrir.
      return TabletSettings();
    }
  }

  Future<void> save(TabletSettings value) async {
    final preferences = await SharedPreferences.getInstance();
    final data = <String, Object>{
      'sector': value.sector,
      'location': value.location,
      'deviceName': value.deviceName,
      'inactivitySeconds': value.inactivitySeconds,
      'kioskMode': value.kioskMode,
      'requirePin': value.requirePin,
      'showSectorOrders': value.showSectorOrders,
      'allowPhotos': value.allowPhotos,
    };
    final saved = await preferences.setString(_key, jsonEncode(data));
    if (!saved) throw StateError('Não foi possível salvar no dispositivo.');
  }

  static String _nonEmpty(Object? value, String fallback) {
    if (value is! String || value.trim().isEmpty) return fallback;
    return value.trim();
  }

  static bool _boolean(Object? value, bool fallback) =>
      value is bool ? value : fallback;
}
