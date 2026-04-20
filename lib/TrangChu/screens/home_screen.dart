import '../../constants.dart';
import 'package:flutter/material.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/service_section.dart';
import '../widgets/home/about_section.dart';
import '../widgets/home/featured_menu_section.dart';
import '../widgets/home/team_section.dart';
import '../widgets/home/testimonials_section.dart';
import '../widgets/home/footer_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: kDark,
            title: Row(
              children: [
                const Icon(Icons.restaurant, color: kPrimary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Nhà Hàng Ngon',
                  style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Đăng Nhập',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Column(
              children: [
                HeroSection(),
                ServiceSection(),
                AboutSection(),
                FeaturedMenuSection(),
                TeamSection(),
                TestimonialsSection(),
                FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
