import '../../../constants.dart';
import 'package:flutter/material.dart';

//Phần này tạo giao diện dịch vụ nhà hàng của Trang Chủ
class ServiceSection extends StatelessWidget {
  static const _services = [
    {
      'icon': Icons.person,
      'title': 'Đầu Bếp Hàng Đầu',
      'desc': 'Đội ngũ đầu bếp tài năng với kinh nghiệm lâu năm.',
    },
    {
      'icon': Icons.eco,
      'title': 'Thực Phẩm Sạch',
      'desc': 'Nguyên liệu tươi ngon, chọn lọc kỹ lưỡng mỗi ngày.',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Đặt Hàng Online',
      'desc': 'Dễ dàng chọn món và đặt hàng trực tuyến.',
    },
    {
      'icon': Icons.headset_mic,
      'title': 'Hỗ Trợ 24/7',
      'desc': 'Chúng tôi luôn sẵn sàng lắng nghe và phục vụ bạn.',
    },
  ];

  const ServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLight,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: _services.map((s) {
          return _ServiceCard(
            icon: s['icon'] as IconData,
            title: s['title'] as String,
            desc: s['desc'] as String,
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovered ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 36,
              color: _hovered ? Colors.white : kPrimary,
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: _hovered ? Colors.white : kDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: _hovered ? Colors.white70 : Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
