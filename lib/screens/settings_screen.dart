import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'address_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
      ),
      body: ListView(
        children: [
          // ── Tài khoản ──
          const SectionHeader(title: 'Tài khoản'),
          _SettingsCard(
            children: [
              MenuListItem(
                icon: Icons.person_outline_rounded,
                iconColor: kPrimary,
                title: 'Cập nhật thông tin cá nhân',
                subtitle: 'Tên, số điện thoại, email',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              MenuListItem(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF6C5CE7),
                title: 'Địa chỉ giao hàng',
                subtitle: 'Quản lý địa chỉ nhận hàng',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
                  );
                },
              ),
              MenuListItem(
                icon: Icons.credit_card_outlined,
                iconColor: const Color(0xFF00B894),
                title: 'Phương thức thanh toán',
                subtitle: 'Thẻ, ví điện tử, COD',
                onTap: () => _showComingSoon(context),
                showDivider: false,
              ),
            ],
          ),

          // ── Tùy chỉnh ──
          const SectionHeader(title: 'Tùy chỉnh'),
          _SettingsCard(
            children: [
              MenuListItem(
                icon: Icons.notifications_outlined,
                iconColor: Colors.orange,
                title: 'Cài đặt thông báo',
                subtitle: 'Nhận thông báo đơn hàng, ưu đãi',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeColor: kPrimary,
                ),
                onTap: null,
                showDivider: false,
              ),
            ],
          ),

          // ── Hỗ trợ ──
          const SectionHeader(title: 'Hỗ trợ'),
          _SettingsCard(
            children: [
              MenuListItem(
                icon: Icons.chat_outlined,
                iconColor: kPrimary,
                title: 'Liên hệ hỗ trợ',
                subtitle: 'Chat, email, hotline',
                onTap: () => _showComingSoon(context),
              ),
              MenuListItem(
                icon: Icons.star_outline_rounded,
                iconColor: Colors.orange,
                title: 'Đánh giá ứng dụng',
                subtitle: 'Chia sẻ trải nghiệm của bạn',
                onTap: () => _showComingSoon(context),
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimary.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: kPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: kPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🚀 Tính năng đang được phát triển'),
        backgroundColor: kDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.w800, color: kDark),
        ),
        content: Text(
          'Bạn có chắc muốn đăng xuất không?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Settings Card wrapper ──
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
