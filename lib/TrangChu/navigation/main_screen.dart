import 'package:flutter/material.dart';
import '../../constants.dart';
import '../screens/home_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/booking_screen.dart';
import '../../TrangLienHe/TrangLienHe.dart';
import '../../screens/profile_screen.dart'; // <-- TRỎ VỀ TRANG TÀI KHOẢN CŨ

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    MenuScreen(),
    BookingScreen(),
    LienHePage(),
    ProfileScreen(), // <-- Dùng ProfileScreen thay vì PersonalScreen trống
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: kDark,
        indicatorColor: kPrimary,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Trang Chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.restaurant_menu, color: Colors.white),
            label: 'Thực Đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.table_restaurant, color: Colors.white),
            label: 'Đặt Bàn',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_phone_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.contact_phone, color: Colors.white),
            label: 'Liên Hệ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white70),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Cá Nhân',
          ),
        ],
      ),
    );
  }
}
