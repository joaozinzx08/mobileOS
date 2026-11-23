import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/setorial_models.dart';

abstract class SetorialRepository {
  Future<List<WorkOrder>> fetchOrders();
  Future<Applicant?> validatePin(String registration, String pin);
  Future<WorkOrder> submitOrder(OrderDraft draft, TabletSettings tablet);
}

class SetorialApiException implements Exception {
  const SetorialApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Repositório real do GestaoOS Web.
/// O token recebido na identificação pertence ao solicitante e é usado
/// para abrir a OS no tenant e setor corretos.
class ApiSetorialRepository implements SetorialRepository {
  ApiSetorialRepository({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  static const String _apiUrl = String.fromEnvironment('GESTAOOS_API_URL');
  static const String _companyCode =
      String.fromEnvironment('GESTAOOS_EMPRESA_CODIGO');

  final http.Client _client;
  final bool _ownsClient;
  String? _token;
  String? _sectorId;

  static bool get isConfigured => _apiUrl.isNotEmpty && _companyCode.isNotEmpty;

  Uri _uri(String path) {
    final base = _apiUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse('$base$path');
    if (uri == null || !['http', 'https'].contains(uri.scheme)) {
      throw const SetorialApiException('Endereço da API inválido.');
    }
    return uri;
  }

  Map<String, String> _headers({bool json = false}) => {
        if (json) 'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _json(http.Response response) async {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    final message = data['error'];
    if (message is String && message.trim().isNotEmpty) {
      throw SetorialApiException(message);
    }
    if (response.statusCode == 401) {
      _token = null;
      _sectorId = null;
      throw const SetorialApiException('Sessão expirada. Identifique-se novamente.');
    }
    if (response.statusCode == 429) {
      throw const SetorialApiException(
        'Muitas tentativas. Aguarde alguns minutos.',
      );
    }
    throw const SetorialApiException('O GestaoOS Web não aceitou a operação.');
  }

  @override
  Future<Applicant?> validatePin(String registration, String pin) async {
    if (!isConfigured) {
      throw const SetorialApiException(
        'Configure GESTAOOS_API_URL e GESTAOOS_EMPRESA_CODIGO.',
      );
    }

    http.Response response;
    try {
      response = await _client
          .post(
            _uri('/setorial/identificar'),
            headers: _headers(json: true),
            body: jsonEncode({
              'codigoEmpresa': _companyCode,
              'matricula': registration.trim(),
              'pin': pin,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const SetorialApiException(
        'Não foi possível conectar ao GestaoOS Web.',
      );
    }

    final data = await _json(response);
    final token = data['token'];
    final user = data['usuario'];
    final sector = data['setor'];

    if (token is! String ||
        token.isEmpty ||
        user is! Map<String, dynamic> ||
        sector is! Map<String, dynamic> ||
        user['nome'] is! String ||
        sector['id'] is! String) {
      throw const SetorialApiException(
        'O servidor retornou uma identificação inválida.',
      );
    }

    _token = token;
    _sectorId = sector['id'] as String;
    return Applicant(
      registration: registration.trim(),
      name: user['nome'] as String,
    );
  }

  @override
  Future<List<WorkOrder>> fetchOrders() async {
    if (_token == null) return const [];

    http.Response response;
    try {
      response = await _client
          .get(_uri('/setorial/ordens'), headers: _headers())
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const SetorialApiException(
        'Não foi possível atualizar as OS do setor.',
      );
    }

    final data = await _json(response);
    if (data.isEmpty) return const [];
    final list = data['items'] is List ? data['items'] : data.values.first;
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((item) => _workOrder(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<WorkOrder> submitOrder(
    OrderDraft draft,
    TabletSettings tablet,
  ) async {
    final applicant = draft.applicant;
    final sectorId = _sectorId;
    if (_token == null || applicant == null || sectorId == null) {
      throw const SetorialApiException(
        'Identifique o solicitante antes de abrir a OS.',
      );
    }
    if (draft.type == null ||
        draft.description.trim().isEmpty ||
        draft.location.trim().isEmpty) {
      throw const SetorialApiException(
        'Preencha identificação, tipo, local e descrição.',
      );
    }

    final request = http.MultipartRequest('POST', _uri('/ordens'));
    request.headers.addAll(_headers());
    request.fields.addAll({
      'titulo': '${draft.type}: ${draft.location}',
      'descricao': draft.description.trim(),
      'setorResponsavelId': sectorId,
      'categoria': draft.type!,
      'prioridade': draft.priority,
      'local': draft.location.trim(),
      'sigilo': 'false',
    });

    for (final path in draft.photos.take(5)) {
      try {
        request.files.add(await http.MultipartFile.fromPath('anexos', path));
      } catch (_) {
        throw const SetorialApiException(
          'Não foi possível preparar uma das fotos da OS.',
        );
      }
    }

    http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const SetorialApiException(
        'Não foi possível enviar a OS ao GestaoOS Web.',
      );
    }

    final response = await http.Response.fromStream(streamed);
    final data = await _json(response);
    return _workOrder(data);
  }

  WorkOrder _workOrder(Map<String, dynamic> data) {
    final rawStatus = data['status'] as String? ?? 'Aberta';
    final status = switch (rawStatus) {
      'Aberta' => 'Aberta',
      'Concluída' => 'Concluída',
      'Cancelada' => 'Cancelada',
      _ => 'Em andamento',
    };
    final history = <OrderEvent>[];
    final rawHistory = data['historico'];
    if (rawHistory is List) {
      for (final item in rawHistory.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        history.add(
          OrderEvent(
            map['acao'] as String? ?? 'Atualização',
            map['descricao'] as String? ?? '',
          ),
        );
      }
    }

    final created = DateTime.tryParse(
          data['dataAbertura'] as String? ?? '',
        ) ??
        DateTime.now();
    final local = data['local'] as String? ??
        _locationFromTitle(data['titulo'] as String? ?? '');
    final type = data['categoria'] as String? ?? 'Manutenção geral';

    return WorkOrder(
      protocol: data['protocolo'] as String? ?? '#-----',
      type: type,
      title: data['titulo'] as String? ?? type,
      location: local,
      status: status,
      priority: data['prioridade'] as String? ?? 'Média',
      description: data['descricao'] as String? ?? '',
      requesterFirstName:
          _firstName(data['solicitanteNome'] as String? ?? 'Solicitante'),
      createdAt: created,
      history: history,
      demo: false,
    );
  }

  String _locationFromTitle(String title) {
    final index = title.indexOf(': ');
    return index >= 0 ? title.substring(index + 2) : '';
  }

  String _firstName(String name) => name.trim().split(' ').first;

  void dispose() {
    _token = null;
    _sectorId = null;
    if (_ownsClient) _client.close();
  }
}

/// Dados exclusivos de demonstração, preservados para testes locais.
class DemoSetorialRepository implements SetorialRepository {
  final List<WorkOrder> _orders = [];
  int _next = 253;
  DemoSetorialRepository() {
    final t = DateTime.now();
    _orders.addAll([
      WorkOrder(
        protocol: '#0252',
        type: 'Hidráulica',
        title: 'Vazamento na pia do banheiro',
        location: 'Bloco A',
        status: 'Aberta',
        priority: 'Média',
        description: 'Há um vazamento na pia do banheiro, o piso está molhado.',
        requesterFirstName: 'João',
        createdAt: t,
        history: [OrderEvent('Aberta', 'Agora · João G.')],
      ),
      WorkOrder(
        protocol: '#0251',
        type: 'Ar-condicionado',
        title: 'Ar-condicionado sem refrigerar',
        location: 'Sala de reuniões',
        status: 'Aberta',
        priority: 'Baixa',
        description: 'O ar-condicionado não está refrigerando.',
        requesterFirstName: 'Maria',
        createdAt: t.subtract(const Duration(minutes: 40)),
        history: [OrderEvent('Aberta', '09:02 · Maria')],
      ),
      WorkOrder(
        protocol: '#0250',
        type: 'Elétrica',
        title: 'Lâmpada apagada na produção',
        location: 'Bloco A',
        status: 'Aberta',
        priority: 'Baixa',
        description: 'Lâmpada no corredor principal apagada.',
        requesterFirstName: 'Pedro',
        createdAt: t.subtract(const Duration(minutes: 90)),
        history: const [OrderEvent('Aberta', 'Aberta na produção')],
      ),
      WorkOrder(
        protocol: '#0248',
        type: 'Hidráulica',
        title: 'Vazamento no banheiro do 2º andar',
        location: 'Bloco A',
        status: 'Em andamento',
        priority: 'Alta',
        description:
            'Há um vazamento na pia do banheiro, o piso está molhado desde cedo.',
        requesterFirstName: 'João',
        createdAt: t.subtract(const Duration(hours: 2)),
        history: [
          OrderEvent('Aberta', '08:10 · João G.'),
          OrderEvent('Em análise', '08:32'),
          OrderEvent('Técnico atribuído', 'Carlos M.'),
          OrderEvent('Em execução', 'Previsto 14:00'),
        ],
      ),
      WorkOrder(
        protocol: '#0246',
        type: 'TI e rede',
        title: 'Computador não liga',
        location: 'Financeiro',
        status: 'Em andamento',
        priority: 'Média',
        description: 'O computador não liga após reiniciar.',
        requesterFirstName: 'Ana',
        createdAt: t.subtract(const Duration(days: 1)),
        history: [
          OrderEvent('Aberta', 'Ontem'),
          OrderEvent('Em análise', 'Em andamento'),
        ],
      ),
      for (var i = 0; i < 5; i++)
        WorkOrder(
          protocol: '#02${40 - i}',
          type: 'Manutenção geral',
          title: 'Manutenção concluída ${i + 1}',
          location: 'Bloco A',
          status: 'Concluída',
          priority: 'Baixa',
          description: 'Solicitação demonstrativa já concluída.',
          requesterFirstName: 'Equipe',
          createdAt: t.subtract(Duration(days: i + 1)),
          history: const [
            OrderEvent('Aberta', 'Registrada'),
            OrderEvent('Concluída', 'Resolvida'),
          ],
        ),
    ]);
  }

  @override
  Future<List<WorkOrder>> fetchOrders() async => List.unmodifiable(_orders);

  @override
  Future<Applicant?> validatePin(String registration, String pin) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (registration.trim() == '04218' && pin == '1234') {
      return const Applicant(
        registration: '04218',
        name: 'João Gabriel Pereira',
      );
    }
    return null;
  }

  @override
  Future<WorkOrder> submitOrder(
    OrderDraft draft,
    TabletSettings tablet,
  ) async {
    final applicant = draft.applicant;
    if (applicant == null ||
        draft.type == null ||
        draft.description.trim().isEmpty) {
      throw StateError('Preencha identificação, tipo e descrição.');
    }
    final id = _next++;
    final order = WorkOrder(
      protocol: '#${id.toString().padLeft(4, '0')}',
      title: '${draft.type}: ${draft.location}',
      type: draft.type!,
      location: draft.location,
      status: 'Aberta',
      priority: draft.priority,
      description: draft.description.trim(),
      requesterFirstName: applicant.firstName,
      createdAt: DateTime.now(),
      history: [OrderEvent('Aberta', 'Agora · ${applicant.firstName}')],
    );
    _orders.insert(0, order);
    return order;
  }
}
