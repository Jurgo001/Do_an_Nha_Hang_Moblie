import '../../../constants.dart';
import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin',
            style: TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...['📋 Về chúng tôi', '📞 Liên hệ', '🍽️ Đặt bàn'].map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                s,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Liên hệ',
            style: TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...[
            '📍 140 Lê Trọng Tấn, Tân Phú, TP.HCM',
            '📱 0903 330 033',
            '✉️ lienhe@nhahangngon.vn',
          ].map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                s,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Giờ Mở Cửa',
            style: TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thứ 2 - Thứ 7: 08:00 - 23:00',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Text(
            'Chủ nhật: 10:00 - 23:00',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Divider(color: Colors.white24, height: 32),
          const Center(
            child: Text(
              '© 2025 Nhà Hàng Ngon. All Rights Reserved.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
