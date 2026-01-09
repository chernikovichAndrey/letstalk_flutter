import 'package:flutter/material.dart';

class CAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;

  const CAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.onTap,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final backgroundColor = _getBackgroundColor(name);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: imageUrl == null ? backgroundColor : Colors.grey[200],
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
