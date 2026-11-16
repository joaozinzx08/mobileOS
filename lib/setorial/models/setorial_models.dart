class TabletSettings {
  TabletSettings({
    this.sector = 'Produção',
    this.location = 'Bloco A · 2º andar',
    this.deviceName = 'Tablet 03',
    this.inactivitySeconds = 60,
    this.kioskMode = true,
    this.requirePin = true,
    this.showSectorOrders = true,
    this.allowPhotos = true,
  });
  String sector, location, deviceName;
  int inactivitySeconds;
  bool kioskMode, requirePin, showSectorOrders, allowPhotos;
}

class Applicant {
  const Applicant({required this.registration, required this.name});
  final String registration, name;
  String get firstName => name.split(' ').first;
}

class WorkOrder {
  WorkOrder({
    required this.protocol,
    required this.type,
    required this.title,
    required this.location,
    required this.status,
    required this.priority,
    required this.description,
    required this.createdAt,
    required this.requesterFirstName,
    this.history = const [],
    this.demo = true,
  });
  final String protocol, type, title, location, status, priority, description;
  final String requesterFirstName;
  final DateTime createdAt;
  final List<OrderEvent> history;
  final bool demo;
}

class OrderEvent {
  const OrderEvent(this.label, this.detail);
  final String label, detail;
}

class OrderDraft {
  Applicant? applicant;
  String? type;
  String priority = 'Média';
  String location = '';
  String description = '';
  final List<String> photos =
      []; // Anexos pendentes: sem plugin de câmera nesta etapa.
  void clear() {
    applicant = null;
    type = null;
    priority = 'Média';
    location = '';
    description = '';
    photos.clear();
  }
}
