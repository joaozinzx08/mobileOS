import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminSession {
  const AdminSession({
    required this.accessToken,
    required this.role,
    required this.registration,
  });
  final String accessToken;
  final String role;
  final String registration;
}

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Usa a API real de autenticação do GestaoOS Web.
/// O código da empresa identifica o tenant ao qual pertence o tablet.
class AdminAuthService {
  AdminAuthService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const String _apiUrl = String.fromEnvironment('GESTAOOS_API_URL');
  static const String _companyCode = String.fromEnvironment(
    'GESTAOOS_EMPRESA_CODIGO',
  );
  final http.Client _client;
  final bool _ownsClient;
  AdminSession? _session;

  AdminSession? get currentSession => _session;

  Future<AdminSession> login({
    required String registration,
    required String password,
    required String tabletName,
  }) async {
    final matricula = registration.trim();
    if (!RegExp(r'^\d{1,20}$').hasMatch(matricula) || password.isEmpty) {
      throw const AdminAuthException('Informe matrícula numérica e senha.');
    }
    if (_apiUrl.isEmpty || _companyCode.isEmpty) {
      throw const AdminAuthException(
        'Configure GESTAOOS_API_URL e GESTAOOS_EMPRESA_CODIGO.',
      );
    }
    final uri = Uri.tryParse(
      '${_apiUrl.replaceFirst(RegExp(r'/+$'), '')}/setorial/admin/login',
    );
    if (uri == null || !['http', 'https'].contains(uri.scheme)) {
      throw const AdminAuthException('Endereço da API inválido.');
    }
    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'codigoEmpresa': _companyCode,
              'matricula': matricula,
              'senha': password,
              'tablet': tabletName,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const AdminAuthException(
        'Não foi possível conectar ao GestaoOS Web.',
      );
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AdminAuthException('Matrícula, senha ou permissão inválida.');
    }
    if (response.statusCode == 429) {
      throw const AdminAuthException(
        'Muitas tentativas. Aguarde alguns minutos.',
      );
    }
    if (response.statusCode != 200) {
      throw const AdminAuthException(
        'Falha na autenticação administrativa do servidor.',
      );
    }
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['accessToken'];
      final role = data['role'];
      if (token is! String ||
          token.isEmpty ||
          role is! String ||
          !{'super_admin', 'ti_manager'}.contains(role) ||
          data['canManageTablet'] != true) {
        throw const FormatException('Resposta inválida');
      }
      return _session = AdminSession(
        accessToken: token,
        role: role,
        registration: matricula,
      );
    } catch (_) {
      throw const AdminAuthException('Servidor não confirmou autorização.');
    }
  }

  void logout() => _session = null;
  void dispose() {
    logout();
    if (_ownsClient) _client.close();
  }
}
