import 'package:flutter/material.dart';

class LienHeForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController hoTenController;
  final TextEditingController emailController;
  final TextEditingController sdtController;
  final TextEditingController noiDungController;

  final String chuDe;
  final List<String> chuDeOptions;
  final bool isLoading;

  final VoidCallback onSubmit;
  final Function(String?) onChuDeChanged;

  const LienHeForm({
    super.key,
    required this.formKey,
    required this.hoTenController,
    required this.emailController,
    required this.sdtController,
    required this.noiDungController,
    required this.chuDe,
    required this.chuDeOptions,
    required this.isLoading,
    required this.onSubmit,
    required this.onChuDeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gửi Tin Nhắn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 24),

            /// Họ tên + Email (responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;

                return isWide
                    ? Row(
                        children: [
                          Expanded(child: _nameField()),
                          const SizedBox(width: 12),
                          Expanded(child: _emailField()),
                        ],
                      )
                    : Column(
                        children: [
                          _nameField(),
                          const SizedBox(height: 16),
                          _emailField(),
                        ],
                      );
              },
            ),

            const SizedBox(height: 16),

            _phoneField(),
            const SizedBox(height: 16),

            _chuDeField(),
            const SizedBox(height: 16),

            _messageField(),
            const SizedBox(height: 24),

            _submitButton(),
          ],
        ),
      ),
    );
  }

  // ================= FIELD =================

  Widget _nameField() {
    return _buildField(
      label: 'Họ tên',
      hint: 'Nhập tên của bạn',
      controller: hoTenController,
      validator: (v) =>
          v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
    );
  }

  Widget _emailField() {
    return _buildField(
      label: 'Email',
      hint: 'email@vidu.com',
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Vui lòng nhập email';
        if (!v.contains('@')) return 'Email không hợp lệ';
        return null;
      },
    );
  }

  Widget _phoneField() {
    return _buildField(
      label: 'Số điện thoại',
      hint: 'Số điện thoại liên hệ',
      controller: sdtController,
      keyboardType: TextInputType.phone,
      validator: (v) =>
          v == null || v.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
    );
  }

  Widget _messageField() {
    return _buildField(
      label: 'Nội dung',
      hint: 'Nội dung tin nhắn...',
      controller: noiDungController,
      maxLines: 4,
      validator: (v) =>
          v == null || v.isEmpty ? 'Vui lòng nhập nội dung' : null,
    );
  }

  Widget _chuDeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Chủ đề'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: chuDe,
          decoration: _inputDecoration('Chọn chủ đề'),
          items: chuDeOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChuDeChanged,
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onSubmit,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send, size: 18),
        label: Text(
          isLoading ? 'Đang gửi...' : 'Gửi Ngay',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          disabledBackgroundColor: Colors.grey[300],
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
    );
  }

  // ================= COMPONENT CHUNG =================

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}