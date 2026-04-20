import 'package:flutter/material.dart';
// Tạm tắt dòng import google_maps_flutter
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPreviewWidget extends StatelessWidget {
  const MapPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạm thời hiển thị một cái khung xám thay cho bản đồ thật
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          "Bản đồ Google Maps (Sẽ gắn API Key sau)",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}