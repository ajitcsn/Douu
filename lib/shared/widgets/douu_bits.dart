import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Small reusable presentational widgets: avatar, RAG dot, frequency pill,
/// streak chip. All purely derived from props (no business logic).

class DouuAvatar extends StatelessWidget {
  const DouuAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class RagDot extends StatelessWidget {
  const RagDot({super.key, required this.rag, this.size = 10});

  final String rag;
  final double size;

  static String label(String rag) {
    switch (rag) {
      case 'green':
        return 'Healthy';
      case 'amber':
        return 'Slipping';
      case 'red':
        return 'Neglected';
      default:
        return 'New';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DouuTheme.ragColor(rag),
        shape: BoxShape.circle,
      ),
    );
  }
}

class FrequencyPill extends StatelessWidget {
  const FrequencyPill({super.key, required this.frequencyDays, this.onTap});

  final int frequencyDays;
  final VoidCallback? onTap;

  static String labelFor(int days) {
    if (days == 1) return 'Daily';
    if (days == 5) return 'Weekdays';
    if (days == 7) return 'Weekly';
    if (days == 14) return 'Biweekly';
    if (days == 30) return 'Monthly';
    return 'Every $days days';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_outlined, size: 14),
          const SizedBox(width: 4),
          Text(labelFor(frequencyDays),
              style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
    return onTap == null
        ? pill
        : InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: pill);
  }
}

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥'),
        const SizedBox(width: 2),
        Text('${days}d', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

/// Subtle repeating dot-grid texture painted behind screen content.
/// Uses Stack + Positioned.fill so the CustomPaint layer is fully separate
/// from the child's layout tree (avoids the parentDataDirty assertion that
/// occurs when CustomPaint.painter + a scrollable child share the same node).
class DotBackground extends StatelessWidget {
  const DotBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dotColor = Theme.of(context).colorScheme.onSurface.withAlpha(14);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _DotPainter(dotColor: dotColor)),
        ),
        child,
      ],
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter({required this.dotColor});
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const spacing = 22.0;
    const radius = 1.4;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.dotColor != dotColor;
}

// Curated pastel palette shared by community cards (hub) and quest rows, so
// a contact's color always matches their community's card color.
const groupPastelPalette = [
  Color(0xFFFFD6E0), // rose
  Color(0xFFC8E6C9), // mint
  Color(0xFFE1BEE7), // lavender
  Color(0xFFFFE0B2), // peach
  Color(0xFFB3E5FC), // sky
  Color(0xFFF8BBD0), // pink
  Color(0xFFB2EBF2), // teal
  Color(0xFFFFF9C4), // lemon
];

const groupPastelBorders = [
  Color(0xFFFFADB9),
  Color(0xFFA5D6A7),
  Color(0xFFCE93D8),
  Color(0xFFFFCC80),
  Color(0xFF81D4FA),
  Color(0xFFF48FB1),
  Color(0xFF80DEEA),
  Color(0xFFFFF176),
];

Color groupCardColor(int groupId) =>
    groupPastelPalette[groupId % groupPastelPalette.length];

Color groupBorderColor(int groupId) =>
    groupPastelBorders[groupId % groupPastelBorders.length];

/// Relative "today / 7d ago / never" used in member rows (S10).
String relativeLastReached(int? lastReachedAtMs, {DateTime? now}) {
  if (lastReachedAtMs == null) return 'never';
  final n = now ?? DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(lastReachedAtMs, isUtc: true)
      .toLocal();
  final days = DateTime(n.year, n.month, n.day)
      .difference(DateTime(then.year, then.month, then.day))
      .inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'yesterday';
  return '${days}d ago';
}
