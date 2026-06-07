import '../../../constants.dart';
import 'package:flutter/material.dart';
import '../shared/section_title.dart';

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  static const _chefs = [
    {
      'name': 'Gordon Ramsay',
      'role': 'Bếp Trưởng',
      'imageUrl': 'assets/images/team-1.jpg',
    },
    {
      'name': 'Jamie Oliver',
      'role': 'Bếp Phó',
      'imageUrl': 'assets/images/team-2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const SectionTitle(sub: 'Đội Ngũ', main: 'Đầu Bếp Hàng Đầu'),
          const SizedBox(height: 20),
          Row(
            children: _chefs.map((chef) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _ChefAvatar(imageUrl: chef['imageUrl']!),
                      const SizedBox(height: 10),
                      Text(
                        chef['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chef['role']!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialBtn(
                            icon: Icons.facebook,
                            color: const Color(0xFF1877F2),
                          ),
                          const SizedBox(width: 6),
                          _SocialBtn(
                            icon: Icons.camera_alt,
                            color: const Color(0xFFE4405F),
                          ),
                          const SizedBox(width: 6),
                          _SocialBtn(
                            icon: Icons.play_circle,
                            color: const Color(0xFF000000),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChefAvatar extends StatelessWidget {
  final String imageUrl;

  const _ChefAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Ảnh tròn
          ClipOval(child: Image.asset(imageUrl, fit: BoxFit.cover)),

          // Layer 2: Viền tròn kPrimary nổi lên trên ảnh
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimary, width: 2.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialBtn({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
