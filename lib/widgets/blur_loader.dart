import 'dart:ui';

import 'package:flutter/material.dart';

class BlurLoader extends StatelessWidget {
  const BlurLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: Colors.black.withValues(alpha: 0.1),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF111C68),
            ),
          ),
        ),
      ),
    );
  }
}
