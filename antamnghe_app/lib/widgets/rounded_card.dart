import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const RoundedCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
