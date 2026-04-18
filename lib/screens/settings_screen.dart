import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Tiếng Việt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
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
                iconColor: AppColors.primary,
                title: 'Cập nhật thông tin cá nhân',
                subtitle: 'Tên, số điện thoại, email',
                onTap: () => _showComingSoon(context),
              ),
              MenuListItem(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF6C5CE7),
                title: 'Địa chỉ giao hàng',
                subtitle: 'Quản lý địa chỉ nhận hàng',
                onTap: () => _showComingSoon(context),
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
                iconColor: AppColors.accent,
                title: 'Cài đặt thông báo',
                subtitle: 'Nhận thông báo đơn hàng, ưu đãi',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeColor: AppColors.primary,
                ),
                onTap: null,
              ),
              MenuListItem(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF2D3436),
                title: 'Chế độ Tối',
                subtitle: 'Giao diện tối cho mắt dễ chịu hơn',
                trailing: Switch.adaptive(
                  value: _darkModeEnabled,
                  onChanged: (v) => setState(() => _darkModeEnabled = v),
                  activeColor: AppColors.primary,
                ),
                onTap: null,
              ),
              MenuListItem(
                icon: Icons.language_outlined,
                iconColor: const Color(0xFF0984E3),
                title: 'Ngôn ngữ',
                subtitle: _selectedLanguage,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLanguage,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () => _showLanguagePicker(context),
                showDivider: false,
              ),
            ],
          ),

          // ── Hỗ trợ ──
          const SectionHeader(title: 'Hỗ trợ'),
          _SettingsCard(
            children: [
              MenuListItem(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.success,
                title: 'Trung tâm trợ giúp',
                subtitle: 'FAQ, hướng dẫn sử dụng',
                onTap: () => _showComingSoon(context),
              ),
              MenuListItem(
                icon: Icons.chat_outlined,
                iconColor: AppColors.primary,
                title: 'Liên hệ hỗ trợ',
                subtitle: 'Chat, email, hotline',
                onTap: () => _showComingSoon(context),
              ),
              MenuListItem(
                icon: Icons.star_outline_rounded,
                iconColor: AppColors.accent,
                title: 'Đánh giá ứng dụng',
                subtitle: 'Chia sẻ trải nghiệm của bạn',
                onTap: () => _showComingSoon(context),
              ),
              MenuListItem(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.textSecondary,
                title: 'Về chúng tôi',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () {},
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
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: AppColors.primary,
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
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final langs = ['Tiếng Việt', 'English', '中文'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chọn ngôn ngữ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...langs.map(
                (lang) => ListTile(
                  leading: Icon(
                    lang == _selectedLanguage
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: lang == _selectedLanguage
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  title: Text(
                    lang,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất không?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
            child: const Text('Đăng xuất'),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
