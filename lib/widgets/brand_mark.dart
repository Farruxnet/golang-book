import 'package:flutter/material.dart';

import '../theme.dart';

/// The app mark: "Go" set in the code font on the accent color.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        'Go',
        style: TextStyle(
          fontFamily: AppTheme.mono,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}
