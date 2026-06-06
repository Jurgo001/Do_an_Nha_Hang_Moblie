import '../../../constants.dart';
import 'package:flutter/material.dart';

class SuccessView extends StatelessWidget {
  final VoidCallback onReset;

  const SuccessView({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: kPrimary, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đặt Bàn Thành Công!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cảm ơn bạn đã đặt bàn. Chúng tôi sẽ liên hệ xác nhận sớm nhất.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Đặt Bàn Mới'),
            ),
          ],
        ),
      ),
    );
  }
}
