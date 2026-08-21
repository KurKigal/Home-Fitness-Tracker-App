import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class NeumorphicStyle {
  static List<BoxShadow> raisedShadows(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        BoxShadow(
          color: AppColors.darkShadow,
          offset: Offset(6, 6),
          blurRadius: 14,
        ),
        BoxShadow(
          color: AppColors.darkHighlight,
          offset: Offset(-4, -4),
          blurRadius: 12,
        ),
      ];
    }

    return const [
      BoxShadow(
        color: AppColors.lightShadow,
        offset: Offset(6, 6),
        blurRadius: 14,
      ),
      BoxShadow(
        color: AppColors.lightHighlight,
        offset: Offset(-6, -6),
        blurRadius: 14,
      ),
    ];
  }
}
