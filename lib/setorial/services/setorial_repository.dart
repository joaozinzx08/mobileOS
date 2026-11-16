import '../models/setorial_models.dart';

/// Dados exclusivos de demonstração. Não existe autenticação real nesta versão.
/// Conectar um backend autorizador de tablets antes de qualquer uso empresarial.
abstract class SetorialRepository {
  Future<List<WorkOrder>> fetchOrders();
  Future<Applicant?> validatePin(String registration, String pin);
  Future<WorkOrder> submitOrder(OrderDraft draft, TabletSettings tablet);
}

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

  /// Credencial fictícia de demonstração, nunca enviada ao servidor.
  /// Para experimentar as telas: matrícula 04218 e PIN 1234.
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
  Future<WorkOrder> submitOrder(OrderDraft draft, TabletSettings tablet) async {
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
