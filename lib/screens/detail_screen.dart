import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/mon_an.dart';
import '../models/cart_provider.dart';

// Lưu ý: Đảm bảo các màu sắc này đã được định nghĩa
const Color primaryColor = Colors.red;
const Color warningColor = Colors.orange;
const Color darkTextColor = Color(0xFF333333);

class DetailScreen extends StatefulWidget {
  final MonAn monAn;
  const DetailScreen({super.key, required this.monAn});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // --- BIẾN TRẠNG THÁI ---
  late Future<dynamic> _detailsFuture;
  late String mainImageUrl;
  bool isFavorite = false;
  int _currentRating = 5;
  File? _selectedImage;
  final _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    mainImageUrl = widget.monAn.anhDaiDien;
    _detailsFuture = fetchChiTietMonTuAPI(widget.monAn.id);
  }

  // --- HÀM XỬ LÝ LOGIC (API) ---

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    String base64Image = "";
    if (_selectedImage != null) {
      base64Image = base64Encode(_selectedImage!.readAsBytesSync());
    }

    try {
      final url = Uri.parse('https://localhost:44324/MobileApi/GuiBinhLuan');
      final response = await http.post(
        url,
        body: {
          'maMon': widget.monAn.id,
          'tenKH': 'Khách hàng', // Sau này lấy tên từ tài khoản đăng nhập
          'noiDung': _commentController.text,
          'soSao': _currentRating.toString(),
          'hinhAnhBase64': base64Image,
        },
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        // Xóa trắng form nhập
        _commentController.clear();

        setState(() {
          _selectedImage = null;
          _currentRating = 5;
          // QUAN TRỌNG: Yêu cầu load lại toàn bộ chi tiết và cmt mới từ API
          _detailsFuture = fetchChiTietMonTuAPI(widget.monAn.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gửi đánh giá thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  Future<dynamic> fetchChiTietMonTuAPI(String id) async {
    final url = Uri.parse(
      'https://localhost:44324/MobileApi/GetChiTietMon?id=$id',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Lỗi API Chi tiết: $e");
    }
    return null;
  }

  // --- GIAO DIỆN CHÍNH ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.monAn.tenMon),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gallery ảnh
            _buildGallerySection(),

            // 2. Thông tin cơ bản (Tên, Giá, Mô tả)
            _buildBasicInfoSection(),

            const Divider(thickness: 1, height: 30),

            // 3. Hiển thị đánh giá trung bình và danh sách bình luận từ DB
            FutureBuilder<dynamic>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  // Trong FutureBuilder, phần snapshot.hasData:
                  var data = snapshot.data;
                  List<dynamic> listCmt =
                      data['BinhLuans'] ?? []; // Lấy đúng tên biến từ C#

                  return Column(
                    children: [
                      _buildRatingSummary(
                        data['DiemTrungBinh'],
                        data['TongDanhGia'],
                      ),

                      // Phần hiển thị danh sách bình luận
                      if (listCmt.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Món này chưa có ai bình luận hết Hào ơi!",
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listCmt.length,
                          itemBuilder: (context, index) {
                            var cmt = listCmt[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              // Kiểm tra đúng tên cột trong SQL của bạn
                              title: Text(cmt['TenNguoiGui'] ?? "Ẩn danh"),
                              subtitle: Text(cmt['NoiDung'] ?? ""),
                              trailing: Text(
                                "${cmt['SoSao'] ?? 5} ⭐",
                              ), // Tránh lỗi nếu SoSao bị NULL
                            );
                          },
                        ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),

            const Divider(thickness: 1, height: 30),

            // 4. Form nhập bình luận mới
            _buildCommentInputSection(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Text(
                "Món ăn nổi bật",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 5. Danh sách món bán chạy
            _buildFeaturedList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- CÁC HÀM XÂY DỰNG GIAO DIỆN CON (NẰM TRONG CLASS STATE) ---

  Widget _buildGallerySection() {
    return Image.network(
      mainImageUrl,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 280,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.monAn.tenMon,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.monAn.donGia.toInt()} đ",
            style: const TextStyle(
              fontSize: 22,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.monAn.moTa,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(dynamic diem, dynamic tong) {
    double score = (diem is num) ? diem.toDouble() : 5.0;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 18,
                    color: index < score.round()
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              Text(
                "($tong đánh giá thực tế)",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(List<dynamic> comments) {
    if (comments.isEmpty) return const SizedBox();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length > 5 ? 5 : comments.length,
      itemBuilder: (context, index) {
        var cmt = comments[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            cmt['TenNguoiGui'] ?? "Ẩn danh",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cmt['NoiDung'] ?? ""),
              if (cmt['HinhAnhBinhLuan'] != null &&
                  cmt['HinhAnhBinhLuan'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(cmt['HinhAnhBinhLuan']),
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Text(
            "${cmt['SoSao'] ?? 5} ⭐",
            style: const TextStyle(color: Colors.orange),
          ),
        );
      },
    );
  }

  Widget _buildCommentInputSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gửi đánh giá của bạn",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _currentRating = index + 1),
                icon: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: "Món ăn thế nào bạn ơi?",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Thêm ảnh"),
              ),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitComment,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text("Gửi", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedList() {
    return FutureBuilder<List<MonAn>>(
      future: fetchMonAn(), // Đảm bảo hàm này nằm trong mon_an.dart
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final list = snapshot.data!.take(5).toList();
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(monAn: item)),
                ),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.anhDaiDien,
                          height: 100,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.tenMon,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${item.donGia.toInt()} đ",
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () => setState(() => isFavorite = !isFavorite),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).tang(
                  CartItem(
                    maSP: widget.monAn.id,
                    tenSP: widget.monAn.tenMon,
                    anhDaiDien: widget.monAn.anhDaiDien,
                    donGia: widget.monAn.donGia,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm vào giỏ!")),
                );
              },
              child: const Text(
                "THÊM VÀO GIỎ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} // <--- ĐÂY LÀ DẤU ĐÓNG CLASS QUAN TRỌNG NHẤT
