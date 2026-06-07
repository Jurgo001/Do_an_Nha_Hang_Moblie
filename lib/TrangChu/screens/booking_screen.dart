import '../../constants.dart';
import 'package:flutter/material.dart';
import '../widgets/shared/app_form_field.dart';
import '../widgets/shared/success_view.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _guests = '2 người';
  DateTime? _selectedDate;
  bool _submitted = false;

  static const _guestOptions = [
    '1 người',
    '2 người',
    '3 người',
    '4 người',
    'Trên 5 người',
  ];

  Future<void> _pickDate() async {
    final picked = await _showDateTimePicker();
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<DateTime?> _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (date == null) return null;
    if (!mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _submitted = true);
    }
  }

  void _reset() {
    setState(() {
      _submitted = false;
      _nameCtrl.clear();
      _emailCtrl.clear();
      _noteCtrl.clear();
      _selectedDate = null;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kDark,
        title: const Text(
          'Đặt Bàn',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _submitted
          ? SuccessView(onReset: _reset)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kDark, Color(0xFF1a2744)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đặt Bàn',
            style: TextStyle(
              color: kPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Giữ Chỗ Trực Tuyến',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đặt bàn ngay hôm nay để đảm bảo chỗ ngồi tốt nhất.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppFormField(
            controller: _nameCtrl,
            label: 'Tên của bạn',
            icon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
          ),
          const SizedBox(height: 14),
          AppFormField(
            controller: _emailCtrl,
            label: 'Email của bạn',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildDatePicker(),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _guests,
            decoration: InputDecoration(
              labelText: 'Số khách',
              prefixIcon: const Icon(Icons.group_outlined, color: kPrimary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimary),
              ),
            ),
            items: _guestOptions.map((g) {
              return DropdownMenuItem(value: g, child: Text(g));
            }).toList(),
            onChanged: (v) => setState(() => _guests = v!),
          ),
          const SizedBox(height: 14),
          AppFormField(
            controller: _noteCtrl,
            label: 'Ghi chú thêm',
            icon: Icons.note_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Xác Nhận Đặt Bàn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: kPrimary),
            const SizedBox(width: 10),
            Text(
              _selectedDate == null
                  ? 'Chọn Ngày & Giờ hẹn'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  '
                        '${_selectedDate!.hour.toString().padLeft(2, '0')}:'
                        '${_selectedDate!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey[400] : kDark,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
