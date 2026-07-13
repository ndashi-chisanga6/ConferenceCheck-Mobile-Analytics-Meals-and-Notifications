import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: primary),
            ),
            const Spacer(),
            _CountUpText(
              value: value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animates numeric values counting up from zero; non-numeric values
/// render statically. A numeric suffix (e.g. "%") is preserved.
class _CountUpText extends StatelessWidget {
  const _CountUpText({required this.value, this.style});

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^(\d+(?:\.\d+)?)(.*)$').firstMatch(value);
    if (match == null) {
      return Text(value, style: style);
    }
    final target = double.parse(match.group(1)!);
    final suffix = match.group(2)!;
    final isWhole = target % 1 == 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(
        (isWhole ? animated.round().toString() : animated.toStringAsFixed(1)) +
            suffix,
        style: style,
      ),
    );
  }
}
