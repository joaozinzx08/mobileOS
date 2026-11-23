import 'package:flutter/material.dart';
import '../controller.dart';
import '../models/setorial_models.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class SetorialSectorOrders extends StatefulWidget {
  const SetorialSectorOrders({super.key, required this.controller});
  final SetorialController controller;
  @override
  State<SetorialSectorOrders> createState() => _SetorialSectorOrdersState();
}

class _SetorialSectorOrdersState extends State<SetorialSectorOrders> {
  late String filter;
  @override
  void initState() {
    super.initState();
    filter = widget.controller.ordersFilter;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, size) {
      final wide = size.maxWidth >= 850;
      final c = widget.controller;
      final rows = c.orders
          .where(
            (o) =>
                filter == 'Todas' ||
                (filter == 'Abertas' && o.status == 'Aberta') ||
                (filter == 'Andamento' && o.status == 'Em andamento') ||
                (filter == 'Concluídas' && o.status == 'Concluída'),
          )
          .toList();
      final selected = c.selectedOrder ?? (rows.isNotEmpty ? rows.first : null);
      final list = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final item in [
                'Todas',
                'Abertas',
                'Andamento',
                'Concluídas',
              ])
                ChoiceChip(
                  label: Text(
                    '$item (${c.orders.where((o) => item == 'Todas' || (item == 'Abertas' && o.status == 'Aberta') || (item == 'Andamento' && o.status == 'Em andamento') || (item == 'Concluídas' && o.status == 'Concluída')).length})',
                  ),
                  selected: item == filter,
                  selectedColor: SColors.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: item == filter ? SColors.primary : SColors.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: item == filter ? Colors.white : SColors.ink,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  onSelected: (_) => setState(() {
                    filter = item;
                    c.selectedOrder = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 22),
          for (final order in rows) ...[
            SOrderTile(
              order,
              height: 116,
              onTap: () => setState(() {
                c.selectedOrder = order;
                c.touch();
              }),
            ),
            const SizedBox(height: 13),
          ],
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(22),
              child: Text('Nenhuma OS encontrada neste filtro.'),
            ),
        ],
      );
      final detail = selected == null
          ? const SCard(child: Text('Toque em uma OS para acompanhar.'))
          : _OrderReadOnlyDetail(order: selected);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                'SOMENTE LEITURA · sincronizado com o GestaoOS Web',
                style: TextStyle(
                  color: SColors.amber,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 48, child: list),
                  const SizedBox(width: 26),
                  Expanded(flex: 52, child: detail),
                ],
              )
            else
              Column(children: [list, const SizedBox(height: 22), detail]),
          ],
        ),
      );
    },
  );
}

class _OrderReadOnlyDetail extends StatelessWidget {
  const _OrderReadOnlyDetail({required this.order});
  final WorkOrder order;
  @override
  Widget build(BuildContext context) {
    const timeline = [
      'Aberta',
      'Em análise',
      'Técnico atribuído',
      'Em execução',
      'Concluída',
    ];
    final lastIndex = order.status == 'Concluída'
        ? 4
        : order.status == 'Em andamento'
        ? 3
        : 0;
    return SCard(
      padding: const EdgeInsets.all(29),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SStatusPill(order.status),
              const Spacer(),
              Text(
                'OS ${order.protocol}',
                style: const TextStyle(
                  color: SColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            order.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              Text(
                '⌖ ${order.location}',
                style: const TextStyle(color: SColors.muted),
              ),
              Text(
                '⚒ ${order.type}',
                style: const TextStyle(color: SColors.muted),
              ),
              Text(
                '◷ ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: SColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            order.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF50557E),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Acompanhamento',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < timeline.length; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: i < lastIndex
                            ? SColors.green
                            : i == lastIndex
                            ? SColors.primary
                            : const Color(0xFFD6D9EB),
                        child: Icon(
                          i < lastIndex ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: i == lastIndex ? 9 : 15,
                        ),
                      ),
                      if (i < timeline.length - 1)
                        Container(
                          width: 2,
                          height: 51,
                          color: i < lastIndex ? SColors.green : SColors.border,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeline[i],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: i > lastIndex ? SColors.muted : SColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          i < order.history.length
                              ? order.history[i].detail
                              : i > lastIndex
                              ? 'Aguardando'
                              : 'Em andamento',
                          style: const TextStyle(
                            color: SColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          const Text(
            'O tablet permite apenas visualizar o andamento.',
            style: TextStyle(color: SColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
