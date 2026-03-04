import 'package:flutter/material.dart';

/// Wraps [child] with [MouseRegion] and an optional hover overlay so desktop
/// mouse and hover feel consistent. Use for list tiles, cards, or any clickable area.
class HoverOverlay extends StatefulWidget {
  const HoverOverlay({
    super.key,
    required this.child,
    this.onTap,
    this.hoverColor,
    this.cursor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;
  final MouseCursor? cursor;

  @override
  State<HoverOverlay> createState() => _HoverOverlayState();
}

class _HoverOverlayState extends State<HoverOverlay> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.hoverColor ?? Colors.white.withValues(alpha: 0.06);
    final cursor = widget.cursor ??
        (widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic);

    return MouseRegion(
      cursor: cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            widget.child,
            if (_isHovered && widget.onTap != null)
              Positioned.fill(child: Container(color: color)),
          ],
        ),
      ),
    );
  }
}
