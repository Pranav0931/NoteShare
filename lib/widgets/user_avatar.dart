import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? const Color(0xFF136DEC).withOpacity(0.2),
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _getInitials(),
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lexend',
                color: const Color(0xFF136DEC),
              ),
            )
          : null,
    );
  }

  String _getInitials() {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

class LargeUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onEdit;

  const LargeUserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 100,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF136DEC),
                const Color(0xFF136DEC).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              radius: size / 2 - 3,
              backgroundColor: Colors.white,
              backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Text(
                      _getInitials(),
                      style: TextStyle(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                        color: const Color(0xFF136DEC),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (onEdit != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF136DEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getInitials() {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
