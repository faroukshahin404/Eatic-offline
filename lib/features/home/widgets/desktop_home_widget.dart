import 'package:flutter/material.dart';

import 'home_widgets/home_content_widget.dart';

class DesktopHomeWidget extends StatelessWidget {
  const DesktopHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: HomeContentWidget(),
    );
  }
}