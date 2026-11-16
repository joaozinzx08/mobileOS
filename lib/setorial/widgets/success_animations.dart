import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Check de sucesso sem imagens, Lottie ou dependências adicionais.
/// Usa um único controller para círculo, halo e traço.
class AnimatedSuccessCheck extends StatefulWidget {
  const AnimatedSuccessCheck({
    super.key,
    this.size = 100,
    this.color = const Color(0xFF16A34A),
    this.haloColor = const Color(0xFFEAFBF1),
    this.duration = const Duration(milliseconds: 1500),
    this.onCompleted,
  });

  final double size;
  final Color color;
  final Color haloColor;
  final Duration duration;
  final VoidCallback? onCompleted;

  @override
  State<AnimatedSuccessCheck> createState() => _AnimatedSuccessCheckState();
}

class _AnimatedSuccessCheckState extends State<AnimatedSuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _finished = false;
  bool _hapticSent = false;
  bool _started = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_handleTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _reducedMotion = reduceMotion;
    if (reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
    } else if (!_started && !_finished) {
      _started = true;
      _controller.forward().then((_) => _complete());
    }
  }

  void _handleTick() {
    // A marca se completa nos primeiros 1000 ms de 1500 ms.
    if (!_hapticSent && _controller.value >= 2 / 3) {
      _hapticSent = true;
      if (!_reducedMotion) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _complete() {
    if (!mounted || _finished) return;
    _finished = true;
    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Ordem de serviço enviada com sucesso',
      image: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = reduceMotion ? 1.0 : _controller.value;
          final circle = Curves.elasticOut.transform(
            const Interval(0, 1 / 3).transform(t),
          );
          final haloAppear = Curves.easeOut.transform(
            const Interval(2 / 15, 7 / 15).transform(t),
          );
          final pulse = const Interval(7 / 15, 10 / 15).transform(t);
          final pulseAmount = pulse > 0 && pulse < 1
              ? 0.065 * (1 - (2 * pulse - 1).abs())
              : 0.0;
          final haloScale = 0.6 + 0.4 * haloAppear + pulseAmount;
          final check = Curves.easeOutCubic.transform(
            const Interval(1 / 3, 2 / 3).transform(t),
          );
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: haloAppear,
                  child: Transform.scale(
                    scale: haloScale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.haloColor,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: circle.clamp(0.0, 1.25),
                  child: Container(
                    width: widget.size * 0.68,
                    height: widget.size * 0.68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(widget.size * 0.16),
                      child: CustomPaint(painter: _CheckPainter(check)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.10, size.height * 0.51)
      ..lineTo(size.width * 0.39, size.height * 0.79)
      ..lineTo(size.width * 0.91, size.height * 0.20);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0)),
      Paint()
        ..color = Colors.white
        ..strokeWidth = size.width * 0.11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Aparece progressivamente após [delay], com fade e deslocamento suave.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.delay,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
  });

  final Duration delay;
  final Duration duration;
  final Widget child;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.delay + widget.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final totalMicros = (widget.delay + widget.duration).inMicroseconds;
    if (totalMicros <= 0) return widget.child;
    final start = widget.delay.inMicroseconds / totalMicros;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start.clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.07),
          end: Offset.zero,
        ).animate(animation),
        child: widget.child,
      ),
    );
  }
}
