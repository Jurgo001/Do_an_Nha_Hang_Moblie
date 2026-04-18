import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/cart_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_nav_screen.dart'; // Trỏ vào thanh menu đáy
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
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
      theme: AppTheme.lightTheme, // Sử dụng theme bạn vừa gửi
      home: const MainNavScreen(), // Chạy thẳng vào màn hình có menu dưới đáy
    );
  }
}

// Class này giúp Flutter bỏ qua việc kiểm tra chứng chỉ SSL cục bộ
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
