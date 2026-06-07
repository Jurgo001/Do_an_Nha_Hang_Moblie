import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'constants.dart'; // Dùng màu sắc của giao diện mới
import 'models/cart_provider.dart'; // Giữ lại giỏ hàng cũ
import 'models/favorite_provider.dart'; // Lưu danh sách món yêu thích
import 'TrangChu/navigation/main_screen.dart'; // Gọi Thanh menu mới

// Bắt buộc giữ lại để C# không bị lỗi trắng màn hình
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const NhaHangNgonApp(),
    ),
  );
}

class NhaHangNgonApp extends StatelessWidget {
  const NhaHangNgonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhà Hàng Ngon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const MainScreen(),
    );
  }
}
