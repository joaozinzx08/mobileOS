import 'package:flutter/material.dart';
import '../controller.dart';
import '../models/setorial_models.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class SetorialHome extends StatelessWidget {
  const SetorialHome({super.key, required this.controller});
  final SetorialController controller;

  static const _shortcuts = <(String, IconData)>[
    ('Elétrica', Icons.bolt_outlined),
    ('Hidráulica', Icons.water_drop_outlined),
    ('TI e rede', Icons.router_outlined),
    ('Mecânica', Icons.build_circle_outlined),
    ('Outros', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, box) {
          final landscapeTablet = box.maxWidth >= 930;
          final showOrders = controller.settings.showSectorOrders;
          final compact = box.maxWidth < 600;
          final pad = compact ? 16.0 : 24.0;
          final content = RefreshIndicator(
            onRefresh: controller.refreshOrders,
            color: SColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 20),
              children: [
                if (landscapeTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 52,
                        child: _HeroPanel(
                          controller: controller,
                          wide: true,
                          hideMainButton: false,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showOrders) ...[
                              _StatsSection(controller: controller),
                              const SizedBox(height: 20),
                              _RecentSection(controller: controller),
                            ] else
                              const _OrdersHiddenCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  _HeroPanel(
                    controller: controller,
                    wide: false,
                    hideMainButton: compact,
                  ),
                  const SizedBox(height: 20),
                  if (showOrders) ...[
                    _StatsSection(controller: controller),
                    const SizedBox(height: 20),
                    _RecentSection(controller: controller),
                  ] else
                    const _OrdersHiddenCard(),
                ],
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Precisa de ajuda?'),
                          content: const Text(
                            'Fale com a Manutenção no ramal 2210.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendi'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.help_outline, size: 19),
                      label: const Text('Dúvidas? Ramal 2210'),
                    ),
                    if (kModoDemo)
                      const Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: Icon(
                          Icons.science_outlined,
                          size: 17,
                          color: SColors.amber,
                        ),
                        label: Text(
                          'AMBIENTE DE DEMONSTRAÇÃO · sem envio ao servidor',
                          style: TextStyle(fontSize: 11, color: SColors.amber),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
          if (!compact) return content;
          return Column(
            children: [
              Expanded(child: content),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: _PrimaryAction(
                  onPressed: controller.startIdentification,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.controller,
    required this.wide,
    required this.hideMainButton,
  });
  final SetorialController controller;
  final bool wide;
  final bool hideMainButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(wide ? 32 : 24),
      decoration: BoxDecoration(
        gradient: SColors.gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [SColors.shadow],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -16,
            top: -14,
            child: IgnorePointer(
              child: Opacity(
                opacity: .09,
                child: Icon(
                  Icons.precision_manufacturing_outlined,
                  size: 190,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setor ${controller.settings.sector}',
                style: const TextStyle(color: Color(0xFFD0D7FF), fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Precisa de algum serviço no seu setor?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 34 : 29,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Registre o problema em poucos passos. A equipe responsável poderá acompanhar a solicitação.',
                style: TextStyle(
                  color: Color(0xFFE3E6FF),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),
              if (!hideMainButton) ...[
                _PrimaryAction(onPressed: controller.startIdentification),
                const SizedBox(height: 16),
              ],
              const Text(
                'COMO FUNCIONA',
                style: TextStyle(
                  color: Color(0xFFDBE1FF),
                  fontSize: 12,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _Step('1', 'Identifique-se'),
                  _Step('2', 'Descreva o problema'),
                  _Step('3', 'OS registrada'),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Atalhos de serviço',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in SetorialHome._shortcuts)
                    OutlinedButton.icon(
                      onPressed: () => controller.startWithType(item.$1),
                      icon: Icon(item.$2, size: 19),
                      label: Text(item.$1),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x99FFFFFF)),
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.label);
  final String number;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: const Color(0x44FFFFFF),
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ],
  );
}

class _PrimaryAction extends StatefulWidget {
  const _PrimaryAction({required this.onPressed});
  final VoidCallback onPressed;
  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _pressed ? .97 : 1,
    duration: const Duration(milliseconds: 120),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 5,
      shadowColor: SColors.dark.withValues(alpha: .25),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onHighlightChanged: (value) => setState(() => _pressed = value),
        onTap: widget.onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 76),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: SColors.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Abrir nova OS',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SColors.primary,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.controller});
  final SetorialController controller;
  @override
  Widget build(BuildContext context) {
    final orders = controller.orders;
    final data = [
      ('Abertas', 'Aberta', Icons.pending_actions_outlined, SColors.blue),
      (
        'Em andamento',
        'Em andamento',
        Icons.build_circle_outlined,
        SColors.amber,
      ),
      ('Concluídas', 'Concluída', Icons.task_alt_outlined, SColors.green),
    ];
    return SCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OS do setor hoje',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 350;
              final cards = [
                for (final item in data)
                  _StatCard(
                    label: item.$1,
                    count: orders.where((o) => o.status == item.$2).length,
                    icon: item.$3,
                    color: item.$4,
                    onTap: () => controller.openOrdersFiltered(
                      item.$2 == 'Aberta'
                          ? 'Abertas'
                          : item.$2 == 'Concluída'
                          ? 'Concluídas'
                          : 'Andamento',
                    ),
                  ),
              ];
              if (narrow) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: SColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: count.toDouble()),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Text(
                '${value.round()}',
                style: TextStyle(
                  color: color,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.controller});
  final SetorialController controller;
  @override
  Widget build(BuildContext context) => SCard(
    padding: const EdgeInsets.all(22),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Últimas ordens',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        if (controller.isLoadingOrders && controller.orders.isEmpty)
          for (var i = 0; i < 2; i++) ...[
            const _SkeletonCard(),
            const SizedBox(height: 12),
          ]
        else if (controller.orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 26),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, color: SColors.primary, size: 52),
                SizedBox(height: 12),
                Text('Nenhuma OS registrada hoje.'),
                Text(
                  'Quando surgir uma solicitação, ela aparecerá aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SColors.muted),
                ),
              ],
            ),
          )
        else
          for (final o in controller.orders.take(2)) ...[
            _OsCard(
              order: o,
              sector: controller.settings.sector,
              onTap: () => controller.openOrder(o),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 4),
        SOutlineButton(
          'Ver todas as OS do setor',
          icon: Icons.assignment_outlined,
          onPressed: () => controller.openOrdersFiltered('Todas'),
          height: 60,
        ),
      ],
    ),
  );
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Opacity(
      opacity: MediaQuery.disableAnimationsOf(context)
          ? .55
          : .3 + _controller.value * .4,
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: SColors.border,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}

class _OsCard extends StatelessWidget {
  const _OsCard({
    required this.order,
    required this.sector,
    required this.onTap,
  });
  final WorkOrder order;
  final String sector;
  final VoidCallback onTap;

  IconData get categoryIcon {
    final category = order.type.toLowerCase();
    if (category.contains('ti') || category.contains('rede')) {
      return Icons.router_outlined;
    }
    if (category.contains('hidrául')) return Icons.water_drop_outlined;
    if (category.contains('elétr')) return Icons.bolt_outlined;
    if (category.contains('limpeza')) return Icons.cleaning_services_outlined;
    return Icons.build_outlined;
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: SColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SColors.soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon, color: SColors.primary, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'OS ${order.protocol}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        _relativeTime(order.createdAt),
                        style: const TextStyle(
                          color: SColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$sector · ${order.location}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: SColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _PriorityChip(order.priority),
                      SStatusPill(order.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip(this.priority);
  final String priority;
  @override
  Widget build(BuildContext context) {
    final color = priority == 'Urgente' || priority == 'Alta'
        ? SColors.red
        : priority == 'Média'
        ? SColors.amber
        : SColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.isNegative || diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  return 'há ${diff.inDays} d';
}

/// A opção administrativa oculta o painel sem afetar a abertura de OS.
class _OrdersHiddenCard extends StatelessWidget {
  const _OrdersHiddenCard();

  @override
  Widget build(BuildContext context) => SCard(
    padding: const EdgeInsets.all(22),
    child: Row(
      children: [
        const Icon(
          Icons.visibility_off_outlined,
          color: SColors.muted,
          size: 28,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'A consulta de OS do setor está desativada neste tablet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
