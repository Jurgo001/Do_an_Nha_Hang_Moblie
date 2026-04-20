import '../../../constants.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String sub;
  final String main;

  const SectionTitle({super.key, required this.sub, required this.main});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 40, height: 1.5, color: kPrimary),
            const SizedBox(width: 8),
            Text(
              sub,
              style: const TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 40, height: 1.5, color: kPrimary),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          main,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kDark,
          ),
        ),
      ],
    );
  }
}
