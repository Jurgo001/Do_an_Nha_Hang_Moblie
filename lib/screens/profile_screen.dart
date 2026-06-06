import 'package:danh_sach_mon_an/TrangChu/navigation/main_screen.dart';
import 'package:danh_sach_mon_an/models/user_session.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/mock_data.dart';
import '../widgets/common_widgets.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'voucher_exchange_screen.dart';
import 'login_screen.dart';
import 'cart_screen.dart'; // Đổi tên file này cho đúng với dự án của nhóm
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isLoggedIn) {
      return const LoginScreen();
    }

    final user = mockUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tài khoản'),
        centerTitle: true,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Card ──
            _ProfileHeaderCard(user: user),

            // ── Stats Cards ──
            _StatsRow(user: user),

            const SizedBox(height: 12),

            // ── Quick Actions ──
            _QuickActionsSection(),

            const SizedBox(height: 12),

            // ── Voucher Wallet ──
            _VoucherWalletSection(),

            const SizedBox(height: 24),

            // 👉 BẮT ĐẦU ĐOẠN CODE NÚT ĐẾN GIỎ HÀNG:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Màu cam cho nổi bật
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), 
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  label: const Text(
                    "MỞ GIỎ HÀNG",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    // Xây cầu chạy thẳng sang màn hình Giỏ Hàng
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()), 
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16), 
            // 👉 KẾT THÚC ĐOẠN CODE
            // ── Logout button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
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
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản này không?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
              UserSession.isLoggedIn = false;
              UserSession.userName = null;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
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

// ─────────────────────────────────────────
// Profile Header Card
// ─────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final UserModel user;

  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF9F43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    UserAvatarWidget(
                      initials: user.avatarInitials,
                      size: 72,
                      showEditIcon: true,
                      onEditTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phone,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MemberBadge(tier: user.memberTier),
                        ],
                      ),
                    ),
                    // Edit button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Points bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Điểm tích lũy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${user.loyaltyPoints} điểm',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VoucherExchangeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Đổi ngay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────
// Stats Row (orders / vouchers)
// ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_bag_outlined,
              iconColor: const Color(0xFF6C5CE7),
              bgColor: const Color(0xFFF0EDFF),
              label: 'Đơn hàng',
              value: user.totalOrders.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
              actionText: 'Xem lịch sử',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.local_activity_outlined,
              iconColor: AppColors.accentDark,
              bgColor: const Color(0xFFFFF8E1),
              label: 'Voucher của tôi',
              value: user.voucherCount.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VoucherExchangeScreen(),
                  ),
                );
              },
              actionText: 'Đổi điểm',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String actionText;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
    required this.onTap,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 11,
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Quick Actions Section
// ─────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        Icons.person_outline_rounded,
        'Hồ sơ',
        AppColors.primary,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
        },
      ),
      _QuickAction(
        Icons.receipt_long_outlined,
        'Đơn hàng',
        const Color(0xFF6C5CE7),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
          );
        },
      ),
      _QuickAction(
        Icons.card_giftcard_rounded,
        'Đổi điểm',
        AppColors.accent,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VoucherExchangeScreen()),
          );
        },
      ),
      _QuickAction(
        Icons.settings_outlined,
        'Cài đặt',
        const Color(0xFF00B894),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Truy cập nhanh',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((a) => _buildActionItem(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.color, this.onTap);
}

// ─────────────────────────────────────────
// Voucher Wallet Section
// ─────────────────────────────────────────
class _VoucherWalletSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1F2EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_activity_outlined,
                    color: Color(0xFF00B894),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ví Voucher của tôi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          if (mockVouchers.isEmpty)
            _EmptyVoucherState()
          else
            ...mockVouchers.map((v) => _VoucherTile(voucher: v)),
        ],
      ),
    );
  }
}

class _EmptyVoucherState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn chưa có voucher nào',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hãy tích điểm và đổi quà nhé!',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Đổi điểm ngay →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherTile extends StatelessWidget {
  final VoucherModel voucher;
  const _VoucherTile({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final isUsed = voucher.isUsed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUsed
                  ? AppColors.surfaceVariant
                  : const Color(0xFFD1F2EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.percent_rounded,
              color: isUsed ? AppColors.textHint : const Color(0xFF00B894),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isUsed
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: isUsed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mã: ${voucher.code}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUsed
                  ? AppColors.surfaceVariant
                  : const Color(0xFFD1F2EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isUsed ? 'Đã dùng' : 'Sẵn sàng',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isUsed
                    ? AppColors.textSecondary
                    : const Color(0xFF00B894),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
