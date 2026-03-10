import 'package:flutter/material.dart';

import 'home_widgets/home_content_widget.dart';

class TabletHomeWidget extends StatelessWidget {
  const TabletHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: HomeContentWidget(),
    );
  }
}