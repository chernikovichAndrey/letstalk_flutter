import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class ContactsSceleton extends StatelessWidget {
  const ContactsSceleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const CSkeleton(width: 48, height: 48, radius: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CSkeleton(width: 140, height: 16, radius: 4),
                    const SizedBox(height: 8),
                    const CSkeleton(width: 100, height: 14, radius: 4),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}