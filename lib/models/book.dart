class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final String description;
  final String imageUrl;
  final String genre;
  final bool isOnSale;
  final double discountPrice;
  final bool isBestSeller;
  final bool isNewArrival;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.genre,
    required this.isOnSale,
    required this.discountPrice,
    required this.isBestSeller,
    required this.isNewArrival,
  });

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      genre: data['genre'] ?? 'General',
      isOnSale: data['isOnSale'] ?? false,
      discountPrice: (data['discountPrice'] ?? 0).toDouble(),
      isBestSeller: data['isBestSeller'] ?? false,
      isNewArrival: data['isNewArrival'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'genre': genre,
      'isOnSale': isOnSale,
      'discountPrice': discountPrice,
      'isBestSeller': isBestSeller,
      'isNewArrival': isNewArrival,
    };
  }
}