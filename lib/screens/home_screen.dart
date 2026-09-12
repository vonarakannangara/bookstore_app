import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('books').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong. Please try again.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allBooks = snapshot.data!.docs
                .map((doc) => Book.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();

            final saleBooks = allBooks.where((b) => b.isOnSale).toList();
            final bestSellers = allBooks.where((b) => b.isBestSeller).toList();
            final newArrivals = allBooks.where((b) => b.isNewArrival).toList();

            return ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(gradient: AppColors.logoGradient),
                  child: Row(
                    children: const [
                      Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
                      SizedBox(width: 10),
                      Text(
                        'Chapterly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Center(
                    child: Text(
                      '"A reader lives a thousand lives before he dies."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: AppColors.darkBlue.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
                if (saleBooks.isNotEmpty)
                  _BookSection(title: 'Sales', books: saleBooks, showDiscount: true),
                if (newArrivals.isNotEmpty)
                  _BookSection(title: 'New Arrivals', books: newArrivals),
                if (bestSellers.isNotEmpty)
                  _BookSection(title: 'Best Sellers', books: bestSellers),
                if (saleBooks.isEmpty && bestSellers.isEmpty && newArrivals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No books available yet.')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookSection extends StatelessWidget {
  final String title;
  final List<Book> books;
  final bool showDiscount;

  const _BookSection({
    required this.title,
    required this.books,
    this.showDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                  );
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: book.imageUrl.isNotEmpty
                              ? Image.network(
                            book.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.lightBlue,
                              child: const Icon(Icons.menu_book_rounded, size: 40, color: AppColors.aqua),
                            ),
                          )
                              : Container(
                            color: AppColors.lightBlue,
                            child: const Icon(Icons.menu_book_rounded, size: 40, color: AppColors.aqua),
                          ),
                        ),
                        if (showDiscount && book.isOnSale)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pink,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'SALE',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                          child: Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: showDiscount && book.isOnSale
                              ? Row(
                            children: [
                              Text(
                                'Rs. ${book.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Rs. ${book.discountPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.pink),
                              ),
                            ],
                          )
                              : Text(
                            'Rs. ${book.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}