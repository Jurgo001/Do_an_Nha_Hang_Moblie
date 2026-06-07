// ============================================================
// Mock Data – dùng làm dữ liệu giả cho toàn bộ module
// ============================================================

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String avatarInitials;
  final int loyaltyPoints;
  final String memberTier; // "Vàng" | "Bạc" | "Đồng"
  final int totalOrders;
  final int voucherCount;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.avatarInitials,
    required this.loyaltyPoints,
    required this.memberTier,
    required this.totalOrders,
    required this.voucherCount,
  });
}

class OrderModel {
  final String orderId;
  final DateTime orderDate;
  final double total;
  final String status; // "Đã thanh toán" | "Đang giao" | "Đã hủy"
  final List<OrderItemModel> items;

  const OrderModel({
    required this.orderId,
    required this.orderDate,
    required this.total,
    required this.status,
    required this.items,
  });
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class VoucherModel {
  final String code;
  final String title;
  final String description;
  final bool isUsed;
  final DateTime redeemedDate;
  final int pointsCost;

  const VoucherModel({
    required this.code,
    required this.title,
    required this.description,
    required this.isUsed,
    required this.redeemedDate,
    required this.pointsCost,
  });
}

// ---- Mock instances ----

final mockUser = UserModel(
  id: 'KH001',
  name: 'Lê Minh Khoa',
  phone: '0911111111',
  email: 'khoa@gmail.com',
  address: '123 Nguyễn Trãi, Quận 1, TP.HCM',
  avatarInitials: 'LK',
  loyaltyPoints: 270,
  memberTier: 'Bạc',
  totalOrders: 1,
  voucherCount: 0,
);

final mockOrders = [
  OrderModel(
    orderId: '#1',
    orderDate: DateTime(2026, 4, 17, 15, 26),
    total: 275000,
    status: 'Đã thanh toán',
    items: const [
      OrderItemModel(name: 'Gà nướng mật ong', quantity: 1, price: 150000),
      OrderItemModel(name: 'Cơm chiên dương châu', quantity: 2, price: 62500),
    ],
  ),
  OrderModel(
    orderId: '#2',
    orderDate: DateTime(2026, 4, 10, 12, 0),
    total: 185000,
    status: 'Đã thanh toán',
    items: const [
      OrderItemModel(name: 'Bò lúc lắc', quantity: 1, price: 185000),
    ],
  ),
];

final mockVouchers = [
  VoucherModel(
    code: 'GIAM10K',
    title: 'Giảm 10.000đ',
    description: 'Áp dụng cho đơn từ 100.000đ',
    isUsed: false,
    redeemedDate: DateTime(2026, 4, 1),
    pointsCost: 100,
  ),
  VoucherModel(
    code: 'FREESHIP',
    title: 'Miễn phí giao hàng',
    description: 'Không giới hạn đơn hàng',
    isUsed: true,
    redeemedDate: DateTime(2026, 3, 15),
    pointsCost: 150,
  ),
];

// Gift vouchers available for exchange
final mockGiftVouchers = [
  {
    'title': 'Giảm 10.000đ',
    'points': 100,
    'desc': 'Đơn từ 100K',
    'color': 0xFF00B894,
  },
  {
    'title': 'Giảm 20.000đ',
    'points': 200,
    'desc': 'Đơn từ 150K',
    'color': 0xFFFF6B6B,
  },
  {
    'title': 'Miễn phí ship',
    'points': 150,
    'desc': 'Mọi đơn hàng',
    'color': 0xFF6C5CE7,
  },
  {
    'title': 'Giảm 50.000đ',
    'points': 500,
    'desc': 'Đơn từ 300K',
    'color': 0xFFFFC107,
  },
];
