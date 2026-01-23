import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';

class MessageImageAttachThumbnail extends StatelessWidget {
  final String thumbnailUrl;

  const MessageImageAttachThumbnail({super.key, required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        thumbnailUrl,
        headers: {'Authorization': 'Bearer $token'},
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, color: Colors.white70, size: 20),
      ),
    );
  }
}
