import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/admin_auth_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';

/// Acesso exclusivo de TI e administradores principais.
/// Matrícula pelo teclado numérico; senha pelo teclado completo do Android.
class SetorialAdminLogin extends StatefulWidget {
  const SetorialAdminLogin({
    super.key,
    required this.authService,
    required this.tabletName,
    required this.onAuthenticated,
    required this.onCancel,
  });

  final AdminAuthService authService;
  final String tabletName;
  final ValueChanged<AdminSession> onAuthenticated;
  final VoidCallback onCancel;

  @override
  State<SetorialAdminLogin> createState() => _SetorialAdminLoginState();
}

class _SetorialAdminLoginState extends State<SetorialAdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _registration = TextEditingController();
  final _password = TextEditingController();
  final _registrationFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _busy = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _registration.dispose();
    _password.dispose();
    _registrationFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _digit(String value) {
    if (_busy) return;
    final selection = _registration.selection;
    final source = _registration.text;
    final begin = selection.isValid ? selection.start : source.length;
    final end = selection.isValid ? selection.end : source.length;
    String result;
    int cursor;
    if (value == 'Limpar') {
      result = '';
      cursor = 0;
    } else if (value == '⌫') {
      if (begin != end) {
        result = source.replaceRange(begin, end, '');
        cursor = begin;
      } else if (begin > 0) {
        result = source.replaceRange(begin - 1, begin, '');
        cursor = begin - 1;
      } else {
        return;
      }
    } else {
      result = source.replaceRange(begin, end, value);
      cursor = begin + value.length;
    }
    _registration.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursor),
    );
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _signIn() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await widget.authService.login(
        registration: _registration.text,
        password: _password.text,
        tabletName: widget.tabletName,
      );
      _password.clear();
      if (mounted) widget.onAuthenticated(session);
    } on AdminAuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível validar o acesso.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final wide = bounds.maxWidth >= 850;
        final pad = bounds.maxWidth < 600 ? 16.0 : 28.0;
        final entry = SCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: SColors.primary,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Acesso administrativo',
                  style: TextStyle(
                    fontSize: wide ? 30 : 24,
                    fontWeight: FontWeight.w800,
                    color: SColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Informe sua matrícula e senha corporativa. '
                  'Somente gestores de TI e administradores principais.',
                  style: TextStyle(fontSize: 15, color: SColors.muted),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Matrícula',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _registration,
                  focusNode: _registrationFocus,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  autofillHints: const [AutofillHints.username],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex.: 04218',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: SColors.primary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: SColors.primary),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe sua matrícula.'
                      : null,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Senha corporativa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  enabled: !_busy,
                  obscureText: !_showPassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: SColors.primary,
                    ),
                    filled: true,
                    fillColor: SColors.soft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    suffixIcon: IconButton(
                      tooltip: _showPassword
                          ? 'Ocultar senha'
                          : 'Mostrar senha',
                      onPressed: _busy
                          ? null
                          : () =>
                                setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Informe sua senha.'
                      : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: SColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SPrimaryButton(
                  _busy ? 'Verificando...' : 'Acessar configurações',
                  onPressed: _busy ? null : _signIn,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _busy ? null : widget.onCancel,
                  child: const Text('Voltar ao início'),
                ),
                const SizedBox(height: 5),
                const Text(
                  'O acesso requer conexão com o GestaoOS Web.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        );

        final keypad = SCard(
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: wide ? 1.67 : 1.85,
                children: [
                  for (final key in [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    'Limpar',
                    '0',
                    '⌫',
                  ])
                    Material(
                      color: SColors.soft,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: _busy ? null : () => _digit(key),
                        borderRadius: BorderRadius.circular(22),
                        child: Center(
                          child: Text(
                            key,
                            style: TextStyle(
                              color: key == 'Limpar'
                                  ? SColors.muted
                                  : SColors.ink,
                              fontSize: key == 'Limpar' ? 17 : 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Teclado numérico para matrícula. '
                'Use o teclado do tablet para digitar a senha.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SColors.muted, fontSize: 13),
              ),
            ],
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: entry),
                    const SizedBox(width: 24),
                    Expanded(child: keypad),
                  ],
                )
              : Column(children: [entry, const SizedBox(height: 20), keypad]),
        );
      },
    );
  }
}
