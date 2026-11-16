import 'package:flutter/material.dart';
import '../controller.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import '../widgets/success_animations.dart';

class SetorialConfirmation extends StatefulWidget {
  const SetorialConfirmation({super.key, required this.controller});
  final SetorialController controller;

  @override
  State<SetorialConfirmation> createState() => _SetorialConfirmationState();
}

class _SetorialConfirmationState extends State<SetorialConfirmation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );
  bool _countdownStarted = false;

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (!mounted || _countdownStarted) return;
    _countdownStarted = true;
    widget.controller.startConfirmationCountdown();
    _progressController.forward();
  }

  void _exit(VoidCallback destination) {
    // Navegar pelo controller cancela o Timer.periodic da confirmação.
    _progressController.stop();
    destination();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.controller.createdOrder;
    if (order == null) {
      return Center(
        child: SPrimaryButton(
          'Voltar ao início',
          onPressed: widget.controller.backHome,
        ),
      );
    }

    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 1500);

    Widget enter(int index, Widget child) => FadeSlideIn(
      delay: reducedMotion
          ? Duration.zero
          : Duration(milliseconds: 900 + 80 * index),
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 280),
      child: child,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                const SizedBox(height: 10),
                AnimatedSuccessCheck(
                  size: 126,
                  duration: duration,
                  color: SColors.green,
                  onCompleted: _startCountdown,
                ),
                const SizedBox(height: 16),
                enter(
                  0,
                  const Text(
                    'OS enviada com sucesso!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 8),
                enter(
                  1,
                  const Text(
                    'Demonstração: solicitação criada somente neste aplicativo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: SColors.muted),
                  ),
                ),
                const SizedBox(height: 18),
                enter(
                  2,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF0FC),
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: Text(
                      'Protocolo ${order.protocol}',
                      style: const TextStyle(
                        color: SColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                enter(
                  3,
                  SCard(
                    color: SColors.soft,
                    child: Column(
                      children: [
                        _detail('Tipo', order.type),
                        _detail('Local', order.location),
                        _detail('Prioridade', order.priority),
                        _detail('Prazo estimado', 'A definir pelo gestor'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                enter(
                  4,
                  LayoutBuilder(
                    builder: (context, box) {
                      if (box.maxWidth < 450) {
                        return Column(
                          children: [
                            SOutlineButton(
                              'Abrir outra OS',
                              onPressed: () =>
                                  _exit(widget.controller.startIdentification),
                            ),
                            const SizedBox(height: 12),
                            SPrimaryButton(
                              'Concluir',
                              onPressed: () =>
                                  _exit(widget.controller.backHome),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: SOutlineButton(
                              'Abrir outra OS',
                              onPressed: () =>
                                  _exit(widget.controller.startIdentification),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SPrimaryButton(
                              'Concluir',
                              onPressed: () =>
                                  _exit(widget.controller.backHome),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                // Apenas o controller atualiza o contador, evitando timers duplicados.
                Text(
                  'Voltando ao início em ${widget.controller.confirmationRemaining} s',
                  style: const TextStyle(color: SColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) => LinearProgressIndicator(
                      minHeight: 5,
                      value: (1 - _progressController.value).clamp(0.0, 1.0),
                      color: SColors.primary,
                      backgroundColor: SColors.border,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: SColors.muted, fontSize: 16),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
