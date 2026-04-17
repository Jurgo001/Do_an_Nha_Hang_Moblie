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
  Future<bool> datHangTrenMobile(String voucherCode, int paymentMethod) async {
    // Nếu giỏ hàng trống thì báo lỗi luôn, không gọi API
    if (_list.isEmpty) return false; 

    // Đóng gói dữ liệu giỏ hàng hiện tại thành format JSON
    var data = {
      // Map từng món hàng thành dạng { id: "1", qty: 2 }
      "cart": _list.map((e) => {"id": e.maSP, "qty": e.soLuong}).toList(),
      "voucher": voucherCode,
      "paymentMethod": paymentMethod
    };

    try {
      // Gọi lên Server C# của bạn
      // LƯU Ý 1: Nếu chạy máy ảo Android, đổi 'localhost' thành '10.0.2.2'
      // LƯU Ý 2: Nếu chạy điện thoại thật, dùng IP máy tính (VD: 192.168.1.15)
      var response = await http.post(
        Uri.parse('http://192.168.1.xxx:PORT/api/Cart/DatHang'), // <-- NHỚ SỬA LẠI ĐƯỜNG DẪN NÀY
        body: json.encode(data),
        headers: {"Content-Type": "application/json"},
      );

      // Nếu Server C# trả về thành công (Mã 200)
      if (response.statusCode == 200) {
        xoaTatCa(); // THÀNH CÔNG -> Xóa sạch giỏ hàng trên app
        return true; 
      } else {
        print("Lỗi Server: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối khi gọi API Đặt hàng: $e");
      return false; // Thất bại do mất mạng hoặc sai IP
    }
  }
}