import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_provider.dart';
import 'screens/home_screen.dart';
import 'dart:io';

// 1. THÊM CLASS NÀY ĐỂ VƯỢT RÀO BẢO MẬT SSL CỦA LOCALHOST
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // 2. KHỞI TẠO LÕI FLUTTER (Bắt buộc phải có trước khi chạy app)
  WidgetsFlutterBinding.ensureInitialized();

  // 3. KÍCH HOẠT CHỨNG CHỈ ẢO
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    // Bọc toàn bộ app bằng MultiProvider
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const NhaHangApp(),
    ),
  );
}

class NhaHangApp extends StatelessWidget {
  const NhaHangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Nhà Hàng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}
