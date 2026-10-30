import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../app/ui/primary_button.dart';
import '../../../../app/ui/streak_badge.dart';

class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.headline,
    required this.subline,
    required this.streak,
    required this.progress,
    required this.progressLabel,
    required this.onContinue,
  });

  final String headline;
  final String subline;
  final int streak;
  final double progress;
  final String progressLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Material(
      color: context.blue,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: _Confetti(animate: !reduced),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 150,
                          color: context.sun.withValues(alpha: 0.55),
                        ),
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 56,
                            color: context.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your progress',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: context.ink),
                              ),
                            ),
                            Text(
                              progressLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0, 1),
                            minHeight: 8,
                            color: context.blue,
                            backgroundColor: context.line,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: StreakBadge(streak: streak),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Keep going',
                    sun: true,
                    onPressed: onContinue,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: onContinue,
                    child: Text(
                      'BACK TO JOURNEY',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Confetti extends StatelessWidget {
  const _Confetti({required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: animate ? AppDurations.celebration : Duration.zero,
      curve: Curves.easeOut,
      builder: (context, value, child) => CustomPaint(
        painter: _ConfettiPainter(value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    const colors = [AppColors.blue, AppColors.sky, AppColors.sun, AppColors.white];

    for (var index = 0; index < 30; index++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.72;
      final color = colors[random.nextInt(colors.length)];
      final paint = Paint()
        ..color = color.withValues(alpha: 0.85 * progress);
      final width = 4 + random.nextDouble() * 4;
      final height = 8 + random.nextDouble() * 8;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi);
      if (index.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: width,
              height: height,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, width / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
