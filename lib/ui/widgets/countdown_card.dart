import 'package:flutter/material.dart';

import 'widgets.dart';

/// Hero countdown — big Space Grotesk numeral on a tinted gradient panel.
/// Bento hero: full-width, softly floating with a subtle 3D numeral.
class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key, required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final days = daysLeft < 0 ? 0 : daysLeft;
    return Reveal(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.primary.withValues(alpha: 0.82)],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.32),
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEET 2027',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exam date is configurable in Settings.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      days == 1 ? '1 DAY TO GO' : '$days DAYS TO GO',
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.1,
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$days',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimary,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: scheme.primary.withValues(alpha: 0.45),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
