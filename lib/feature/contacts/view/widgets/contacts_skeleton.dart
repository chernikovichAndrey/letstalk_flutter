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
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              const CSkeleton(width: 40, height: 40, radius: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CSkeleton(width: 140, height: 16, radius: 4),
                      const SizedBox(height: 8),
                      const CSkeleton(width: 100, height: 14, radius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}