import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/mock_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoucherExchangeScreen extends StatefulWidget {
  const VoucherExchangeScreen({super.key});

  @override
  State<VoucherExchangeScreen> createState() => _VoucherExchangeScreenState();
}

class _VoucherExchangeScreenState extends State<VoucherExchangeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userPoints = mockUser.loyaltyPoints;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleRedeem(Map<String, dynamic> gift) {
    final points = gift['points'] as int;
    if (_userPoints < points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bạn không đủ điểm! Cần thêm ${points - _userPoints} điểm nữa.',
          ),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận đổi điểm',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Bạn muốn đổi '),
              TextSpan(
                text: '$points điểm',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                ),
              ),
              const TextSpan(text: ' để nhận '),
              TextSpan(
                text: gift['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '?'),
            ],
          ),
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
              setState(() => _userPoints -= points);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Đổi thành công! Bạn còn $_userPoints điểm'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        title: const Text('Thư viện quà tặng'),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimary,
          unselectedLabelColor: Colors.white60,
          indicatorColor: kPrimary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
          ),
          tabs: const [
            Tab(text: 'Đổi điểm'),
            Tab(text: 'Voucher của tôi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GiftLibraryTab(userPoints: _userPoints, onRedeem: _handleRedeem),
          const _MyVouchersTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Gift Library Tab
// ─────────────────────────────────────────
class _GiftLibraryTab extends StatelessWidget {
  final int userPoints;
  final void Function(Map<String, dynamic>) onRedeem;

  const _GiftLibraryTab({required this.userPoints, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Points balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số dư khả dụng',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    Text(
                      '$userPoints Điểm',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Đổi điểm tích lũy lấy ưu đãi độc quyền',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),

          const SizedBox(height: 16),

          // Gift grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: mockGiftVouchers.length,
            itemBuilder: (context, index) {
              final gift = mockGiftVouchers[index];
              final canAfford = userPoints >= (gift['points'] as int);
              return _GiftCard(
                gift: gift,
                canAfford: canAfford,
                onTap: () => onRedeem(gift),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final Map<String, dynamic> gift;
  final bool canAfford;
  final VoidCallback onTap;

  const _GiftCard({
    required this.gift,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(gift['color'] as int);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canAfford ? color.withOpacity(0.3) : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_activity_outlined,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gift['title'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: canAfford
                        ? kDark
                        : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gift['desc'] as String,
                  style: TextStyle(
                      fontSize: 11,
                    color: Color.fromARGB(255, 189, 189, 189),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? color.withOpacity(0.12)
                        : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${gift['points']} điểm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      color: canAfford ? color : const Color.fromARGB(255, 189, 189, 189)       ),
                    ),
                  ),
                ],
              ),
            ),
            if (!canAfford)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                  color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                child: Text(
                    'Thiếu điểm',
                    style: TextStyle(
                      fontSize: 9,
                    color: const Color.fromARGB(255, 189, 189, 189),
                      fontWeight: FontWeight.w600,
                    ),
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
// My Vouchers Tab
// ─────────────────────────────────────────
class _MyVouchersTab extends StatefulWidget {
  const _MyVouchersTab();

  @override
  State<_MyVouchersTab> createState() => _MyVouchersTabState();
}

class _MyVouchersTabState extends State<_MyVouchersTab> {
  bool _isLoading = true;
  List<dynamic> _apiVouchers = [];

  @override
  void initState() {
    super.initState();
    _fetchMyVouchers();
  }

  Future<void> _fetchMyVouchers() async {
    try {
      var res = await http.get(Uri.parse('https://localhost:44324/MobileApi/GetDanhSachVoucher'));
      if (res.statusCode == 200) {
        var jsonResponse = json.decode(res.body);
        if (jsonResponse is List) {
          setState(() => _apiVouchers = jsonResponse);
        }
      }
    } catch (e) {
      print("Lỗi API My Vouchers: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_apiVouchers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color.fromARGB(255, 189, 189, 189),
            ),
            SizedBox(height: 12),
            Text(
              'Bạn chưa có voucher nào',
              style: TextStyle(
                color: Color.fromARGB(255, 117, 117, 117),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Hãy đổi điểm để nhận ưu đãi!',
              style: TextStyle(color: Color.fromARGB(255, 189, 189, 189), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _apiVouchers.length,
      itemBuilder: (context, index) {
        final v = _apiVouchers[index];
        return _VoucherCard(voucher: v);
      },
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final dynamic voucher;
  const _VoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final String code = voucher['TenVoucher'] ?? 'VOUCHER';
    final double value = (voucher['GiaTri'] ?? 0).toDouble();
    final String title = 'Giảm ${value.toInt()}đ';
    final bool isUsed = false; // Backend chưa có trạng thái nên mặc định false

    final accentColor = isUsed ? Colors.grey[600]! : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUsed ? Colors.grey[300]! : accentColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left color strip
          Container(
            width: 6,
            height: 80,
            decoration: BoxDecoration(
              color: isUsed ? Colors.grey[300] : accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUsed
                  ? Colors.grey[200]
                  : accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.percent_rounded, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  'Mã: $code',
                style: TextStyle(
                    fontSize: 12,
                  color: Colors.grey[600],
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isUsed
                  ? Colors.grey[200]
                    : accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUsed ? 'Đã dùng' : 'Sẵn sàng',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
