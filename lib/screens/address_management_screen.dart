import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _addresses = [];
  int _maKH = 0;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? maKH = prefs.getInt('maKH_logged_in');
    
    if (maKH == null || maKH == 0) {
      setState(() => _isLoading = false);
      return;
    }
    
    _maKH = maKH;

    try {
      var response = await http.get(
        Uri.parse('https://localhost:44324/MobileApi/GetDanhSachDiaChi?maKH=$_maKH')
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        // Hỗ trợ cả API trả về mảng trực tiếp hoặc mảng gói trong key 'data'
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
           setState(() {
              _addresses = jsonResponse['data'];
           });
        } else if (jsonResponse is List) {
           setState(() {
              _addresses = jsonResponse;
           });
        }
      }
    } catch (e) {
      print("Lỗi tải danh sách địa chỉ: $e");
    }
    
    setState(() => _isLoading = false);
  }

  // Hàm dùng chung cho cả Thêm Mới và Sửa Địa Chỉ
  void _showAddressBottomSheet({Map<String, dynamic>? addressToEdit}) {
    final bool isEditing = addressToEdit != null;
    
    final TextEditingController nameController = TextEditingController(text: isEditing ? addressToEdit['TenNguoiNhan'] : '');
    final TextEditingController phoneController = TextEditingController(text: isEditing ? addressToEdit['SoDienThoai'] : '');
    // API có thể trả về 'DiaChiChiTiet' hoặc 'DiaChi' tùy phiên bản, ta bắt cả 2
    final TextEditingController addressController = TextEditingController(text: isEditing ? (addressToEdit['DiaChiChiTiet'] ?? addressToEdit['DiaChi']) : '');
    bool isDefault = isEditing ? (addressToEdit['LaMacDinh'] == true) : false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? "Cập nhật địa chỉ" : "Thêm địa chỉ mới",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDark),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Tên người nhận",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Số điện thoại",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: "Nhập địa chỉ chi tiết (VD: 140 Lê Trọng Tấn...)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isDefault,
                        activeColor: kPrimary,
                        onChanged: (val) {
                          setModalState(() {
                            isDefault = val ?? false;
                          });
                        },
                      ),
                      const Text(
                        "Đặt làm địa chỉ mặc định",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty || 
                            phoneController.text.trim().isEmpty || 
                            addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
                          );
                          return;
                        }
                        
                        Navigator.pop(context); // Đóng bottom sheet
                        setState(() => _isLoading = true);

                        try {
                          String endpoint = isEditing ? 'SuaDiaChiGiaoHang' : 'ThemDiaChiGiaoHang';
                          Map<String, dynamic> payload = {
                            "MaKH": _maKH,
                            "TenNguoiNhan": nameController.text.trim(),
                            "SoDienThoai": phoneController.text.trim(),
                            "DiaChiChiTiet": addressController.text.trim(),
                            "LaMacDinh": isDefault,
                          };

                          if (isEditing) {
                            payload["MaDiaChi"] = addressToEdit['MaDiaChi'];
                          }

                          var response = await http.post(
                            Uri.parse('https://localhost:44324/MobileApi/$endpoint'),
                            headers: {"Content-Type": "application/json"},
                            body: json.encode(payload),
                          );

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEditing ? "Cập nhật địa chỉ thành công!" : "Thêm địa chỉ thành công!"), backgroundColor: Colors.green),
                            );
                            _fetchAddresses(); // Tải lại danh sách
                          }
                        } catch (e) {
                          print("Lỗi thêm địa chỉ: $e");
                          setState(() => _isLoading = false);
                        }
                      },
                      child: Text(
                        isEditing ? "CẬP NHẬT ĐỊA CHỈ" : "LƯU ĐỊA CHỈ", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        title: const Text('Quản lý địa chỉ'),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    // Phân biệt UI cho dòng địa chỉ mặc định
                    final isDefault = address['LaMacDinh'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDefault ? Colors.red.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDefault ? kPrimary.withOpacity(0.5) : Colors.grey.shade200,
                          width: isDefault ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on, 
                              color: isDefault ? kPrimary : Colors.grey.shade400,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "Địa chỉ giao hàng",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: kDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Badge (Nhãn) màu đỏ cho địa chỉ mặc định
                                      if (isDefault)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: kPrimary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "Mặc định",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (address['TenNguoiNhan'] != null && address['SoDienThoai'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        "${address['TenNguoiNhan']} | ${address['SoDienThoai']}",
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                                      ),
                                    ),
                                  Text(
                                    address['DiaChiChiTiet'] ?? address['DiaChi'] ?? 'Không có thông tin địa chỉ',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Nút Sửa địa chỉ (Góc phải)
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, color: kPrimary, size: 28),
                              onPressed: () => _showAddressBottomSheet(addressToEdit: address),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      // Nút Floating Action Button (+) góc dưới cùng bên phải
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressBottomSheet(), // Gọi hàm không truyền data tức là Thêm mới
        backgroundColor: kPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Bạn chưa có địa chỉ nào",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}