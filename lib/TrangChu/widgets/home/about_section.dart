import '../../../constants.dart';
import 'package:flutter/material.dart';
import '../shared/section_title.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const SectionTitle(
            sub: 'Về Chúng Tôi',
            main: 'Chào mừng đến với\nNhà Hàng Ngon',
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _ImageCard(
                imageUrl: 'assets/images/about-1.jpg',
                label: '🍽️ Không gian',
              ),
              _ImageCard(
                imageUrl: 'assets/images/about-2.jpg',
                label: '🔥 Bếp lửa',
              ),
              _ImageCard(
                imageUrl: 'assets/images/about-3.jpg',
                label: '🥗 Nguyên liệu',
              ),
              _ImageCard(
                imageUrl: 'assets/images/about-4.jpg',
                label: '🍱 Món ăn',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Chúng tôi mang đến cho bạn không gian ẩm thực tinh tế với những món ăn được chế biến từ nguyên liệu chất lượng. Tại đây, bạn sẽ tận hưởng hương vị tuyệt vời cùng sự phục vụ tận tâm.',
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatBox(number: '15', label: 'NĂM', sub: 'KINH NGHIỆM'),
              const SizedBox(width: 16),
              _StatBox(number: '50', label: 'ĐẦU BẾP', sub: 'NỔI TIẾNG'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimary),
                foregroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Xem Chi Tiết',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget mới dùng Stack: ảnh ở dưới, chữ nổi lên trên
class _ImageCard extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _ImageCard({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Ảnh nền
          Image.asset(imageUrl, fit: BoxFit.cover),

          // Layer 2: Gradient overlay để chữ dễ đọc
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
              ),
            ),
          ),

          // Layer 3: Chữ label nổi lên phía trên
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String number;
  final String label;
  final String sub;

  const _StatBox({
    required this.number,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: const Border(left: BorderSide(color: kPrimary, width: 4)),
          color: kLight,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                color: kPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 10,
                    color: kDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
