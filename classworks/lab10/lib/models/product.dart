class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'];
    final ratingMap = ratingData is Map ? ratingData : {};

    final idValue = json['id'];
    final priceValue = json['price'];
    final ratingValue = ratingMap['rate'];
    final countValue = ratingMap['count'];

    final originalCategory = json['category'] is String
        ? json['category'] as String
        : '';

    String categoryName;

    switch (originalCategory) {
      case 'electronics':
        categoryName = 'Электроника';
        break;
      case 'jewelery':
        categoryName = 'Әшекейлер';
        break;
      case "men's clothing":
        categoryName = 'Ерлер киімі';
        break;
      case "women's clothing":
        categoryName = 'Әйелдер киімі';
        break;
      default:
        categoryName = 'Басқа';
    }

    return Product(
      id: idValue is num ? idValue.toInt() : 0,
      title: json['title'] is String
          ? json['title'] as String
          : 'Атауы жоқ тауар',
      price: priceValue is num ? priceValue.toDouble() : 0.0,
      description: json['description'] is String
          ? json['description'] as String
          : 'Сипаттама жоқ',
      category: categoryName,
      imageUrl: json['image'] is String
          ? json['image'] as String
          : '',
      rating: ratingValue is num ? ratingValue.toDouble() : 0.0,
      reviewCount: countValue is num ? countValue.toInt() : 0,
    );
  }
}