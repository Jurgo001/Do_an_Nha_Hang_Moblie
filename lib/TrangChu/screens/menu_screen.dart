import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../models/mon_an.dart';
import '../../models/cart_provider.dart';
import '../../screens/cart_screen.dart'; // Trỏ về giỏ hàng cũ của bạn
import '../../screens/detail_screen.dart'; // Trỏ về trang chi tiết cũ của bạn

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCatId = 'all';
  String _search = '';

  late Future<List<LoaiMon>> _loaiMonFuture;
  late Future<List<MonAn>> _monAnFuture;

  @override
  void initState() {
    super.initState();
    _loaiMonFuture = fetchLoaiMon();
    _monAnFuture = fetchMonAn();
  }

  // --- API LẤY DANH MỤC ---
  Future<List<LoaiMon>> fetchLoaiMon() async {
    try {
      final url = Uri.parse('https://localhost:44324/MobileApi/GetLoaiMon');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<LoaiMon> dsLoaiMon = [
          LoaiMon(id: 'all', tenLoai: 'Tất cả', icon: Icons.grid_view),
        ];
        dsLoaiMon.addAll(
          data
              .map(
                (json) => LoaiMon(
                  id: json['MaLoai'].toString(),
                  tenLoai: json['TenLoai'] ?? 'Khác',
                  icon: Icons.restaurant,
                ),
              )
              .toList(),
        );
        return dsLoaiMon;
      }
    } catch (e) {
      print("Lỗi danh mục: $e");
    }
    return [LoaiMon(id: 'all', tenLoai: 'Tất cả', icon: Icons.grid_view)];
  }

  // --- API LẤY MÓN ĂN ---
  Future<List<MonAn>> fetchMonAn() async {
    try {
      final url = Uri.parse('https://localhost:44324/MobileApi/GetTatCaMonAn');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (json) => MonAn(
                id: json['MaMon'].toString(),
                tenMon: json['TenMon'] ?? 'Đang cập nhật',
                moTa: json['MoTa'] ?? '',
                donGia: (json['DonGia'] as num?)?.toDouble() ?? 0.0,
                anhDaiDien:
                    'https://localhost:44324/Content/Images/${json['AnhDaiDien']}',
                maLoai: json['MaLoai'].toString(),
              ),
            )
            .toList();
      }
    } catch (e) {
      print("Lỗi món ăn: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kDark,
        title: const Text(
          'Thực Đơn',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // BƯNG LẠI CÁI GIỎ HÀNG VÀO GÓC PHẢI
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) => cart.tongSL > 0
                      ? Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.tongSL}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. THANH CUỘN DANH MỤC (TỪ API)
          SizedBox(
            height: 50,
            child: FutureBuilder<List<LoaiMon>>(
              future: _loaiMonFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  );
                final danhMuc = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: danhMuc.length,
                  itemBuilder: (_, i) {
                    final cat = danhMuc[i];
                    final active = cat.id == _selectedCatId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCatId = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: active ? kPrimary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat.icon,
                              size: 14,
                              color: active ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cat.tenLoai,
                              style: TextStyle(
                                fontSize: 12,
                                color: active ? Colors.white : Colors.grey[700],
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. DANH SÁCH MÓN ĂN (TỪ API)
          Expanded(
            child: FutureBuilder<List<MonAn>>(
              future: _monAnFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  );
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return _buildEmpty();

                // Lọc món theo Category và Search
                final filteredList = snapshot.data!.where((item) {
                  final catMatch =
                      _selectedCatId == 'all' || item.maLoai == _selectedCatId;
                  final searchMatch =
                      _search.isEmpty ||
                      item.tenMon.toLowerCase().contains(_search.toLowerCase());
                  return catMatch && searchMatch;
                }).toList();

                if (filteredList.isEmpty) return _buildEmpty();

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredList.length,
                  itemBuilder: (_, i) => _buildMenuItem(
                    context,
                    filteredList[i],
                  ), // Truyền MonAn thật vào
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy món ăn',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD MÓN ĂN (Giao diện mới + Dữ liệu thật)
  Widget _buildMenuItem(BuildContext context, MonAn item) {
    return GestureDetector(
      // BẤM VÀO CHUYỂN SANG TRANG CHI TIẾT
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(monAn: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh thật lấy từ mạng thay vì cái Icon Emoji
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.anhDaiDien,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.tenMon,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: kDark,
                          ),
                        ),
                      ),
                      Text(
                        '${item.donGia.toInt()} đ',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 4),
                  Text(
                    item.moTa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    // NÚT THÊM VÀO GIỎ HÀNG
                    child: InkWell(
                      onTap: () {
                        Provider.of<CartProvider>(context, listen: false).tang(
                          CartItem(
                            maSP: item.id,
                            tenSP: item.tenMon,
                            anhDaiDien: item.anhDaiDien,
                            donGia: item.donGia,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${item.tenMon} vào giỏ!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Đặt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
