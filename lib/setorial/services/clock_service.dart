import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Mantém hora e data de São Paulo atualizadas sem exigir pacote adicional.
///
/// A API é consultada ao abrir, a cada cinco minutos e quando o app retoma.
/// Entre consultas usa um Stopwatch, não o relógio do tablet, para avançar.
/// Se não houver rede, usa a hora local como alternativa.
class ClockService extends ChangeNotifier {
  DateTime _base = DateTime.now();
  final Stopwatch _elapsed = Stopwatch()..start();
  Timer? _tick;
  Timer? _refresh;
  bool _disposed = false;
  bool _syncing = false;
  bool _synced = false;

  static const _url =
      'https://timeapi.io/api/Time/current/zone?timeZone=America/Sao_Paulo';

  DateTime get agora => _base.add(_elapsed.elapsed);
  bool get sincronizado => _synced;

  String get horarioFormatado {
    final value = agora;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  String get dataFormatada {
    final value = agora;
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final day = value.day.toString().padLeft(2, '0');
    return '${weekdays[value.weekday - 1]}, $day ${months[value.month - 1]}';
  }

  void iniciar() {
    if (_disposed || _tick != null) return;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_disposed) notifyListeners();
    });
    _refresh = Timer.periodic(const Duration(minutes: 5), (_) {
      sincronizar();
    });
    sincronizar();
  }

  Future<void> sincronizar() async {
    if (_disposed || _syncing) return;
    _syncing = true;
    final requestTime = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client
          .getUrl(Uri.parse(_url))
          .timeout(const Duration(seconds: 8));
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 8));
      final json = jsonDecode(body) as Map<String, dynamic>;
      final time = DateTime(
        (json['year'] as num).toInt(),
        (json['month'] as num).toInt(),
        (json['day'] as num).toInt(),
        (json['hour'] as num).toInt(),
        (json['minute'] as num).toInt(),
        (json['seconds'] as num).toInt(),
        ((json['milliSeconds'] ?? 0) as num).toInt(),
      );
      requestTime.stop();
      if (_disposed) return;
      // Compensa aproximadamente o atraso entre consulta e resposta.
      _base = time.add(
        Duration(microseconds: requestTime.elapsedMicroseconds ~/ 2),
      );
      _elapsed
        ..reset()
        ..start();
      _synced = true;
      notifyListeners();
    } catch (e) {
      debugPrint('ClockService: sem sincronização pela API: $e');
      // Preserva a última sincronização em vez de voltar ao relógio do tablet.
      if (!_synced && !_disposed) {
        _base = DateTime.now();
        _elapsed
          ..reset()
          ..start();
        notifyListeners();
      }
    } finally {
      client.close(force: true);
      _syncing = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _refresh?.cancel();
    _elapsed.stop();
    super.dispose();
  }
}
