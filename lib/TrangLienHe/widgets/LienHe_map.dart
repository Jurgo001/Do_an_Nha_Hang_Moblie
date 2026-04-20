import 'LienHe_mapLink.dart';
import 'package:flutter/material.dart';

class LienHeMap extends StatelessWidget {
  const LienHeMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 160,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.hardEdge,
          child: const MapPreviewWidget(),
        ),
      ),
    );
  }
}
