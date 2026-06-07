import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/mock_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  List<OrderModel> _apiOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? maKH = prefs.getInt('maKH_logged_in');

    if (maKH == null || maKH == 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Gọi API lấy lịch sử đơn hàng của khách hàng (Cần đảm bảo đúng tên API của C#)
      var response = await http.get(
        Uri.parse('https://localhost:44324/MobileApi/GetOrderHistory?maKH=$maKH')
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> dataList = [];

        // Hỗ trợ cả dạng trả về mảng List trực tiếp hoặc dạng {"success": true, "data": [...]}
        if (jsonResponse is Map && jsonResponse['data'] != null) {
          dataList = List.from(jsonResponse['data']);
        } else if (jsonResponse is List) {
          dataList = List.from(jsonResponse);
        }

        // Ưu tiên thứ tự xếp lịch sử đơn là 1, 2, 3, 4, 5
        dataList.sort((a, b) {
          int tA = a['TinhTrang'] ?? 99;
          int tB = b['TinhTrang'] ?? 99;
          return tA.compareTo(tB);
        });

        List<OrderModel> loadedOrders = [];
        for (var item in dataList) {
          List<OrderItemModel> orderItems = [];
          if (item['ChiTietMon'] != null) {
            for (var ct in item['ChiTietMon']) {
              orderItems.add(OrderItemModel(
                name: ct['TenMon'] ?? 'Món ăn',
                quantity: ct['SoLuong'] ?? 1,
                price: (ct['DonGia'] ?? 0).toDouble(),
              ));
            }
          }

          // Trạng thái đơn hàng lấy từ Tình trạng
          int tinhTrang = item['TinhTrang'] ?? 1;

          // C# trả về ngày dạng "17/04/2026 15:26" nên cần DateFormat để chuyển đổi
          DateTime parsedDate = DateTime.now();
          if (item['NgayLap'] != null) {
            try {
              parsedDate = DateFormat('dd/MM/yyyy HH:mm').parse(item['NgayLap']);
            } catch (_) {}
          }

          loadedOrders.add(OrderModel(
            orderId: item['MaHD'] != null ? '#${item['MaHD']}' : '#...',
            orderDate: parsedDate,
            total: (item['TongTien'] ?? 0).toDouble(),
            status: _getTrangThaiText(tinhTrang), 
            items: orderItems,
          ));
        }

        setState(() {
          _apiOrders = loadedOrders; // Thay thế dữ liệu mock bằng API
        });
      }
    } catch (e) {
      print('Lỗi gọi API Lịch sử đơn hàng: $e');
    }
    setState(() => _isLoading = false);
  }

  String _getTrangThaiText(int tinhTrang) {
    switch (tinhTrang) {
      case 1: return 'Chờ xác nhận';
      case 2: return 'Đang chế biến';
      case 3: return 'Đang phục vụ';
      case 4: return 'Đã thanh toán';
      case 5: return 'Đã hủy';
      default: return 'Chờ xử lý';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _apiOrders.isEmpty
              ? const _EmptyOrders()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _apiOrders.length,
                  itemBuilder: (context, index) {
                    final order = _apiOrders[index];
                    return _OrderCard(order: order);
                  },
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    final statusData = _getStatusData(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_rounded,
                    color: kPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn hàng ${order.orderId}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kDark,
                      ),
                    ),
                    Text(
                      dateFmt.format(order.orderDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (statusData['color'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusData['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.name} x${item.quantity}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Text(
                            '${fmt.format(item.price * item.quantity)}đ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Total
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                ),
                Text(
                  '${fmt.format(order.total)}đ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData(String status) {
    switch (status) {
      case 'Đã thanh toán':
        return {'color': Colors.green};
      case 'Chờ duyệt':
      case 'Đang chuẩn bị':
      case 'Đang phục vụ': // Thêm trạng thái này từ API của bạn
        return {'color': const Color(0xFF0984E3)};
      case 'Đã hủy':
        return {'color': Colors.red[800]};
      default:
        return {'color': Colors.grey[600]};
    }
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy đặt món ngon đầu tiên của bạn!',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Xem thực đơn'),
          ),
        ],
      ),
    );
  }
}
