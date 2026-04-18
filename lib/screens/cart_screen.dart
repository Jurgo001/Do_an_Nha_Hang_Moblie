import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Biến lưu mã voucher và phương thức thanh toán
  final TextEditingController _voucherController = TextEditingController();
  int _paymentMethod = 1; // 1: Nhận hàng trả tiền (COD), 2: Chuyển khoản

void _showQRCodeDialog(BuildContext context, double totalAmount) {
  // THAY THÔNG TIN CỦA BẠN VÀO ĐÂY


   String nganHang = "Sacombank"; // Tên ngân hàng (vietcombank, mbbank, acb...)
   String soTaiKhoan = "0123456789"; // Số tài khoản thật của bạn
   String chuTaiKhoan = "Dang Quang Minh"; // Tên bạn (viết hoa không dấu)
  
  // Tạo link VietQR (Tự động chèn số tiền và nội dung)
  String qrUrl = "https://img.vietqr.io/image/$nganHang-$soTaiKhoan-compact.png?amount=${totalAmount.toInt()}&addInfo=Thanh toan don hang&accountName=$chuTaiKhoan";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Quét mã để thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Số tiền: ${totalAmount.toInt()} đ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            
            // HIỂN THỊ MÃ QR
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
              child: Image.network(qrUrl, height: 250, width: 250, fit: BoxFit.contain),
            ),
            
            const SizedBox(height: 20),
            Text("Chủ TK: $chuTaiKhoan", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("STK: $soTaiKhoan ($nganHang)"),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  // Sau khi khách bấm "Tôi đã chuyển", mới gọi API đặt hàng
                  var cart = Provider.of<CartProvider>(context, listen: false);
                  bool success = await cart.datHangTrenMobile(_voucherController.text, 2);
                  Navigator.pop(context); // Đóng mã QR
                  if (success) {
                    Navigator.pop(context); // Quay về Home
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xác nhận đã thanh toán! Đang chờ duyệt."), backgroundColor: Colors.green));
                  }
                },
                child: const Text("TÔI ĐÃ CHUYỂN KHOẢN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Nền xám nhạt cực sang
      appBar: AppBar(
        title: const Text("Giỏ hàng của bạn", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
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
                        // Danh sách món ăn
                        ...cart.list.map((item) => _buildCartItem(item, cart)).toList(),
                        
                        const SizedBox(height: 20),
                        
                        // Mã giảm giá
                        const Text("Mã ưu đãi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        _buildVoucherInput(),

                        const SizedBox(height: 20),

                        // Phương thức thanh toán
                        const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        _buildPaymentMethods(),
                        
                        const SizedBox(height: 20), // Khoảng trống cuộn
                      ],
                    ),
                  ),
                ),
                // Khung Tổng tiền & Đặt hàng cố định bên dưới
                _buildSummarySection(cart),
              ],
            ),
    );
  }

  // --- 1. GIAO DIỆN TỪNG MÓN ĂN TRONG GIỎ (CÓ NÚT XÓA) ---
  Widget _buildCartItem(var item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ảnh món
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              "https://localhost:44324${item.anhDaiDien}",
              width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80, height: 80, color: Colors.grey[200],
                child: Icon(Icons.fastfood, color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Thông tin & Nút Tăng/Giảm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.tenSP, maxLines: 2, overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    // NÚT THÙNG RÁC XÓA MÓN
                    GestureDetector(
                      onTap: () => cart.xoa(item.maSP),
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item.donGia.toInt()} đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                    // Nút tăng giảm số lượng
                    Container(
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          _qtyBtn(Icons.remove, () => cart.giam(item.maSP)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text("${item.soLuong}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          _qtyBtn(Icons.add, () => cart.tang(item), isAdd: true),
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
        decoration: BoxDecoration(shape: BoxShape.circle, color: isAdd ? Colors.red : Colors.transparent),
        child: Icon(icon, size: 16, color: isAdd ? Colors.white : Colors.black),
      ),
    );
  }

  // --- 2. GIAO DIỆN NHẬP VOUCHER ---
  Widget _buildVoucherInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _voucherController,
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Nhập mã giảm giá..."),
            ),
          ),
          TextButton(
            onPressed: () {
              // Xử lý báo áp dụng thành công ảo cho đẹp
              if (_voucherController.text.isNotEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Áp dụng mã thành công!")));
              }
            },
            child: const Text("ÁP DỤNG", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 3. GIAO DIỆN CHỌN PHƯƠNG THỨC THANH TOÁN ---
  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _paymentTile(1, "Thanh toán khi nhận hàng (COD)", Icons.payments_outlined, Colors.green),
        const SizedBox(height: 10),
        _paymentTile(2, "Chuyển khoản ngân hàng", Icons.account_balance_outlined, Colors.blue),
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
          border: Border.all(color: isSelected ? Colors.red : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. KHUNG TỔNG TIỀN VÀ NÚT ĐẶT HÀNG Ở ĐÁY MÀN HÌNH ---
  Widget _buildSummarySection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tạm tính:", style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text("${cart.tongThanhTien.toInt()} đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phí vận chuyển:", style: TextStyle(color: Colors.grey, fontSize: 16)),
                Text("0 đ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG CỘNG:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${cart.tongThanhTien.toInt()} đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 20),
            
            // NÚT ĐẶT HÀNG
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Nút đỏ đặc trưng
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                // Trong hàm onPressed của nút XÁC NHẬN ĐẶT HÀNG
                onPressed: () async {
                  if (_paymentMethod == 2) {
                    // Nếu chọn Chuyển khoản (2), hiện mã QR trước
                    _showQRCodeDialog(context, cart.tongThanhTien);
                  } else {
                    // Nếu chọn COD (1), đặt hàng luôn
                    bool success = await cart.datHangTrenMobile(_voucherController.text, _paymentMethod);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🎉 Đặt hàng thành công!"), backgroundColor: Colors.green)
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("XÁC NHẬN ĐẶT HÀNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÀN HÌNH GIỎ HÀNG TRỐNG ---
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Giỏ hàng của bạn đang trống", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tiếp tục mua sắm", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}