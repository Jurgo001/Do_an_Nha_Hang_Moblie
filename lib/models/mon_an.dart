import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- MÀU SẮC CHỦ ĐẠO TỪ WEB ---
const Color primaryColor = Color(0xFFFF6B6B);
const Color warningColor = Color(0xFFFF9F43);
const Color darkTextColor = Color(0xFF2D3436);
const Color priceColor = Color(0xFFD63031);

// --- MODEL LOẠI MÓN (MỚI THÊM) ---
class LoaiMon {
  final String id;
  final String tenLoai;
  final IconData icon;

  LoaiMon({required this.id, required this.tenLoai, required this.icon});
}

// --- MODEL MÓN ĂN ---
class MonAn {
  final String id;
  final String tenMon;
  final String moTa;
  final double donGia;
  final String anhDaiDien;
  final String maLoai;
  final List<String> hinhAnhs; // Danh sách ảnh phụ thực tế

  MonAn({
    required this.id,
    required this.tenMon,
    required this.moTa,
    required this.donGia,
    required this.anhDaiDien,
    required this.maLoai,
    this.hinhAnhs = const [],
  });
}

// Hàm format tiền tệ
String formatCurrency(double amount) {
  return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";
}

Future<dynamic> fetchChiTietMonTuAPI(String id) async {
  final url = Uri.parse(
    'https://localhost:44324/MobileApi/GetChiTietMon?id=$id',
  );
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) return jsonDecode(response.body);
  } catch (e) {
    print("Lỗi: $e");
  }
  return null;
}

Future<List<MonAn>> fetchMonAn() async {
  final url = Uri.parse('https://localhost:44324/MobileApi/GetTatCaMonAn');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map(
            (json) => MonAn(
              id: json['MaMon'].toString(),
              tenMon: json['TenMon'],
              moTa: json['MoTa'] ?? 'Chưa có mô tả',
              donGia: (json['DonGia'] as num).toDouble(),
              anhDaiDien:
                  'https://localhost:44324/Content/Images/${json['AnhDaiDien']}',

              maLoai: json['MaLoai']
                  .toString(), // 3. THÊM DÒNG NÀY ĐỂ NHẬN DỮ LIỆU
            ),
          )
          .toList();
    } else {
      throw Exception('Lỗi Server: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Không thể kết nối: $e');
  }
}

// Gọi API lấy danh sách Loại Món
Future<List<LoaiMon>> fetchLoaiMon() async {
  final url = Uri.parse('https://localhost:44324/MobileApi/GetLoaiMon');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);

      List<LoaiMon> list = jsonList
          .map(
            (json) => LoaiMon(
              id: json['MaLoai'].toString(),
              tenLoai: json['TenLoai'],
              icon:
                  Icons.restaurant_menu, // Dùng icon mặc định cho món ăn từ DB
            ),
          )
          .toList();

      // Tự động chèn thêm mục "Tất cả" vào đầu danh sách
      list.insert(
        0,
        LoaiMon(id: 'all', tenLoai: 'Tất cả', icon: Icons.grid_view),
      );
      return list;
    } else {
      throw Exception('Lỗi Server: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Không thể kết nối: $e');
  }
}
