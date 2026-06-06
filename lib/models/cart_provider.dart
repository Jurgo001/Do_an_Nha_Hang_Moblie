import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import thư viện gọi API
import 'dart:convert';                   // Import thư viện xử lý JSON

// Tương đương với class CartItem trong C#
class CartItem {
  final String maSP;
  final String tenSP;
  final String anhDaiDien;
  final double donGia;
  int soLuong;

  CartItem({
    required this.maSP,
    required this.tenSP,
    required this.anhDaiDien,
    required this.donGia,
    this.soLuong = 1,
  });

  // Tương đương hàm get ThanhTien
  double get thanhTien => donGia * soLuong;
}

// Tương đương với class Cart trong C#
// Dùng ChangeNotifier để báo cho giao diện biết khi giỏ hàng thay đổi
class CartProvider with ChangeNotifier {
  final List<CartItem> _list = [];

  List<CartItem> get list => _list;

  // Tương đương TongSL()
  int get tongSL => _list.fold(0, (sum, item) => sum + item.soLuong);

  // Tương đương TongThanhTien()
  double get tongThanhTien =>
      _list.fold(0, (sum, item) => sum + item.thanhTien);

  // Tương đương Tang()
  void tang(CartItem newItem) {
    int index = _list.indexWhere((item) => item.maSP == newItem.maSP);

    if (index >= 0) {
      // Nếu đã có trong giỏ, tăng số lượng
      _list[index].soLuong++;
    } else {
      // Nếu chưa có, thêm mới vào giỏ
      _list.add(newItem);
    }
    notifyListeners(); // Báo cho UI cập nhật (Ví dụ: nhảy số đỏ trên icon giỏ hàng)
  }

  // Tương đương Giam()
  void giam(String id) {
    int index = _list.indexWhere((item) => item.maSP == id);
    if (index >= 0) {
      _list[index].soLuong--;
      if (_list[index].soLuong <= 0) {
        _list.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Tương đương Xoa()
  void xoa(String id) {
    _list.removeWhere((item) => item.maSP == id);
    notifyListeners();
  }

  // Tiện ích: Xóa sạch giỏ hàng (khi thanh toán xong)
  void xoaTatCa() {
    _list.clear();
    notifyListeners();
  }

  // =========================================================================
  // PHẦN THÊM MỚI: HÀM GỌI API ĐỂ ĐẨY DỮ LIỆU THANH TOÁN LÊN SERVER C#
  // =========================================================================
  Future<bool> datHangTrenMobile(int maKH, String ghiChu,double tongTienThanhToan) async {
    if (_list.isEmpty) return false; 

    // 1. Đóng gói chuẩn 100% theo class OrderRequest bên C#
    var data = {
      "MaKH": maKH, 
      "GhiChu": ghiChu, 
      "TongTienThanhToan": tongTienThanhToan, // 👉 GỬI KÈM SỐ TIỀN VỪA TÍNH LÊN C#
      "Items": _list.map((e) => {
        "MaMon": int.parse(e.maSP), // C# yêu cầu MaMon là số nguyên (int)
        "SoLuong": e.soLuong,
        "DonGia": e.donGia
      }).toList()
    };

    try {
      var response = await http.post(
        Uri.parse('https://localhost:44324/MobileApi/DatHang'),
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          xoaTatCa(); 
          return true; 
        } else {
          print("Lỗi từ server: ${jsonResponse['message']}");
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Lỗi kết nối: $e");
      return false; 
    }
  }
}