import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/setorial_models.dart';
import 'services/setorial_repository.dart';
import 'services/tablet_settings_store.dart';

enum SectorPage {
  home,
  identification,
  type,
  details,
  confirmation,
  orders,
  admin,
}

/// Single state for the shared tablet. Wipes in-progress identification on idle.
class SetorialController extends ChangeNotifier {
  SetorialController(this.repository) {
    load();
    _loadSavedSettings();
  }
  final SetorialRepository repository;
  final TabletSettingsStore _settingsStore = TabletSettingsStore();
  bool _disposed = false;
  TabletSettings settings = TabletSettings();
  final OrderDraft draft = OrderDraft();
  SectorPage page = SectorPage.home;
  List<WorkOrder> orders = [];
  WorkOrder? selectedOrder, createdOrder;
  DateTime? pinLockedUntil;
  int failedPins = 0, confirmationRemaining = 7;
  String ordersFilter = 'Todas';
  bool isLoadingOrders = false;
  Timer? _idleTimer, _confirmationTimer;
  bool isCheckingPin = false;
  String? error;

  bool get isDemo => repository is DemoSetorialRepository;
  bool get isPinLocked =>
      pinLockedUntil != null && DateTime.now().isBefore(pinLockedUntil!);
  void touch() {
    if (page == SectorPage.home) return;
    _armIdle();
  }

  void _armIdle() {
    _idleTimer?.cancel();
    _idleTimer = Timer(Duration(seconds: settings.inactivitySeconds), backHome);
  }

  void go(SectorPage next) {
    page = next;
    error = null;
    _confirmationTimer?.cancel();
    if (next == SectorPage.home) {
      _idleTimer?.cancel();
    } else {
      _armIdle();
    }
    notifyListeners();
  }

  void backHome() {
    _idleTimer?.cancel();
    _confirmationTimer?.cancel();
    draft.clear();
    page = SectorPage.home;
    error = null;
    selectedOrder = null;
    createdOrder = null;
    notifyListeners();
  }

  Future<void> load() async {
    isLoadingOrders = true;
    notifyListeners();
    try {
      orders = await repository.fetchOrders();
    } finally {
      isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrders() => load();

  // Inicia identificação preservando a categoria do atalho.
  void startWithType(String type) {
    draft.clear();
    draft.type = type;
    go(SectorPage.identification);
  }

  void openOrdersFiltered(String filter) {
    ordersFilter = filter;
    selectedOrder = null;
    go(SectorPage.orders);
  }

  // O contador só inicia quando a animação da confirmação termina.
  void startConfirmationCountdown() {
    if (page != SectorPage.confirmation || _confirmationTimer != null) return;
    confirmationRemaining = 7;
    notifyListeners();
    _confirmationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (page != SectorPage.confirmation) {
        timer.cancel();
        _confirmationTimer = null;
        return;
      }
      confirmationRemaining--;
      if (confirmationRemaining <= 0) {
        timer.cancel();
        _confirmationTimer = null;
        backHome();
      } else {
        notifyListeners();
      }
    });
  }

  void startIdentification() {
    draft.clear();
    go(SectorPage.identification);
  }

  Future<bool> submitPin(String reg, String pin) async {
    if (isPinLocked) {
      error = 'Aguarde antes de tentar novamente.';
      notifyListeners();
      return false;
    }
    isCheckingPin = true;
    error = null;
    notifyListeners();
    try {
      final applicant = await repository.validatePin(reg, pin);
      if (applicant != null) {
        failedPins = 0;
        draft.applicant = applicant;
        draft.location = settings.location;
        go(SectorPage.type);
        return true;
      }
      failedPins++;
      if (failedPins >= 5) {
        pinLockedUntil = DateTime.now().add(const Duration(seconds: 30));
        failedPins = 0;
        error = 'Muitas tentativas. Aguarde 30 segundos.';
      } else {
        error = 'Matrícula ou PIN inválido. Tentativa $failedPins de 5.';
      }
      notifyListeners();
      return false;
    } on SetorialApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } finally {
      isCheckingPin = false;
      notifyListeners();
    }
  }

  void selectType(String type) {
    draft.type = type;
    notifyListeners();
    touch();
  }

  void selectPriority(String p) {
    draft.priority = p;
    notifyListeners();
    touch();
  }

  void selectLocation(String loc) {
    draft.location = loc;
    notifyListeners();
    touch();
  }

  void selectDescription(String d) {
    draft.description = d;
    notifyListeners();
    touch();
  }

  void photoAdded() {
    notifyListeners();
    touch();
  }

  Future<bool> submit() async {
    if (draft.type == null ||
        draft.applicant == null ||
        draft.description.trim().isEmpty ||
        draft.location.trim().isEmpty) {
      error = 'Informe local e descrição para continuar.';
      notifyListeners();
      return false;
    }
    try {
      createdOrder = await repository.submitOrder(draft, settings);
      await load();
      go(SectorPage.confirmation);
      confirmationRemaining = 7;
      _confirmationTimer?.cancel();
      _confirmationTimer = null;
      return true;
    } catch (_) {
      error = _submitError(_);
      notifyListeners();
      return false;
    }
  }

  String _submitError(Object error) {
    if (error is SetorialApiException) return error.message;
    return 'Não foi possível registrar a OS.';
  }

  void openOrder(WorkOrder o) {
    selectedOrder = o;
    go(SectorPage.orders);
  }

  Future<void> _loadSavedSettings() async {
    try {
      final saved = await _settingsStore.load();
      if (_disposed) return;
      // Sem autenticação de identificação no backend, jamais ignorar matrícula/PIN.
      saved.requirePin = true;
      settings = saved;
      notifyListeners();
    } catch (_) {
      // Mantém preferências padrão se o armazenamento estiver indisponível.
    }
  }

  /// Salva no armazenamento local antes de retornar à Home.
  /// Falhas são propagadas para a tela exibir uma mensagem, sem falsa confirmação.
  Future<void> saveSettings(TabletSettings value) async {
    // Impede que uma preferência local desative a identificação do solicitante.
    // A opção só poderá ser flexível após autorização implementada no servidor.
    value.requirePin = true;
    await _settingsStore.save(value);
    if (_disposed) return;
    settings = value;
    go(SectorPage.home);
  }

  @override
  void dispose() {
    _disposed = true;
    _idleTimer?.cancel();
    _confirmationTimer?.cancel();
    super.dispose();
  }
}
