import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mon_an.dart';
import '../models/cart_provider.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';
import 'dart:convert'; // Để dùng jsonDecode
import 'package:http/http.dart' as http; // Để gọi API

// LƯU Ý: Phải đảm bảo file mon_an.dart có chứa class LoaiMon
const Color primaryColor = Colors.red;
const Color warningColor = Colors.orange;
const Color darkTextColor = Color(0xFF333333);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Biến lưu ID danh mục đang chọn
  String selectedCategoryId = 'all';
  late Future<List<LoaiMon>> _loaiMonFuture;
  late Future<List<MonAn>> _monAnFuture;
  @override
  void initState() {
    super.initState();
    // --- 2. CHỈ GỌI API ĐÚNG 1 LẦN KHI MỞ APP ---
    _loaiMonFuture = fetchLoaiMon();
    _monAnFuture = fetchMonAn();
  }
  // --- BẠN DÁN 2 HÀM NÀY VÀO TRONG CLASS _HomeScreenState NHÉ ---

  // 1. Hàm gọi API lấy danh sách Loại món (Danh mục)
  Future<List<LoaiMon>> fetchLoaiMon() async {
    try {
      final url = Uri.parse('https://localhost:44324/MobileApi/GetLoaiMon');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Thêm mục "Tất cả" lên đầu danh sách
        List<LoaiMon> dsLoaiMon = [
          LoaiMon(id: 'all', tenLoai: 'Tất cả', icon: Icons.restaurant_menu),
        ];

        // Map dữ liệu từ C# vào
        dsLoaiMon.addAll(
          data
              .map(
                (json) => LoaiMon(
                  id: json['MaLoai'].toString(),
                  tenLoai: json['TenLoai'] ?? 'Khác',
                  // Tạm gán icon ngẫu nhiên vì DB thường không có icon
                  icon: Icons.fastfood,
                ),
              )
              .toList(),
        );

        return dsLoaiMon;
      }
    } catch (e) {
      print("Lỗi lấy danh mục: $e");
    }
    // Nếu lỗi vẫn trả về mục Tất Cả để app không sập
    return [LoaiMon(id: 'all', tenLoai: 'Tất cả', icon: Icons.restaurant_menu)];
  }

  // 2. Hàm gọi API lấy danh sách Món ăn
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
      print("Lỗi lấy món ăn: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xin chào, Khách hàng 👋",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Text(
              "Thực đơn hôm nay",
              style: TextStyle(
                color: darkTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: primaryColor),
                onPressed: () {
                  // Mở màn hình giỏ hàng mà tui với bạn làm lúc nãy
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              // Hiển thị số lượng nhỏ trên icon giỏ hàng cho xịn
              Positioned(
                top: 8,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DANH MỤC MÓN ĂN (DATA THẬT) ---
            FutureBuilder<List<LoaiMon>>(
              future: _loaiMonFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 45,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const SizedBox();

                final danhMuc = snapshot.data!;
                return SizedBox(
                  height: 45,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: danhMuc.length,
                    itemBuilder: (context, index) {
                      final cat = danhMuc[index];
                      final isSelected = selectedCategoryId == cat.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryId = cat.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.icon,
                                color: isSelected ? Colors.white : primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat.tenLoai,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : darkTextColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // --- 2. BEST SELLER (Lấy ngẫu nhiên 5 món đầu tiên từ DATA THẬT) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSectionTitle(
                Icons.stars,
                warningColor,
                "Top Món Bán Chạy",
              ),
            ),
            const SizedBox(height: 15),

            FutureBuilder<List<MonAn>>(
              future: _monAnFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 230,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const SizedBox();

                // Lấy 5 món đầu tiên làm Best Seller
                final topBestSeller = snapshot.data!.take(5).toList();

                return SizedBox(
                  height: 230,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: topBestSeller.length,
                    itemBuilder: (context, index) {
                      return _buildBestSellerCard(
                        context,
                        topBestSeller[index],
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // --- 3. THỰC ĐƠN HÔM NAY (CÓ LỌC THEO DANH MỤC - DATA THẬT) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(width: 4, height: 24, color: primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Thực Đơn Hôm Nay",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            FutureBuilder<List<MonAn>>(
              future: fetchMonAn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Lỗi tải dữ liệu:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildEmptyState("Chưa có món ăn nào"),
                  );
                }

                // Logic Lọc:
                final danhSachMonAn = snapshot.data!;
                final danhSachLoc = selectedCategoryId == 'all'
                    ? danhSachMonAn
                    : danhSachMonAn
                          .where((mon) => mon.maLoai == selectedCategoryId)
                          .toList();

                if (danhSachLoc.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildEmptyState(
                      "Chưa có món ăn trong danh mục này",
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: danhSachLoc.length,
                  itemBuilder: (context, index) {
                    return _buildMenuCard(context, danhSachLoc[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET GIAO DIỆN PHỤ (GIỮ NGUYÊN) ---

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.fastfood, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, Color iconColor, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWithFallback(String imageUrl, double height) {
    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey.shade400, size: 40),
              Text(
                "Lỗi ảnh",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBestSellerCard(BuildContext context, MonAn monAn) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(monAn: monAn)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _buildImageWithFallback(monAn.anhDaiDien, 120),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [warningColor, primaryColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "BEST SELLER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monAn.tenMon,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${monAn.donGia.toInt()} đ",
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Đã bán: 99+",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ), // Giả lập số lượng vì DB không có
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, MonAn monAn) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(monAn: monAn)),
      ),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _buildImageWithFallback(monAn.anhDaiDien, 120),
                ),
                Positioned(
                  bottom: -15,
                  right: 10,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add,
                        color: primaryColor,
                        size: 20,
                      ),
                      onPressed: () {
                        // Thêm vào giỏ hàng
                        Provider.of<CartProvider>(context, listen: false).tang(
                          CartItem(
                            maSP: monAn.id,
                            tenSP: monAn.tenMon,
                            anhDaiDien: monAn.anhDaiDien,
                            donGia: monAn.donGia,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm ${monAn.tenMon} vào giỏ!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monAn.tenMon,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monAn.moTa,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      "${monAn.donGia.toInt()} đ",
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
