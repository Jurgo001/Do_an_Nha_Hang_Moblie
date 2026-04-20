import 'package:flutter/material.dart';
import 'widgets/LienHe_banner.dart';
import 'widgets/LienHe_thongTin.dart';
import 'widgets/LienHe_form.dart';
import 'widgets/LienHe_map.dart';
import 'dart:async';

class LienHePage extends StatefulWidget {
  const LienHePage({super.key});

  @override
  State<LienHePage> createState() => _LienHePageState();
}

class _LienHePageState extends State<LienHePage> {
  final _formKey = GlobalKey<FormState>();

  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _sdtController = TextEditingController();
  final _noiDungController = TextEditingController();

  String _chuDe = 'Khác';
  bool _isLoading = false;

  final List<String> _chuDeOptions = [
    'Góp ý món ăn',
    'Thái độ phục vụ',
    'Đặt tiệc',
    'Khác',
  ];

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _sdtController.dispose();
    _noiDungController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thành công!'),
        content: const Text('Đã gửi tin nhắn'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LienHeBanner(),

            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const LienHeThongTin(),
                      LienHeForm(
                        formKey: _formKey,
                        hoTenController: _hoTenController,
                        emailController: _emailController,
                        sdtController: _sdtController,
                        noiDungController: _noiDungController,
                        chuDe: _chuDe,
                        chuDeOptions: _chuDeOptions,
                        isLoading: _isLoading,
                        onSubmit: _submitForm,
                        onChuDeChanged: (v) => setState(() => _chuDe = v!),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const LienHeMap(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}