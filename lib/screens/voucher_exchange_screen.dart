import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/mock_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VoucherExchangeScreen extends StatefulWidget {
  const VoucherExchangeScreen({super.key});

  @override
  State<VoucherExchangeScreen> createState() => _VoucherExchangeScreenState();
}

class _VoucherExchangeScreenState extends State<VoucherExchangeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userPoints = 0;
  int _maKH = 0;
  List<dynamic> _realVouchers = [];
  List<dynamic> _myVouchers = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? maKH = prefs.getInt('maKH_logged_in');
    
    if (maKH != null) {
      _maKH = maKH;
      try {
        final diemFuture = http.get(Uri.parse('https://localhost:44324/MobileApi/GetDiemHienTai?maKH=$_maKH'));
        final voucherFuture = http.get(Uri.parse('https://localhost:44324/MobileApi/GetDanhSachVoucher'));
        final myVoucherFuture = http.get(Uri.parse('https://localhost:44324/MobileApi/GetVoucherCuaToi?maKH=$_maKH'));
        
        final results = await Future.wait([diemFuture, voucherFuture, myVoucherFuture]);
        
        if (results[0].statusCode == 200) {
          var jsonDiem = json.decode(results[0].body);
          if (jsonDiem['success'] == true) {
             _userPoints = jsonDiem['diem'] ?? 0;
          }
        }

        if (results[1].statusCode == 200) {
          var jsonVoucher = json.decode(results[1].body);
          if (jsonVoucher is List) {
            _realVouchers = jsonVoucher;
          }
        }

        if (results[2].statusCode == 200) {
          var jsonMyVoucher = json.decode(results[2].body);
          if (jsonMyVoucher['success'] == true && jsonMyVoucher['data'] != null) {
            _myVouchers = jsonMyVoucher['data'];
          }
        }
      } catch (e) {
        print("Lỗi tải data đổi điểm: $e");
      }
    }
    setState(() {
      _isLoadingData = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleRedeem(Map<String, dynamic> gift) {
    // Ép kiểu lấy dữ liệu từ API thật
    final points = (gift['DiemDoi'] ?? 0) as int;
    final maVoucher = gift['MaVoucher'] ?? 0;
    final title = gift['TenVoucher'] ?? 'Voucher';

    if (_userPoints < points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn không đủ điểm! Cần thêm ${points - _userPoints} điểm.'),
          backgroundColor: Colors.red[800],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận đổi điểm', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn muốn dùng $points điểm để đổi $title?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () async {
              Navigator.pop(context); // Đóng Dialog

              // GỌI API ĐỔI ĐIỂM THẬT
              try {
                // LƯU Ý: Đổi localhost thành 10.0.2.2 nếu dùng máy ảo Android
                var response = await http.post(
                  Uri.parse('https://localhost:44324/MobileApi/DoiVoucher'), // ĐỔI IP Ở ĐÂY NẾU CẦN
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "MaKH": _maKH,
                    "MaVoucher": maVoucher
                  }),
                );

                if (response.statusCode == 200) {
                  var jsonResponse = json.decode(response.body);
                  if (jsonResponse['success'] == true) {
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(jsonResponse['message']), backgroundColor: Colors.green),
                    );
                    
                    // Gọi tải lại dữ liệu từ đầu để cập nhật Điểm và Danh sách Voucher
                    setState(() => _isLoadingData = true);
                    await _fetchData();
                    _tabController.animateTo(1); // Chuyển sang tab Voucher của tôi

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(jsonResponse['message']), backgroundColor: Colors.red),
                    );
                  }
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi gọi API: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
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
      body: _isLoadingData 
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : TabBarView(
              controller: _tabController,
              children: [
                _GiftLibraryTab(userPoints: _userPoints, realVouchers: _realVouchers, onRedeem: _handleRedeem),
                _MyVouchersTab(diemHienTai: _userPoints, apiVouchers: _myVouchers),
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
  final List<dynamic> realVouchers;
  final void Function(Map<String, dynamic>) onRedeem;

  const _GiftLibraryTab({required this.userPoints, required this.realVouchers, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final list = realVouchers.isNotEmpty ? realVouchers : mockGiftVouchers;
    final isReal = realVouchers.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Points balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // ĐỒNG BỘ MÀU SẮC ĐIỂM KHẢ DỤNG: Giống bên MyVouchersTab
              gradient: const LinearGradient(
                colors: [kPrimary, Color(0xFFFF9F43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điểm khả dụng của bạn',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$userPoints',
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
            itemCount: list.length,
            itemBuilder: (context, index) {
              final gift = list[index];
              final points = isReal ? (gift['DiemDoi'] ?? 0) as int : (gift['points'] as int);
              final canAfford = userPoints >= points;
              
              return _GiftCard(
                gift: gift,
                isReal: isReal,
                canAfford: canAfford,
                onTap: () => onRedeem(gift as Map<String, dynamic>),
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
  final bool isReal;
  final bool canAfford;
  final VoidCallback onTap;

  const _GiftCard({
    required this.gift,
    this.isReal = false,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isReal ? (gift['TenVoucher'] ?? 'Voucher') : (gift['title'] as String);
    final desc = isReal ? 'Giảm ${(gift['GiaTri'] ?? 0).toInt()}đ' : (gift['desc'] as String);
    final points = isReal ? (gift['DiemDoi'] ?? 0) as int : (gift['points'] as int);
    
    final colorList = const [Color(0xFF00B894), Color(0xFFFF6B6B), Color(0xFF6C5CE7), Color(0xFFFFC107)];
    final color = isReal ? colorList[(title.length + points) % 4] : Color(gift['color'] as int);

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
                    title,
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
                    desc,
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
                      '$points điểm',
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
class _MyVouchersTab extends StatelessWidget {
  final int diemHienTai;
  final List<dynamic> apiVouchers;

  const _MyVouchersTab({
    required this.diemHienTai,
    required this.apiVouchers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── 1. Thẻ Điểm khả dụng (Header) ──
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, Color(0xFFFF9F43)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Điểm khả dụng của bạn',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$diemHienTai',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── 2. Danh sách Voucher (Body) ──
        Expanded(
          child: apiVouchers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Bạn chưa có voucher nào',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hãy đổi điểm để nhận ngay ưu đãi!',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: apiVouchers.length,
                  itemBuilder: (context, index) {
                    return _VoucherCard(voucher: apiVouchers[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final dynamic voucher;
  const _VoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final String tenVoucher = voucher['TenVoucher'] ?? 'Voucher';
    final String maCode = voucher['MaCode'] ?? '';
    final String ngayHetHan = voucher['NgayHetHan'] ?? 'Không rõ';
    final bool conHan = voucher['ConHan'] ?? false; // Lấy trạng thái từ Backend

    // Nếu Còn Hạn -> Màu Đỏ (kPrimary), Nếu Hết Hạn -> Màu Xám
    final Color accentColor = conHan ? kPrimary : Colors.grey.shade500;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: conHan ? accentColor.withOpacity(0.4) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dải màu bên trái (Style giống chiếc Vé - Ticket)
          Container(
            width: 8,
            height: 90,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_activity_rounded, color: accentColor, size: 24),
          ),
          const SizedBox(width: 12),
          // Thông tin Voucher
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenVoucher,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: conHan ? kDark : Colors.grey.shade600,
                      decoration: conHan ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã: $maCode',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        'HSD: $ngayHetHan',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Nhãn "Hết hạn" ở góc phải
          if (!conHan)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Hết hạn',
                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
