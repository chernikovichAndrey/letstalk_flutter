import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';

class NetworkImageViewer extends StatelessWidget {
  final String imageUrl;

  const NetworkImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          imageUrl,
          headers: {'Authorization': 'Bearer $token'},
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.broken_image,
              size: 64,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
