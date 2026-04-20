import '../../../constants.dart';
import 'package:flutter/material.dart';
import '../shared/section_title.dart';

//Phần này tạo giao diện Đánh giá của khách hàng ở Trang Chủ
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  static const _reviews = [
    {
      'text':
          'Lần đầu ghé ăn thử, wow nha! Đồ ăn ở nhà hàng rất hợp vị, giá cả phải chăng, không gian sang trọng.',
      'name': 'Thanh Nhã',
      'role': 'Thực khách',
      'emoji': '👩',
    },
    {
      'text':
          '10 điểm không có nhưng nha. Đồ ăn thì khỏi bàn, mê nhất là món Chả giò hải sản, trời ơi nó ngon!!!',
      'name': 'Khả Hân',
      'role': 'Doanh nhân',
      'emoji': '👨',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLight,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const SectionTitle(
            sub: 'Đánh Giá',
            main: 'Khách Hàng Nói Gì\nVề Chúng Tôi!',
          ),
          const SizedBox(height: 20),
          ..._reviews.asMap().entries.map((entry) {
            final isHighlight = entry.key == 1;
            final r = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHighlight ? kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHighlight ? kPrimary : Colors.grey[200]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 28,
                    color: isHighlight ? Colors.white : kPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r['text']!,
                    style: TextStyle(
                      color: isHighlight ? Colors.white : Colors.grey[700],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHighlight
                              ? Colors.white.withOpacity(0.2)
                              : kPrimary.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            r['emoji']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isHighlight ? Colors.white : kDark,
                            ),
                          ),
                          Text(
                            r['role']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isHighlight
                                  ? Colors.white70
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
