import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller.dart';
import '../services/admin_auth_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import 'admin_login.dart';
import 'home.dart';
import 'identification.dart';
import 'service_type.dart';
import 'details.dart';
import 'confirmation.dart';
import 'sector_orders.dart';
import 'tablet_settings.dart';

/// A engrenagem abre o login. Não há PIN de demonstração ou acesso sem API.
class SetorialRoot extends StatefulWidget {
  const SetorialRoot({super.key, required this.controller});
  final SetorialController controller;

  @override
  State<SetorialRoot> createState() => _SetorialRootState();
}

class _SetorialRootState extends State<SetorialRoot> {
  final AdminAuthService _auth = AdminAuthService();
  bool _showAdminLogin = false;
  bool? _lastImmersiveSetting;

  /// Tela cheia visual. NÃO é bloqueio de quiosque (Lock Task / Device Owner).
  void _updateImmersiveMode() {
    final enabled = widget.controller.settings.kioskMode;
    if (_lastImmersiveSetting == enabled) return;
    _lastImmersiveSetting = enabled;
    SystemChrome.setEnabledSystemUIMode(
      enabled ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateImmersiveMode();
    });
  }

  @override
  void didUpdateWidget(covariant SetorialRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
      _lastImmersiveSetting = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateImmersiveMode();
      });
    }
  }

  void _handleControllerChange() {
    _updateImmersiveMode();
    // Sair, salvar ou expirar inatividade encerra o acesso administrativo.
    if (widget.controller.page != SectorPage.admin &&
        _auth.currentSession != null) {
      _auth.logout();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _auth.dispose();
    // Restaura barras do sistema ao sair desta interface.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _openLogin() {
    _auth.logout();
    setState(() => _showAdminLogin = true);
  }

  void _closeLogin() {
    _auth.logout();
    setState(() => _showAdminLogin = false);
  }

  void _authenticated(AdminSession session) {
    if (!mounted) return;
    // O serviço já verificou no retorno da API canManageTablet e o papel.
    if (_auth.currentSession != session) return;
    widget.controller.go(SectorPage.admin);
    setState(() => _showAdminLogin = false);
  }

  void _back() {
    if (_showAdminLogin) {
      _closeLogin();
      return;
    }
    if (widget.controller.page == SectorPage.admin) {
      _auth.logout();
      widget.controller.backHome();
      return;
    }
    switch (widget.controller.page) {
      case SectorPage.details:
        widget.controller.go(SectorPage.type);
        break;
      case SectorPage.type:
        widget.controller.go(SectorPage.identification);
        break;
      default:
        widget.controller.backHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isHome = controller.page == SectorPage.home && !_showAdminLogin;
    final isProtected = controller.page == SectorPage.admin;
    final isAuthorized = _auth.currentSession != null;

    final title = _showAdminLogin
        ? 'Identificação administrativa'
        : switch (controller.page) {
            SectorPage.home => null,
            SectorPage.identification => 'Identificação',
            SectorPage.type || SectorPage.details => 'Nova OS',
            SectorPage.confirmation => 'Confirmação',
            SectorPage.orders => 'OS do setor',
            SectorPage.admin => 'Configuração do tablet',
          };

    final Widget page = _showAdminLogin || (isProtected && !isAuthorized)
        ? SetorialAdminLogin(
            authService: _auth,
            tabletName: controller.settings.deviceName,
            onAuthenticated: _authenticated,
            onCancel: _closeLogin,
          )
        : switch (controller.page) {
            SectorPage.home => SetorialHome(controller: controller),
            SectorPage.identification => SetorialIdentification(
              controller: controller,
            ),
            SectorPage.type => SetorialServiceType(controller: controller),
            SectorPage.details => SetorialOrderDetails(controller: controller),
            SectorPage.confirmation => SetorialConfirmation(
              controller: controller,
            ),
            SectorPage.orders => SetorialSectorOrders(controller: controller),
            SectorPage.admin => SetorialTabletSettings(controller: controller),
          };

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (!_showAdminLogin && controller.page != SectorPage.home) {
          controller.touch();
        }
      },
      child: Scaffold(
        backgroundColor: controller.page == SectorPage.confirmation
            ? Colors.white
            : SColors.background,
        body: Column(
          children: [
            STopBar(
              controller: controller,
              title: title,
              onBack:
                  isHome ||
                      (controller.page == SectorPage.confirmation &&
                          !_showAdminLogin)
                  ? null
                  : _back,
              onAdmin: isHome ? _openLogin : null,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: KeyedSubtree(
                  key: ValueKey(
                    _showAdminLogin ? 'admin-login' : controller.page,
                  ),
                  child: page,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
