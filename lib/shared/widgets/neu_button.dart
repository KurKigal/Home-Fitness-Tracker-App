import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_style.dart';

enum NeuButtonStyle { primary, secondary, danger }

class NeuButton extends StatefulWidget {
  const NeuButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.style = NeuButtonStyle.secondary,
    this.isExpanded = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NeuButtonStyle style;
  final bool isExpanded;

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final enabled = widget.onPressed != null;

    final baseSurface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final foregroundColor = switch (widget.style) {
      NeuButtonStyle.primary => Colors.white,
      NeuButtonStyle.secondary =>
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
      NeuButtonStyle.danger => AppColors.danger,
    };

    final backgroundColor = switch (widget.style) {
      NeuButtonStyle.primary => AppColors.primary,
      NeuButtonStyle.secondary => baseSurface,
      NeuButtonStyle.danger => baseSurface,
    };

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _pressed || !enabled
            ? const []
            : NeumorphicStyle.raisedShadows(brightness),
      ),
      transform: Matrix4.translationValues(0, _pressed ? 1.5 : 0, 0),
      child: Row(
        mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 20,
              color: foregroundColor.withValues(alpha: enabled ? 1 : 0.4),
            ),
            const SizedBox(width: 9),
          ],
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: foregroundColor.withValues(alpha: enabled ? 1 : 0.4),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) {
              setState(() {
                _pressed = true;
              });
            }
          : null,
      onTapCancel: enabled
          ? () {
              setState(() {
                _pressed = false;
              });
            }
          : null,
      onTapUp: enabled
          ? (_) {
              setState(() {
                _pressed = false;
              });

              widget.onPressed?.call();
            }
          : null,
      child: content,
    );
  }
}
