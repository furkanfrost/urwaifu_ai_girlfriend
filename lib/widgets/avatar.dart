import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String path;
  final double radius;
  const Avatar({super.key, required this.path, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        path,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.pinkAccent.withOpacity(0.2),
          child: Icon(Icons.person, size: radius, color: Colors.pinkAccent),
        ),
      ),
    );
  }
}
