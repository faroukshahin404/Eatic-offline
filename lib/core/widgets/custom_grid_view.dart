import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Generic grid view that lays out items in a responsive wrap: card width is capped by
/// [maxCardWidth], and the number of columns grows with available width.
///
/// Use [itemBuilder] to build a widget for each item of type [T]. Works with any model type.
/// Optional [selectedItem] and [onSelectionChanged] enable radio-style single selection.
class CustomGridView<T> extends StatelessWidget {
  const CustomGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.horizontalPadding = 16.0,
    this.spacing = 8.0,
    this.maxCardWidth = 280.0,
    this.minCrossAxisCount = 2,
    this.maxCrossAxisCount = 8,
    this.scrollPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.scrollable = true,
    this.selectedItem,
    this.onSelectionChanged,
    this.itemEquals,
  });

  /// List of items to display (any type).
  final List<T> items;

  /// Builds the widget for each item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Horizontal padding included in width calculation.
  final double horizontalPadding;

  /// Spacing between items (horizontal and vertical).
  final double spacing;

  /// Maximum width per item; column count increases so items do not exceed this.
  final double maxCardWidth;

  /// Minimum number of columns.
  final int minCrossAxisCount;

  /// Maximum number of columns.
  final int maxCrossAxisCount;

  /// Padding around the scroll content.
  final EdgeInsets scrollPadding;

  /// When true, wraps content in [SingleChildScrollView]. Set to false when grid is inside another scrollable (e.g. ListView).
  final bool scrollable;

  /// Currently selected item; used with [onSelectionChanged] to show radio/selection state.
  final T? selectedItem;

  /// Called when user selects an item. When set, each item is tappable and shows selection indicator.
  final void Function(T? item)? onSelectionChanged;

  /// Optional equality for [T]. Defaults to reference equality ([identical]).
  final bool Function(T a, T b)? itemEquals;

  bool _isSelected(T a, T b) => itemEquals != null ? itemEquals!(a, b) : identical(a, b);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = ((width - horizontalPadding + spacing) /
                    (maxCardWidth + spacing))
                .ceil()
                .clamp(minCrossAxisCount, maxCrossAxisCount);
        final itemWidth = (width -
                horizontalPadding -
                (crossAxisCount - 1) * spacing) /
            crossAxisCount;

        final gridContent = Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < items.length; i++) _buildGridItem(context, items[i], itemWidth, i),
          ],
        );

        if (scrollable) {
          return SingleChildScrollView(
            padding: scrollPadding,
            child: gridContent,
          );
        }
        return Padding(
          padding: scrollPadding,
          child: gridContent,
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, T item, double itemWidth, int index) {
    final content = SizedBox(
      width: itemWidth,
      child: itemBuilder(context, item),
    );

    if (onSelectionChanged == null) {
      return content;
    }

    final isSelected = selectedItem != null && _isSelected(selectedItem as T, item);

    return SizedBox(
      width: itemWidth,
      child: InkWell(
        onTap: () => onSelectionChanged!(isSelected ? null : item),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: content,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.greyA4ACAD,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
