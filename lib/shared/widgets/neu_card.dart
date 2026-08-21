import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_style.dart';

class NeuCard extends StatelessWidget {
  const NeuCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final surfaceColor = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: NeumorphicStyle.raisedShadows(brightness),
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
