import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_fonts.dart';
import '../../core/services/flutter_secure_storage.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../users/session_user_holder.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/custom_text.dart';
import '../../routes/app_paths.dart';
import 'widgets/list_of_settings_widget.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  final List<String> settings = [
    "users",
    "branches",
    "delivery-men",
    "zones",
    "currencies",
    "payment-methods",
    "dining-areas",
    "restaurant-tables",
    "categories",
    "addons",
    "price-lists",
    "products",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "settings"),
      body: CustomPadding(
        child: Column(
          children: [
            Expanded(child: ListOfSettings(settings: settings)),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 255, 78, 75),
                ),
              ),
              onPressed: () async {
                SessionUserHolder.clear();
                await SecureLocalStorageService.deleteAllSecureData();
                if (context.mounted) context.go(AppPaths.splash);
              },
              child: CustomText(
                text: 'logout',
                style: AppFonts.styleBold20.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
