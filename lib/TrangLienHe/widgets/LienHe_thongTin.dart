import 'package:flutter/material.dart';

class LienHeThongTin extends StatelessWidget {
  const LienHeThongTin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2D3436),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Thông Tin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Colors.white24, height: 28),

          InfoItem(
            icon: Icons.location_on,
            title: 'Địa chỉ',
            content: '140 Lê Trọng Tấn, P. Tây Thạnh, Q. Tân Phú, TP.HCM',
          ),
          SizedBox(height: 20),

          InfoItem(
            icon: Icons.phone,
            title: 'Hotline',
            content: '0909 736 426',
          ),
          SizedBox(height: 20),

          InfoItem(
            icon: Icons.email,
            title: 'Email',
            content: 'cskh@nhahangngon.vn',
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFF6B6B), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
