import 'package:flutter/material.dart';

class LienHeBanner extends StatelessWidget {
  const LienHeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Layer 1: Ảnh network
        SizedBox(
          width: double.infinity,
          height: 280,
          child: Image.network(
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1920&q=80',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFF2D3436),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF2D3436),
            ),
          ),
        ),

        // Layer 2: Overlay tối để chữ dễ đọc
        Container(
          width: double.infinity,
          height: 280,
          color: Colors.black.withOpacity(0.45),
        ),

        // Layer 3: Nội dung chữ
        const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Liên Hệ Với Chúng Tôi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Sẵn sàng lắng nghe và phục vụ bạn tốt hơn',
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}