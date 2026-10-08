import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_helpers.dart';

/// The two moments worth celebrating.
enum GoalCelebrationKind {
  /// Reserved money just reached the price.
  funded,

  /// The goal was marked bought.
  completed,
}

/// Shows the celebration for [goal] — but only the FIRST time each moment
/// happens for that goal. Undoing a purchase and buying again, or a price
/// update that makes the goal fully funded, never repeats it.
///
/// Returns true when it was shown, so the caller can skip its usual
/// snackbar instead of saying the same thing twice.
Future<bool> showGoalCelebration(
  BuildContext context, {
  required Goal goal,
  required GoalCelebrationKind kind,
  required String title,
  required List<String> lines,
  required String primaryLabel,
  VoidCallback? onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
}) async {
  final key = 'goal_celebrated_${kind.name}_${goal.id}';
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(key) ?? false) return false;
    await prefs.setBool(key, true);
  } catch (_) {
    // If the flag can't be stored, celebrating once more is harmless.
  }
  if (!context.mounted) return false;

  // Which button was tapped; the action runs AFTER the dialog has closed so
  // it can open its own dialog on the screen underneath.
  final choice = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.close,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => _CelebrationView(
      kind: kind,
      title: title,
      lines: lines,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
    ),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
    ),
  );

  if (choice == 'primary') onPrimary?.call();
  if (choice == 'secondary') onSecondary?.call();
  return true;
}

class _CelebrationView extends StatefulWidget {
  final GoalCelebrationKind kind;
  final String title;
  final List<String> lines;
  final String primaryLabel;
  final String? secondaryLabel;

  const _CelebrationView({
    required this.kind,
    required this.title,
    required this.lines,
    required this.primaryLabel,
    this.secondaryLabel,
  });

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confetti;
  late final List<_Piece> _pieces;
  Timer? _autoClose;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    const colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.accentDark,
      Colors.white,
    ];
    _pieces = List.generate(
      70,
      (_) => _Piece(
        x: rnd.nextDouble(),
        delay: rnd.nextDouble() * 0.35,
        speed: 0.7 + rnd.nextDouble() * 0.6,
        drift: (rnd.nextDouble() - 0.5) * 0.25,
        spin: (rnd.nextDouble() - 0.5) * 12,
        size: 6 + rnd.nextDouble() * 6,
        color: colors[rnd.nextInt(colors.length)],
      ),
    );
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();

    // Short and out of the way: closes itself if left alone.
    _autoClose = Timer(const Duration(seconds: 8), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final funded = widget.kind == GoalCelebrationKind.funded;

    return Stack(
      children: [
        // Confetti falls behind the card, across the whole screen.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_pieces, _confetti.value),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        funded ? Icons.celebration : Icons.emoji_events,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.lines.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            l,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        )),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop('primary'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(widget.primaryLabel),
                      ),
                    ),
                    if (widget.secondaryLabel != null)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop('secondary'),
                        child: Text(widget.secondaryLabel!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Piece {
  final double x, delay, speed, drift, spin, size;
  final Color color;

  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
  });
}

/// Simple falling, spinning paper squares — drawn by the app itself, so no
/// extra package (and no extra download size) is needed.
class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;

  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -20 + local * p.speed * (size.height + 40);
      final x = (p.x + p.drift * local) * size.width;
      // Fade out over the last part of the fall.
      final opacity = local > 0.8 ? (1 - local) / 0.2 : 1.0;
      paint.color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * local);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
