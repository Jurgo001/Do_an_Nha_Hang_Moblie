import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/mock_data.dart';
import '../widgets/common_widgets.dart';
import 'address_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSaving = false;
  String _defaultAddress = "Đang tải...";
  int _maKH = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _maKH = prefs.getInt('maKH_logged_in') ?? 0;
    if (_maKH == 0) return;

    // Tải thông tin người dùng
    try {
      var res = await http.get(Uri.parse('https://localhost:44324/MobileApi/GetThongTinKhachHang?maKH=$_maKH'));
      if (res.statusCode == 200) {
        var jsonRes = json.decode(res.body);
        if (jsonRes['success'] == true) {
          setState(() {
            _nameController.text = jsonRes['data']['TenKH'] ?? '';
            _phoneController.text = jsonRes['data']['DienThoai'] ?? '';
            _emailController.text = jsonRes['data']['Email'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Lỗi tải thông tin: $e");
    }

    _fetchDefaultAddress();
  }

  Future<void> _fetchDefaultAddress() async {
    try {
      var res = await http.get(Uri.parse('https://localhost:44324/MobileApi/GetDanhSachDiaChi?maKH=$_maKH'));
      if (res.statusCode == 200) {
        var jsonRes = json.decode(res.body);
        List<dynamic> addresses = [];
        if (jsonRes['success'] == true && jsonRes['data'] != null) {
          addresses = jsonRes['data'];
        } else if (jsonRes is List) {
          addresses = jsonRes;
        }

        if (addresses.isNotEmpty) {
          var defaultAddr = addresses.firstWhere(
            (a) => a['LaMacDinh'] == true, 
            orElse: () => addresses.first
          );
          setState(() {
            _defaultAddress = defaultAddr['DiaChiChiTiet'] ?? defaultAddr['DiaChi'] ?? 'Chưa có địa chỉ';
          });
        } else {
          setState(() {
            _defaultAddress = "Bạn chưa có địa chỉ nào";
          });
        }
      }
    } catch (e) {
      setState(() => _defaultAddress = "Lỗi khi tải địa chỉ");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Cập nhật thông tin thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
        backgroundColor: kDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar section ──
              Center(
                child: Column(
                  children: [
                    UserAvatarWidget(
                      initials: mockUser.avatarInitials,
                      size: 90,
                      showEditIcon: true,
                      onEditTap: () {},
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn vào icon máy ảnh để thay đổi',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Form card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Họ và tên',
                      hint: 'Nhập họ và tên',
                      prefixIcon: Icons.person_outline_rounded,
                      controller: _nameController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Số điện thoại',
                      hint: 'Nhập số điện thoại',
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Nhập email',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Thay thế TextField Địa chỉ bằng Nút bấm quản lý danh sách địa chỉ
                    InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressManagementScreen(),
                          ),
                        );
                        // Gọi tải lại để update text ngay lập tức khi vừa về màn hình này
                        if (_maKH != 0) _fetchDefaultAddress();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: kPrimary, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Địa chỉ giao hàng',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _defaultAddress,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: kDark,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Save button ──
              GradientButton(
                text: 'LƯU THAY ĐỔI',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onTap: _handleSave,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
