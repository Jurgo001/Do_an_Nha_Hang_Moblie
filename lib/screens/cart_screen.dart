import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _noteController =
      TextEditingController(); // Thêm biến lưu ghi chú
  int _paymentMethod = 1;
  int _maKH = 0;

  List<dynamic> _danhSachVoucher = []; 
  double _giamGia = 0; // Biến này dùng để lưu số tiền được giảm nè
  // Giả lập thông tin người dùng (Sau này bạn có thể lấy từ API Đăng nhập)
   // final String _customerName = "Quang Minh";
  //final String _customerPhone = "00000000000";
  //final String _deliveryAddress =
      //"140 Lê Trọng Tấn, Phường Tây Thạnh, Quận Tân Phú, TP.HCM";
  String _customerName = "Đang tải...";
  String _customerPhone = "Đang tải...";
  String _deliveryAddress = "Đang tải thông tin...";

  @override
  void initState() {
    super.initState();
    // Gọi hàm này ngay khi màn hình giỏ hàng vừa xuất hiện
    _loadUserDataAndFetchAPI(); 
  }

  // --- HÀM XỬ LÝ CHÍNH ---
  Future<void> _loadUserDataAndFetchAPI() async {
    // 1. MỞ KÉT SẮT TÌM MÃ KHÁCH HÀNG (Thay vì gõ cứng _maKH = 1)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedMaKH = prefs.getInt('maKH_logged_in');

    if (savedMaKH != null) {
      // 2. NẾU CÓ ĐĂNG NHẬP -> Dùng mã thật để gọi API
      _maKH = savedMaKH; 
      print("Đã lấy được MaKH từ két sắt là: $_maKH");

      try {
        var response = await http.get(
          Uri.parse('https://localhost:44324/MobileApi/GetThongTinKhachHang?maKH=$_maKH')
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            var data = jsonResponse['data'];
            
            setState(() {
              _customerName = data['TenKH'] ?? "Chưa có tên";
              _customerPhone = data['DienThoai'] ?? "Chưa có SĐT";
              _deliveryAddress = data['DiaChi'] ?? "Chưa cập nhật địa chỉ";
            });
          }
        }
      } catch (e) {
        print("Lỗi API Khách hàng: $e");
      }

// ========================================================
      // 👉 DÁN THÊM ĐOẠN GỌI API VOUCHER VÀO NGAY ĐÂY NÈ
      // ========================================================
      try {
        var responseVoucher = await http.get(
          Uri.parse('https://localhost:44324/MobileApi/GetDanhSachVoucher')
        );

        if (responseVoucher.statusCode == 200) {
          // Vì C# trả thẳng mảng Json(vouchers) nên hứng trực tiếp dạng List
          var jsonResponse = json.decode(responseVoucher.body);
          
          if (jsonResponse is List) {
            setState(() {
              _danhSachVoucher = jsonResponse;
            });
            print("Đã tải thành công ${_danhSachVoucher.length} voucher!");
          }
        }
      } catch (e) {
        print("Lỗi API Voucher: $e");
      }
      // ========================================================


    } else {
      // 3. NẾU CHƯA ĐĂNG NHẬP
      setState(() {
        _customerName = "Khách vãng lai";
        _customerPhone = "Vui lòng đăng nhập";
        _deliveryAddress = "Chưa có địa chỉ giao hàng";
      });
    }
  }



  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context, double totalAmount) {
    String nganHang = "sacombank";
    String soTaiKhoan = "060324378270";
    String chuTaiKhoan = "DANG QUANG MINH";

    String qrUrl =
        "https://img.vietqr.io/image/$nganHang-$soTaiKhoan-compact.png?amount=${totalAmount.toInt()}&addInfo=Thanh toan don hang&accountName=$chuTaiKhoan";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Quét mã để thanh toán",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Số tiền: ${totalAmount.toInt()} đ",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.network(
                  qrUrl,
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Chủ TK: $chuTaiKhoan",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("STK: $soTaiKhoan ($nganHang)"),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    var cart = Provider.of<CartProvider>(
                      context,
                      listen: false,
                    );
                    // Lưu ý: Nếu backend của bạn có hỗ trợ truyền thêm Ghi chú, bạn có thể truyền _noteController.text vào hàm này
                    bool success = await cart.datHangTrenMobile(
                     _maKH, 
                    _noteController.text,
                    totalAmount,
                    );
                    Navigator.pop(context);
                    if (success) {
                      Navigator.pop(context);
                      _showSuccessSnackBar(
                        "Xác nhận đã thanh toán! Đang chờ duyệt.",
                      );
                    }
                  },
                  child: const Text(
                    "TÔI ĐÃ CHUYỂN KHOẢN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _noteController.dispose(); // Nhớ hủy controller mới
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "Xác nhận đơn hàng",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cart.list.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TÍNH NĂNG MỚI: ĐỊA CHỈ GIAO HÀNG ---
                        const Text(
                          "Địa chỉ nhận hàng",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDeliveryInfo(),
                        const SizedBox(height: 20),

                        // Danh sách món ăn
                        const Text(
                          "Danh sách món",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...cart.list
                            .map((item) => _buildCartItem(item, cart))
                            ,

                        // --- TÍNH NĂNG MỚI: GHI CHÚ CHO QUÁN ---
                        const SizedBox(height: 10),
                        _buildOrderNote(),
                        const SizedBox(height: 20),

                        const Text(
                          "Mã ưu đãi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildVoucherInput(),

                        const SizedBox(height: 20),
                        const Text(
                          "Phương thức thanh toán",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPaymentMethods(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildSummarySection(cart),
              ],
            ),
    );
  }

  // --- GIAO DIỆN ĐỊA CHỈ GIAO HÀNG (Giống Shopee) ---
  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _customerPhone,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _deliveryAddress,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // --- GIAO DIỆN NHẬP GHI CHÚ ---
  Widget _buildOrderNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 2,
        minLines: 1,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Ghi chú cho nhà hàng",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          icon: Icon(Icons.edit_note, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCartItem(var item, CartProvider cart) {
    String fullImageUrl = item.anhDaiDien ?? '';

    // CHỐT CHẶN: Chỉ tiến hành cắt ghép nối link nếu ảnh CHƯA CÓ chữ "http"
    if (!fullImageUrl.startsWith('http')) {
      String pathAnh = fullImageUrl.replaceAll('~', '');
      if (pathAnh.isNotEmpty && !pathAnh.startsWith('/')) {
        pathAnh = '/$pathAnh';
      }
      fullImageUrl = "https://localhost:44324$pathAnh";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              fullImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, color: Colors.grey[400]),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.tenSP,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text("Xóa món ăn?"),
                            content: Text(
                              "Bạn có chắc chắn muốn xóa '${item.tenSP}' khỏi giỏ hàng không?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "HỦY",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  cart.xoa(item.maSP);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "XÓA",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${item.donGia.toInt()} đ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _qtyBtn(Icons.remove, () => cart.giam(item.maSP)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "${item.soLuong}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _qtyBtn(
                            Icons.add,
                            () => cart.tang(item),
                            isAdd: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAdd ? Colors.red : Colors.transparent,
        ),
        child: Icon(icon, size: 16, color: isAdd ? Colors.white : Colors.black),
      ),
    );
  }

 // =========================================================================
  // 👉 KHỐI CODE ĐỒNG BỘ: VOUCHER VÀ PHƯƠNG THỨC THANH TOÁN (ĐÃ FIX NGOẶC)
  // =========================================================================
  
  Widget _buildVoucherInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Ô nhập mã Voucher bằng tay
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_outlined, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _voucherController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Nhập hoặc chọn mã giảm giá...",
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _applyVoucherLogic(_voucherController.text.trim());
                },
                child: const Text(
                  "ÁP DỤNG",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Danh sách voucher chạy ngang để ấn chọn nhanh
        _danhSachVoucher.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text("Bạn chưa có voucher nào", style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            : SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _danhSachVoucher.length,
                  itemBuilder: (context, index) {
                    var v = _danhSachVoucher[index];
                    String code = v['TenVoucher'] ?? 'VOUCHER';
                    double value = (v['GiaTri'] ?? 0).toDouble();

                    return GestureDetector(
                      onTap: () {
                        _voucherController.text = code;
                        _applyVoucherLogic(code);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(
                              "$code (-${value.toInt()}đ)",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Chép đè hàm này lên hàm cũ của bạn
  void _applyVoucherLogic(String maNhapVao) {
    if (maNhapVao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập hoặc chọn mã!")),
      );
      return;
    }

    // 👉 THÊM .trim() VÀO ĐÂY ĐỂ DỌN SẠCH KHOẢNG TRẮNG TỪ DATABASE
    var voucherHopLe = _danhSachVoucher.where(
      (v) => v['TenVoucher'].toString().trim().toUpperCase() == maNhapVao.trim().toUpperCase()
    ).firstOrNull;

    if (voucherHopLe != null) {
      setState(() {
        _giamGia = (voucherHopLe['GiaTri'] ?? 0).toDouble();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Áp dụng thành công! Đã giảm ${_giamGia.toInt()} đ"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() { _giamGia = 0; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã không hợp lệ!"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _paymentTile(
          1,
          "Thanh toán khi nhận hàng (COD)",
          Icons.payments_outlined,
          Colors.green,
        ),
        const SizedBox(height: 10),
        _paymentTile(
          2,
          "Chuyển khoản ngân hàng",
          Icons.account_balance_outlined,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _paymentTile(int value, String title, IconData icon, Color iconColor) {
    bool isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  // =========================================================================

  Widget _buildSummarySection(CartProvider cart) {
    // 👉 BẠN PHẢI DÁN 3 DÒNG NÀY VÀO ĐÂY ĐỂ TÍNH TIỀN TRƯỚC:
    double tamTinh = cart.tongThanhTien;
    double tongCong = tamTinh - _giamGia;
    if (tongCong < 0) tongCong = 0; // Đảm bảo tiền không bị âm
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tạm tính:",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                 "${tamTinh.toInt()} đ", // Đã đổi thành tamTinh cho gọn
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Phí vận chuyển:",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  "0 đ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            if (_giamGia > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Giảm giá Voucher:",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    "- ${_giamGia.toInt()} đ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TỔNG CỘNG:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${tongCong.toInt()} đ",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () async {
                  if (_paymentMethod == 2) {
                    _showQRCodeDialog(context, tongCong);
                  } else {
                    bool success = await cart.datHangTrenMobile(
                     _maKH, 
                     _noteController.text,
                     tongCong,
                    );
                    if (success) {
                      Navigator.pop(context);
                      _showSuccessSnackBar(
                        "Đặt hàng thành công! Đơn hàng đang được chuẩn bị.",
                      );
                    }
                  }
                },
                child: const Text(
                  "XÁC NHẬN ĐẶT HÀNG",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Giỏ hàng của bạn đang trống",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tiếp tục mua sắm",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
