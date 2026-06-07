import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mon_an.dart';

class FavoriteItem {
  final String maSP;
  final String tenSP;
  final String anhDaiDien;
  final double donGia;
  final String moTa;
  final String maLoai;

  FavoriteItem({
    required this.maSP,
    required this.tenSP,
    required this.anhDaiDien,
    required this.donGia,
    required this.moTa,
    required this.maLoai,
  });

  factory FavoriteItem.fromMonAn(MonAn monAn) {
    return FavoriteItem(
      maSP: monAn.id,
      tenSP: monAn.tenMon,
      anhDaiDien: monAn.anhDaiDien,
      donGia: monAn.donGia,
      moTa: monAn.moTa,
      maLoai: monAn.maLoai,
    );
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      maSP: json['maSP'].toString(),
      tenSP: json['tenSP'] ?? '',
      anhDaiDien: json['anhDaiDien'] ?? '',
      donGia: (json['donGia'] as num?)?.toDouble() ?? 0,
      moTa: json['moTa'] ?? '',
      maLoai: json['maLoai']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSP': maSP,
      'tenSP': tenSP,
      'anhDaiDien': anhDaiDien,
      'donGia': donGia,
      'moTa': moTa,
      'maLoai': maLoai,
    };
  }

  MonAn toMonAn() {
    return MonAn(
      id: maSP,
      tenMon: tenSP,
      moTa: moTa,
      donGia: donGia,
      anhDaiDien: anhDaiDien,
      maLoai: maLoai,
    );
  }
}

class FavoriteProvider with ChangeNotifier {
  static const String _storageKey = 'favorite_foods';
  final List<FavoriteItem> _list = [];
  bool _loaded = false;

  List<FavoriteItem> get list => List.unmodifiable(_list);
  int get tongYeuThich => _list.length;

  bool isFavorite(String maSP) {
    return _list.any((item) => item.maSP == maSP);
  }

  Future<void> loadFavorites() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_storageKey);

    _list.clear();
    if (rawData != null && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is List) {
          _list.addAll(
            decoded
                .whereType<Map>()
                .map((item) => FavoriteItem.fromJson(Map<String, dynamic>.from(item))),
          );
        }
      } catch (e) {
        debugPrint('Lỗi đọc danh sách yêu thích: $e');
      }
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(FavoriteItem newItem) async {
    if (!_loaded) await loadFavorites();
    final index = _list.indexWhere((item) => item.maSP == newItem.maSP);

    if (index >= 0) {
      _list.removeAt(index);
    } else {
      _list.add(newItem);
    }

    notifyListeners();
    await _saveFavorites();
  }

  Future<void> them(FavoriteItem newItem) async {
    if (!_loaded) await loadFavorites();
    if (!isFavorite(newItem.maSP)) {
      _list.add(newItem);
      notifyListeners();
      await _saveFavorites();
    }
  }

  Future<void> xoa(String maSP) async {
    if (!_loaded) await loadFavorites();
    _list.removeWhere((item) => item.maSP == maSP);
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> xoaTatCa() async {
    if (!_loaded) await loadFavorites();
    _list.clear();
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = jsonEncode(_list.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, rawData);
  }
}
