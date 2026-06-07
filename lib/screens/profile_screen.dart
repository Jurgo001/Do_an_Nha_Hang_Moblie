import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/mock_data.dart';
import '../widgets/common_widgets.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'voucher_exchange_screen.dart';
import 'login_screen.dart';
import 'cart_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _maKH = 0;

  // Khai báo các biến lưu thông tin (Sẽ được đổ dữ liệu từ Server)
  String _customerName = "Đang tải...";
  String _customerPhone = "Đang tải...";
  String _memberTier = "Đồng";
  int _loyaltyPoints = 0;
  int _totalOrders = 0;
  int _voucherCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedMaKH = prefs.getInt('maKH_logged_in');

    if (savedMaKH != null) {
      _maKH = savedMaKH;
      try {
        var response = await http.get(
          Uri.parse('https://localhost:44324/MobileApi/GetThongTinKhachHang?maKH=$_maKH')
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            var data = jsonResponse['data'];
            
            setState(() {
              _customerName = data['TenKH'] ?? "Chưa cập nhật";
              _customerPhone = data['DienThoai'] ?? "Chưa cập nhật";
              
              // Lấy các trường điểm/vouchers, nếu BE chưa có tạm set = 0
              _memberTier = data['HangThanhVien'] ?? "Đồng";
              _loyaltyPoints = data['DiemTichLuy'] ?? 0;
              _totalOrders = data['TongDonHang'] ?? 0;
              _voucherCount = data['SoVoucher'] ?? 0;
            });
          }
        }
      } catch (e) {
        print("Lỗi API Profile: $e");
      }

      // --- TẢI LỊCH SỬ ĐƠN HÀNG ĐỂ LỌC VÀ ĐẾM ĐƠN ĐANG XỬ LÝ (1, 2, 3) ---
      try {
        var resOrders = await http.get(
          Uri.parse('https://localhost:44324/MobileApi/GetOrderHistory?maKH=$_maKH')
        );
        if (resOrders.statusCode == 200) {
          var jsonOrders = json.decode(resOrders.body);
          List<dynamic> dataOrders = [];
          if (jsonOrders is Map && jsonOrders['data'] != null) {
            dataOrders = jsonOrders['data'];
          } else if (jsonOrders is List) {
            dataOrders = jsonOrders;
          }

          // Đếm các đơn hàng có TinhTrang 1, 2, 3 (bỏ qua 4 và 5)
          int activeCount = dataOrders.where((o) {
            int tt = o['TinhTrang'] ?? 0;
            return tt == 1 || tt == 2 || tt == 3;
          }).length;

          setState(() => _totalOrders = activeCount);
        }
      } catch (e) {
        print("Lỗi API Order trong Profile: $e");
      }
    } else {
      setState(() {
        _customerName = "Khách vãng lai";
        _customerPhone = "Vui lòng đăng nhập";
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kLight,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        backgroundColor: kDark,
        title: const Text('Tài khoản', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: Colors.white,
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
            _ProfileHeaderCard(
              name: _customerName,
              phone: _customerPhone,
              memberTier: _memberTier,
              loyaltyPoints: _loyaltyPoints,
            ),

            // ── Stats Cards ──
            _StatsRow(totalOrders: _totalOrders, voucherCount: _voucherCount),

            const SizedBox(height: 12),

            // ── Voucher Wallet ──
            _VoucherWalletSection(),

            const SizedBox(height: 24),

            // ── Nút Giỏ Hàng ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // ── Logout button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: kPrimary.withOpacity(0.5),
                    ),
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
          'Bạn có chắc muốn đăng xuất khỏi tài khoản này không?',
          style: TextStyle(color: Colors.grey[700], height: 1.5),
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
            onPressed: () async {
              // KHI BẤM ĐĂNG XUẤT CẦN XÓA CHÌA KHÓA KHỎI KÉT SẮT
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('maKH_logged_in');

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

// ─────────────────────────────────────────
// Profile Header Card
// ─────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String phone;
  final String memberTier;
  final int loyaltyPoints;

  const _ProfileHeaderCard({
    required this.name,
    required this.phone,
    required this.memberTier,
    required this.loyaltyPoints,
  });

  String get avatarInitials {
    if (name.isEmpty || name == "Khách vãng lai") return "U";
    var parts = name.trim().split(' ');
    if (parts.length > 1) {
      return parts[0][0].toUpperCase() + parts.last[0].toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // ĐÃ KHÔI PHỤC logic lấy màu theo hạng thành viên
    final tierData = MemberBadge.getTierData(memberTier);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172B), Color(0xFF151424)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
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
                color: Colors.white.withOpacity(0.08),
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
                color: Colors.white.withOpacity(0.06),
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
                      initials: avatarInitials,
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
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MemberBadge(tier: memberTier), 
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
                          color: Colors.white.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tierData['color'] as Color, // Lấy màu động từ getTierData
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.stars_rounded,
                          color: tierData['textColor'] as Color, // Lấy màu động từ getTierData
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
                            '$loyaltyPoints điểm',
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
                            color: tierData['color'] as Color, // Lấy màu động từ getTierData
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Đổi ngay',
                            style: TextStyle(
                              color: tierData['textColor'] as Color, // Lấy màu động từ getTierData
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
  final int totalOrders;
  final int voucherCount;
  const _StatsRow({
    required this.totalOrders,
    required this.voucherCount,
  });

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
              value: totalOrders.toString(),
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
              iconColor: Colors.orange.shade700,
              bgColor: const Color(0xFFFFF8E1),
              label: 'Voucher của tôi',
              value: voucherCount.toString(),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
// Voucher Wallet Section
// ─────────────────────────────────────────
class _VoucherWalletSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                    color: kDark,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          if (mockVouchers.isEmpty)
            _EmptyVoucherState()
          else
            ...mockVouchers.map((v) => _VoucherTile(voucher: v)).toList(),
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
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Bạn chưa có voucher nào',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy tích điểm và đổi quà nhé!',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VoucherExchangeScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Đổi điểm ngay →',
                style: TextStyle(
                  color: kPrimary,
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
                  ? Colors.grey[200]
                  : const Color(0xFFD1F2EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.percent_rounded,
              color: isUsed ? Colors.grey[400] : const Color(0xFF00B894),
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
                        ? Colors.grey[600]
                        : kDark,
                    decoration: isUsed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mã: ${voucher.code}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUsed
                  ? Colors.grey[200]
                  : const Color(0xFFD1F2EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isUsed ? 'Đã dùng' : 'Sẵn sàng',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isUsed
                    ? Colors.grey[600]
                    : const Color(0xFF00B894),
              ),
            ),
          ),
        ],
      ),
    );
  }
}