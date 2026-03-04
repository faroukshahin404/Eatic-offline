import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/services/flutter_secure_storage.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/custom_text.dart';
import '../../routes/app_paths.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "settings"),
      body: CustomPadding(
        child: Column(
          children: [
            ListOfSettings(settings: settings),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 255, 78, 75),
                ),
              ),
              onPressed: () async {
                SecureLocalStorageService.deleteAllSecureData();

                context.go(AppPaths.splash);
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
        return InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            context.push("/${settings[index]}");
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: settings[index].tr(),
                    maxLines: 1,
                    style: AppFonts.styleBold20,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}
