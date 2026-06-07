import 'package:flutter/material.dart';
import '../../constants.dart';
import '../screens/home_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/booking_screen.dart';
import '../../TrangLienHe/TrangLienHe.dart';
import '../../screens/profile_screen.dart'; // <-- TRỎ VỀ TRANG TÀI KHOẢN CŨ
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';

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
        onDestinationSelected: (i) async {
          if (i == 4) { // 4 là vị trí của tab Cá Nhân
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int? savedMaKH = prefs.getInt('maKH_logged_in');
            
            if (savedMaKH == null || savedMaKH == 0) {
              _showLoginRequiredDialog(context);
              return; // Return để chặn không cho chuyển sang tab Cá nhân
            }
          }
          setState(() => _currentIndex = i);
        },
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

  // Hàm hiển thị Dialog yêu cầu đăng nhập
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Yêu cầu đăng nhập',
          style: TextStyle(fontWeight: FontWeight.w800, color: kDark),
        ),
        content: Text(
          'Vui lòng đăng nhập hoặc đăng ký để sử dụng tính năng này.',
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text('Đăng ký', style: TextStyle(color: kPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
