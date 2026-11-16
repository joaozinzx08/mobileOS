import 'package:flutter/material.dart';
import '../services/clock_service.dart';
import '../controller.dart';
import '../models/setorial_models.dart';
import '../theme.dart';

class SCard extends StatelessWidget {
  const SCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.color = Colors.white,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(29),
      boxShadow: const [SColors.shadow],
    ),
    child: child,
  );
}

class SPrimaryButton extends StatelessWidget {
  const SPrimaryButton(
    this.text, {
    super.key,
    required this.onPressed,
    this.icon,
    this.height = 66,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? .48 : 1,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: SColors.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [SColors.shadow],
          ),
          child: SizedBox(
            height: height,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 25, color: Colors.white),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
    ),
  );
}

class SOutlineButton extends StatelessWidget {
  const SOutlineButton(
    this.text, {
    super.key,
    required this.onPressed,
    this.icon,
    this.height = 66,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: SColors.primary,
        side: const BorderSide(color: SColors.border, width: 1.2),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 22),
      label: Text(
        text,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class STopBar extends StatelessWidget {
  const STopBar({
    super.key,
    required this.controller,
    this.title,
    this.onBack,
    this.onAdmin,
  });
  final SetorialController controller;
  final String? title;
  final VoidCallback? onBack, onAdmin;
  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: LayoutBuilder(
      builder: (_, c) {
        final compact = c.maxWidth < 730;
        final sector = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF0FB),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: SColors.primary,
                size: 22,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  '${controller.settings.sector} · ${controller.settings.location.split(' · ').first}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
        final heading = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onBack != null) ...[
              SOutlineButton(
                'Voltar',
                icon: Icons.chevron_left,
                onPressed: onBack,
                height: 54,
              ),
              const SizedBox(width: 12),
            ] else ...[
              SizedBox(
                width: 56,
                height: 56,
                child: Image.asset(
                  'assets/images/gestaoos_logo.png',
                  fit: BoxFit.contain,
                  semanticLabel: 'Logo GestaoOS',
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                title ?? 'GestaoOS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: SColors.ink,
                ),
              ),
            ),
          ],
        );
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 34,
            vertical: 14,
          ),
          child: compact
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: heading),
                        const SLiveClock(),
                        if (onAdmin != null) ...[
                          const SizedBox(width: 28),
                          IconButton(
                            tooltip: 'Configurações do tablet',
                            onPressed: onAdmin,
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: SColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(child: sector),
                        const Spacer(),
                        Text(
                          controller.isDemo
                              ? '● Demonstração'
                              : '${controller.settings.deviceName} · Online',
                          style: const TextStyle(
                            color: SColors.amber,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 4, child: heading),
                    Expanded(
                      flex: 3,
                      child: Align(alignment: Alignment.center, child: sector),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SLiveClock(showDate: true),
                          if (onAdmin != null) ...[
                            const SizedBox(width: 32),
                            IconButton(
                              tooltip: 'Configurações do tablet',
                              onPressed: onAdmin,
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: SColors.primary,
                                size: 28,
                              ),
                            ),
                          ],
                          const SizedBox(width: 26),
                          Flexible(
                            child: Text(
                              controller.isDemo
                                  ? '${controller.settings.deviceName} · DEMO'
                                  : '${controller.settings.deviceName} · Online',
                              style: TextStyle(
                                fontSize: 14,
                                color: controller.isDemo
                                    ? SColors.amber
                                    : SColors.green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    ),
  );
}

/// Relógio conectado ao horário de São Paulo.
/// Cada instância é liberada ao sair da tela.
class SLiveClock extends StatefulWidget {
  const SLiveClock({super.key, this.showDate = false});
  final bool showDate;

  @override
  State<SLiveClock> createState() => _SLiveClockState();
}

class _SLiveClockState extends State<SLiveClock> with WidgetsBindingObserver {
  final ClockService _clock = ClockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock.iniciar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clock.sincronizar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _clock,
      builder: (context, _) {
        final time = _clock.horarioFormatado;
        final text = Text(
          time,
          maxLines: 1,
          style: TextStyle(
            fontSize: widget.showDate ? 21 : 19,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
        if (!widget.showDate) {
          return Semantics(label: 'Horário de São Paulo: $time', child: text);
        }
        return Semantics(
          label: 'Horário de São Paulo: $time',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              text,
              Text(
                _clock.dataFormatada,
                style: const TextStyle(color: SColors.muted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SProgress extends StatelessWidget {
  const SProgress({super.key, required this.step});
  final int step;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      for (var i = 1; i <= 3; i++)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: i <= step
                  ? SColors.primary
                  : const Color(0xFFE3E6F5),
              child: i < step
                  ? const Icon(Icons.check, color: Colors.white, size: 19)
                  : Text(
                      '$i',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: i == step ? Colors.white : SColors.muted,
                      ),
                    ),
            ),
            const SizedBox(width: 9),
            Text(
              ['Tipo de serviço', 'Detalhes', 'Confirmação'][i - 1],
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: i <= step ? SColors.ink : SColors.muted,
              ),
            ),
            if (i != 3)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: SizedBox(
                  width: 42,
                  child: Divider(color: SColors.border, thickness: 2),
                ),
              ),
          ],
        ),
    ],
  );
}

class SFooter extends StatelessWidget {
  const SFooter({
    super.key,
    required this.controller,
    required this.secondary,
    required this.onSecondary,
    required this.primary,
    required this.onPrimary,
  });
  final SetorialController controller;
  final String secondary, primary;
  final VoidCallback onSecondary;
  final VoidCallback? onPrimary;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 14),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (_, c) => c.maxWidth >= 1000
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF5665E8),
                    child: Text(
                      _initials(controller.draft.applicant?.name ?? ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.draft.applicant?.name ?? 'Colaborador',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Matrícula ${controller.draft.applicant?.registration ?? ''} · ${controller.settings.sector}',
                        style: const TextStyle(
                          color: SColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 170,
                    child: SOutlineButton(secondary, onPressed: onSecondary),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 300,
                    child: SPrimaryButton(
                      primary,
                      onPressed: onPrimary,
                      icon: Icons.arrow_forward_ios,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.draft.applicant?.name ?? 'Colaborador',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SOutlineButton(
                          secondary,
                          onPressed: onSecondary,
                          height: 56,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SPrimaryButton(
                          primary,
                          onPressed: onPrimary,
                          height: 56,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    ),
  );
}

String _initials(String name) => name.trim().isEmpty
    ? 'OS'
    : name
          .trim()
          .split(' ')
          .take(2)
          .map((s) => s.substring(0, 1).toUpperCase())
          .join();

class SStatusPill extends StatelessWidget {
  const SStatusPill(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final progress = status.toLowerCase().contains('andamento');
    final completed = status.toLowerCase().contains('conclu');
    final color = progress
        ? const Color(0xFF9A5900)
        : completed
        ? SColors.green
        : const Color(0xFF2759E2);
    final bg = progress
        ? const Color(0xFFFFF2D8)
        : completed
        ? const Color(0xFFE2F7EB)
        : const Color(0xFFE6ECFF);
    final icon = progress
        ? Icons.autorenew
        : completed
        ? Icons.check_circle_outline
        : Icons.schedule;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SOrderTile extends StatelessWidget {
  const SOrderTile(this.order, {super.key, this.onTap, this.height = 112});
  final WorkOrder order;
  final VoidCallback? onTap;
  final double height; // Mantido para compatibilidade; altura agora é dinâmica.

  @override
  Widget build(BuildContext context) {
    final color = order.status == 'Em andamento'
        ? SColors.amber
        : order.status == 'Concluída'
        ? SColors.green
        : SColors.blue;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 75,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OS ${order.protocol}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SColors.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
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
                    const SizedBox(height: 7),
                    Text(
                      '${order.type} · ${order.location}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 7,
                      children: [
                        SStatusPill(order.status),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: SColors.soft,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flag_outlined,
                                size: 13,
                                color: SColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.priority,
                                style: const TextStyle(
                                  color: SColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
