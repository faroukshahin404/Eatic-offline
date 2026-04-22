import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';

class ListOfSettings extends StatelessWidget {
  const ListOfSettings({super.key, required this.settings});

  final List<String> settings;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: settings.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return SettingsTile(
          label: settings[index].tr(),
          icon: _resolveSettingIcon(settings[index]),
          onTap: () {
            context.push("/${settings[index]}");
          },
        );
      },
    );
  }

  IconData _resolveSettingIcon(String key) {
    switch (key) {
      case "general-settings":
        return Icons.tune_rounded;
      case "users":
        return Icons.group_outlined;
      case "branches":
        return Icons.store_mall_directory_outlined;
      case "delivery-men":
        return Icons.delivery_dining_outlined;
      case "zones":
        return Icons.map_outlined;
      case "currencies":
        return Icons.currency_exchange_outlined;
      case "payment-methods":
        return Icons.payments_outlined;
      case "dining-areas":
        return Icons.dining_outlined;
      case "restaurant-tables":
        return Icons.table_restaurant_outlined;
      case "categories":
        return Icons.category_outlined;
      case "addons":
        return Icons.add_circle_outline_rounded;
      case "price-lists":
        return Icons.receipt_long_outlined;
      case "products":
        return Icons.inventory_2_outlined;
      default:
        return Icons.settings_outlined;
    }
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.textColor = Colors.black87,
    this.trailingColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: CustomText(
            text: label,
            maxLines: 1,
            style: AppFonts.styleBold20.copyWith(color: textColor),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: trailingColor ?? AppColors.primary.withOpacity(0.85),
            size: 18,
          ),
        ),
      ),
    );
  }
}
