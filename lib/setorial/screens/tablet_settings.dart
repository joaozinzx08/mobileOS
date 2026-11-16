import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../controller.dart';
import '../models/setorial_models.dart';
import '../theme.dart';
import '../widgets/shared.dart';

/// Preferências locais do tablet. Autorização vem do login administrativo real.
class SetorialTabletSettings extends StatefulWidget {
  const SetorialTabletSettings({super.key, required this.controller});
  final SetorialController controller;
  @override
  State<SetorialTabletSettings> createState() => _SetorialTabletSettingsState();
}

class _SetorialTabletSettingsState extends State<SetorialTabletSettings> {
  bool _saving = false;
  bool _checkingApi = false;
  String _apiStatus = 'Ainda não verificada';
  DateTime? _lastApiCheck;
  bool _apiOnline = false;

  @override
  void initState() {
    super.initState();
    // Verifica a conexão sem confundir conectividade com sincronização de OS.
    Future<void>.microtask(_checkApi);
  }

  Future<void> _checkApi() async {
    if (_checkingApi || !mounted) return;
    if (_apiUrl.trim().isEmpty) {
      setState(() {
        _apiStatus = 'API não configurada';
        _apiOnline = false;
        _lastApiCheck = DateTime.now();
      });
      return;
    }
    setState(() => _checkingApi = true);
    try {
      final base = Uri.parse(
        _apiUrl.endsWith('/')
            ? _apiUrl.substring(0, _apiUrl.length - 1)
            : _apiUrl,
      );
      // O projeto usa GESTAOOS_API_URL terminando em /api.
      final response = await http
          .get(base.replace(path: '${base.path}/status'))
          .timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() {
        _apiOnline = response.statusCode == 200;
        _apiStatus = _apiOnline
            ? 'Servidor acessível'
            : 'HTTP ${response.statusCode}';
        _lastApiCheck = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiOnline = false;
        _apiStatus = 'Sem conexão com o Web';
        _lastApiCheck = DateTime.now();
      });
    } finally {
      if (mounted) setState(() => _checkingApi = false);
    }
  }

  String get _checkTime {
    final last = _lastApiCheck;
    if (last == null) return 'Não verificada';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(last.hour)}:${two(last.minute)}:${two(last.second)}';
  }

  late TabletSettings working = TabletSettings(
    sector: widget.controller.settings.sector,
    location: widget.controller.settings.location,
    deviceName: widget.controller.settings.deviceName,
    inactivitySeconds: widget.controller.settings.inactivitySeconds,
    kioskMode: widget.controller.settings.kioskMode,
    requirePin: widget.controller.settings.requirePin,
    showSectorOrders: widget.controller.settings.showSectorOrders,
    allowPhotos: widget.controller.settings.allowPhotos,
  );
  late final TextEditingController name = TextEditingController(
    text: working.deviceName,
  );
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (_, size) {
            final wide = size.maxWidth >= 850;
            final left = SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vínculo do tablet',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  _label('Setor'),
                  _select(working.sector, [
                    'Produção',
                    'Logística',
                    'TI',
                    'Manutenção',
                    'RH',
                    'Financeiro',
                  ], (v) => setState(() => working.sector = v)),
                  const SizedBox(height: 20),
                  _label('Local padrão das OS'),
                  _select(working.location, [
                    'Bloco A · 2º andar',
                    'Bloco A',
                    'Almoxarifado',
                    'Sala Técnica',
                    'Pátio',
                  ], (v) => setState(() => working.location = v)),
                  const SizedBox(height: 20),
                  _label('Nome do tablet'),
                  TextField(
                    controller: name,
                    onChanged: (v) => working.deviceName = v,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.tablet_android,
                        color: SColors.primary,
                      ),
                      filled: true,
                      fillColor: SColors.soft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _label('Voltar ao início após'),
                  _select(
                    '${working.inactivitySeconds}',
                    ['30', '60', '120', '300'],
                    (v) => setState(
                      () => working.inactivitySeconds = int.parse(v),
                    ),
                    suffix: ' segundos sem uso',
                  ),
                ],
              ),
            );
            final right = Column(
              children: [
                SCard(
                  child: Column(
                    children: [
                      _toggle(
                        Icons.lock_outline,
                        'Modo quiosque',
                        'Tela cheia visual; não bloqueia sair do aplicativo',
                        working.kioskMode,
                        (v) => setState(() => working.kioskMode = v),
                      ),
                      const Divider(color: SColors.border),
                      _toggle(
                        Icons.badge_outlined,
                        'Exigir matrícula e PIN',
                        'Obrigatório até a integração segura com o Web',
                        true,
                        (_) {},
                      ),
                      const Divider(color: SColors.border),
                      _toggle(
                        Icons.assignment_outlined,
                        'Mostrar OS do setor',
                        'Permite acompanhar as OS na tela inicial',
                        working.showSectorOrders,
                        (v) => setState(() => working.showSectorOrders = v),
                      ),
                      const Divider(color: SColors.border),
                      _toggle(
                        Icons.camera_alt_outlined,
                        'Permitir fotos',
                        'Usa a câmera do tablet nas OS',
                        working.allowPhotos,
                        (v) => setState(() => working.allowPhotos = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _value(
                              'Conexão com o Web',
                              _apiStatus,
                              _apiOnline ? SColors.green : SColors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _value(
                              'Último teste',
                              _checkTime,
                              SColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: _checkingApi ? null : _checkApi,
                        icon: Icon(
                          _checkingApi ? Icons.hourglass_top : Icons.refresh,
                        ),
                        label: Text(
                          _checkingApi ? 'Verificando...' : 'Testar conexão',
                        ),
                      ),
                      const Divider(color: SColors.border),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _value(
                              'Versão do app',
                              'Setorial · local',
                              SColors.ink,
                            ),
                          ),
                          Expanded(
                            child: _value(
                              'Sincronização de OS',
                              'Ainda não integrada',
                              SColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 25, 32, 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1D1),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline, color: Color(0xFF996000)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Preferências locais. Acesso administrativo exige autenticação real. O modo quiosque aqui é somente tela cheia, não bloqueio do Android.',
                            style: TextStyle(
                              color: Color(0xFF8A5600),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 23),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: 24),
                        Expanded(child: right),
                      ],
                    )
                  else
                    Column(children: [left, const SizedBox(height: 20), right]),
                ],
              ),
            );
          },
        ),
      ),
      SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: LayoutBuilder(
            builder: (_, size) {
              final wide = size.maxWidth >= 650;
              final buttons = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: wide ? 160 : 125,
                    child: SOutlineButton(
                      'Cancelar',
                      onPressed: widget.controller.backHome,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: wide ? 285 : 220,
                    child: SPrimaryButton(
                      _saving ? 'Salvando...' : 'Salvar configurações',
                      onPressed: _saving ? null : _saveSettings,
                    ),
                  ),
                ],
              );
              return wide
                  ? Row(
                      children: [
                        TextButton.icon(
                          onPressed: widget.controller.backHome,
                          icon: const Icon(Icons.logout, color: SColors.red),
                          label: const Text(
                            'Sair do modo administrador',
                            style: TextStyle(
                              color: SColors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        buttons,
                      ],
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: buttons,
                    );
            },
          ),
        ),
      ),
    ],
  );

  static const _apiUrl = String.fromEnvironment('GESTAOOS_API_URL');

  Future<void> _saveSettings() async {
    final tabletName = name.text.trim();
    if (tabletName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dê um nome ao tablet.')));
      return;
    }
    working.deviceName = tabletName;
    setState(() => _saving = true);
    try {
      await widget.controller.saveSettings(working);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar no tablet. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _label(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
    ),
  );
  Widget _select(
    String value,
    List<String> options,
    ValueChanged<String> onChange, {
    String suffix = '',
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: SColors.soft,
      borderRadius: BorderRadius.circular(19),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt,
                child: Text(
                  '$opt$suffix',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChange(v);
        },
      ),
    ),
  );
  Widget _toggle(
    IconData icon,
    String label,
    String subtitle,
    bool value,
    ValueChanged<bool> change,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            color: SColors.soft,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: SColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: SColors.muted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: SColors.primary,
          onChanged: label == 'Exigir matrícula e PIN' ? null : change,
        ),
      ],
    ),
  );
  Widget _value(String name, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: const TextStyle(color: SColors.muted, fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    ],
  );
}
