import 'package:flutter/material.dart';

class AvatarBadge extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final bool square;

  const AvatarBadge({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 48,
    this.square = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primary;
    if (square) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    width: size - 12,
                    height: size - 12,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.person, color: bg.withOpacity(0.9)),
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(initials, style: const TextStyle(color: Colors.white))
          : null,
    );
  }
}
