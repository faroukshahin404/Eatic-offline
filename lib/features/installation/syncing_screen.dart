import 'package:flutter/material.dart';

import '../../core/widgets/custom_padding.dart';

class SyncingScreen extends StatelessWidget {
  const SyncingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: CustomPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Text(
                'Syncing Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Online syncing flow will be implemented in the next step.'),
            ],
          ),
        ),
      ),
    );
  }
}
