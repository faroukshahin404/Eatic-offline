import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ActionIcon extends StatelessWidget {
  const ActionIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 22, color: AppColors.primary),
        style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
      ),
    );
  }
}
