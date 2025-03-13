class Service {
  final String id;
  final String name;
  final double price;
  bool isSelected;

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['s_name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}