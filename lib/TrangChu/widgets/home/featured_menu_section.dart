import '../../../constants.dart';
import 'package:flutter/material.dart';

import '../shared/section_title.dart';

class FeaturedMenuSection extends StatefulWidget {
  const FeaturedMenuSection({super.key});

  @override
  State<FeaturedMenuSection> createState() => _FeaturedMenuSectionState();
}

class _FeaturedMenuSectionState extends State<FeaturedMenuSection> {
  int _selectedTab = 0;

  static const _tabs = ['Món Khai Vị', 'Món Chính', 'Tráng Miệng', 'Đồ Uống'];

  static const _menuItems = [
    [
      {
        'name': 'Gỏi Cuốn Tôm Thịt',
        'price': '25.000 đ',
        'desc': 'Món khai vị tươi mát',
        'emoji': '🥗',
      },
      {
        'name': 'Chả Giò Hải Sản',
        'price': '35.000 đ',
        'desc': 'Giòn rụm, nhân đầy',
        'emoji': '🍤',
      },
    ],
    [
      {
        'name': 'Cơm Tấm Sườn Bì',
        'price': '65.000 đ',
        'desc': 'Đặc sản Sài Gòn',
        'emoji': '🍚',
      },
      {
        'name': 'Bún Bò Huế',
        'price': '55.000 đ',
        'desc': 'Đậm đà miền Trung',
        'emoji': '🍜',
      },
      {
        'name': 'Phở Bò Đặc Biệt',
        'price': '60.000 đ',
        'desc': 'Nước dùng ngon ngọt',
        'emoji': '🍲',
      },
    ],
    [
      {
        'name': 'Chè Ba Màu',
        'price': '20.000 đ',
        'desc': 'Ngọt ngào và mát lạnh',
        'emoji': '🍮',
      },
      {
        'name': 'Bánh Flan',
        'price': '18.000 đ',
        'desc': 'Mịn màng, thơm ngon',
        'emoji': '🍯',
      },
    ],
    [
      {
        'name': 'Nước Chanh Muối',
        'price': '15.000 đ',
        'desc': 'Giải khát tuyệt vời',
        'emoji': '🍋',
      },
      {
        'name': 'Sinh Tố Xoài',
        'price': '25.000 đ',
        'desc': 'Tươi ngon mỗi ngày',
        'emoji': '🥭',
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLight,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const SectionTitle(sub: 'Thực Đơn', main: 'Món Ăn Nổi Bật'),
          const SizedBox(height: 16),
          _buildTabBar(),
          const SizedBox(height: 20),
          ..._menuItems[_selectedTab].map(_buildMenuItem),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? kPrimary : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 14,
                    color: active ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tabs[i],
                    style: TextStyle(
                      color: active ? Colors.white : Colors.grey[700],
                      fontSize: 13,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                item['emoji'] as String,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kDark,
                        ),
                      ),
                    ),
                    Text(
                      item['price'] as String,
                      style: const TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Divider(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 4),
                Text(
                  item['desc'] as String,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
