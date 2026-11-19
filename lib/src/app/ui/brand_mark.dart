import 'package:flutter/material.dart';

/// The INTRA Buddy mark shown on the auth screens.
///
/// The artwork already carries its own white interior, so it sits directly on
/// the page colour without a container. The visible name is rendered as text
/// next to it, which is why the image is excluded from semantics.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/branding/intra_buddy_mark.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true,
      ),
    );
  }
}
