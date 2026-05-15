import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/service/custom_cache_manager.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';

class CAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;
  final bool isLoading;

  const CAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.onTap,
    this.isLoading = false,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name[0] == '+') {
      return '';
    }
    return name[0].toUpperCase();
  }

  Color _getBackgroundColor(String? name) {
    if (name == null || name.isEmpty) return Colors.blue;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _getAnimalAvatar() {
    return 'assets/images/animals/panda.svg';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final backgroundColor = _getBackgroundColor(name);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasName = name != null && name!.isNotEmpty && name![0] != '+';

    Widget avatar;
    final token = (getIt<AuthBloc>().state as AuthAuthenticated).token;

    if (hasImage) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        httpHeaders: {'Authorization': 'Bearer $token'},
        cacheManager: CustomCacheManager.instance,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: context.appColors.backgroundColor,
          child: SizedBox(
            width: radius * 0.5,
            height: radius * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (hasName) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      avatar = SvgPicture.asset(
        _getAnimalAvatar(),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.contain,
      );
    }

    if (isLoading) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha:  0.5),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: context.appColors.secondaryBackground,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
