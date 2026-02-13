import 'dart:io';

import 'package:flutter/cupertino.dart';

class ImagePreview extends StatelessWidget {
  final File? file;

  const ImagePreview({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    if (file == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(file!),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

}