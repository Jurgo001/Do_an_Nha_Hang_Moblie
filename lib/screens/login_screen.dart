import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/common_widgets.dart';
import 'register_screen.dart';
import '../TrangChu/navigation/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Bật hiệu ứng xoay xoay loading
    setState(() => _isLoading = true);

    try {
      // 1. GỌI API ĐĂNG NHẬP LÊN SERVER C#
      // (Lưu ý: Thay 'DangNhap' thành đúng tên API mà nhóm bạn viết bên C#)
      var response = await http.post(
        Uri.parse('https://localhost:44324/MobileApi/DangNhap'), 
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "Email": _emailController.text,     // Lấy email user nhập
          "Password": _passwordController.text // Lấy pass user nhập
        }),
      );

      // Tắt hiệu ứng loading khi đã có phản hồi từ server
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        // NẾU ĐĂNG NHẬP THÀNH CÔNG (Server báo success = true)
        if (jsonResponse['success'] == true) {
          
          // Lấy Mã Khách Hàng từ API trả về (Cần khớp với cấu trúc JSON của backend)
          int maKH = jsonResponse['data']['MaKH'];

          // --- PHẦN KÉT SẮT ---
          // Mở két sắt ra và cất MaKH vào với chìa khóa 'maKH_logged_in'
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('maKH_logged_in', maKH);
          // --------------------

          if (mounted) {
            // Hiện thông báo xanh lá góc dưới
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đăng nhập thành công!"), 
                backgroundColor: Colors.green,
              ),
            );
            // Chuyển về màn hình MainScreen để có thanh điều hướng
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        } 
        // NẾU SAI PASS HOẶC EMAIL (Server báo success = false)
        else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(jsonResponse['message'] ?? "Sai tài khoản hoặc mật khẩu!"), 
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Lỗi 404, 500,... từ server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi máy chủ!"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      // Lỗi do chưa bật Visual Studio, sai IP, hoặc sập mạng
      setState(() => _isLoading = false);
      print("Lỗi kết nối: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể kết nối đến Server!"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Logo ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kPrimary, kPrimary.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nhà Hàng Ngon',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Welcome text ──
                    const Text(
                      'Xin chào! 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Đăng nhập để tiếp tục thưởng thức món ngon.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Email / Phone ──
                    CustomTextField(
                      label: 'Email hoặc Số điện thoại',
                      hint: 'Nhập email hoặc số điện thoại',
                      prefixIcon: Icons.person_outline_rounded,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Vui lòng nhập email hoặc số điện thoại';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Password ──
                    CustomTextField(
                      label: 'Mật khẩu',
                      hint: 'Nhập mật khẩu',
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixWidget: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: _obscurePassword
                              ? Colors.grey[400]
                              : kPrimary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Remember + Forgot ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _rememberMe
                                      ? kPrimary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _rememberMe
                                        ? kPrimary
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: _rememberMe
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ghi nhớ tôi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Login button ──
                    GradientButton(
                      text: 'ĐĂNG NHẬP',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: _isLoading,
                      onTap: _handleLogin,
                    ),

                    const SizedBox(height: 28),

                    // ── Divider ──
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Hoặc tiếp tục với',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Social buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: Icons.facebook_rounded,
                          color: const Color(0xFF1877F2),
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          color: const Color(0xFFEA4335),
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: Icons.phone_iphone_rounded,
                          color: kDark,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Register link ──
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chưa có tài khoản? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Đăng ký ngay',
                              style: TextStyle(
                                color: kPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Social Icon Button ───
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
