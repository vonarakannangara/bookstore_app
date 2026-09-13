import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import 'book_detail_screen.dart';

enum SortOption { alphabetical, priceLowHigh, priceHighLow }

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  String _searchQuery = '';
  String _selectedGenre = 'All';
  SortOption _sortOption = SortOption.alphabetical;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text('Browse Books'),
        backgroundColor: AppColors.aqua,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: AppColors.aqua,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title or author',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('books').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Something went wrong. Please try again.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBooks = snapshot.data!.docs
                    .map((doc) =>
                    Book.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                    .toList();

                final genres = <String>{'All'};
                for (final b in allBooks) {
                  genres.add(b.genre);
                }

                var filteredBooks = _searchQuery.isEmpty
                    ? allBooks
                    : allBooks.where((book) {
                  return book.title.toLowerCase().contains(_searchQuery) ||
                      book.author.toLowerCase().contains(_searchQuery);
                }).toList();

                if (_selectedGenre != 'All') {
                  filteredBooks = filteredBooks
                      .where((b) => b.genre == _selectedGenre)
                      .toList();
                }

                switch (_sortOption) {
                  case SortOption.alphabetical:
                    filteredBooks.sort((a, b) =>
                        a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                    break;
                  case SortOption.priceLowHigh:
                    filteredBooks.sort((a, b) => a.price.compareTo(b.price));
                    break;
                  case SortOption.priceHighLow:
                    filteredBooks.sort((a, b) => b.price.compareTo(a.price));
                    break;
                }

                return Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGenre,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Genre',
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: genres
                                  .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedGenre = value ?? 'All');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<SortOption>(
                              initialValue: _sortOption,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Sort by',
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: SortOption.alphabetical,
                                  child: Text('A - Z',
                                      overflow: TextOverflow.ellipsis),
                                ),
                                DropdownMenuItem(
                                  value: SortOption.priceLowHigh,
                                  child: Text('Price: Low-High',
                                      overflow: TextOverflow.ellipsis),
                                ),
                                DropdownMenuItem(
                                  value: SortOption.priceHighLow,
                                  child: Text('Price: High-Low',
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() =>
                                _sortOption = value ?? SortOption.alphabetical);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredBooks.isEmpty
                          ? const Center(child: Text('No books found.'))
                          : GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        BookDetailScreen(book: book)),
                              );
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: book.imageUrl.isNotEmpty
                                        ? Image.network(
                                      book.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                          Container(
                                            color: AppColors.lightBlue,
                                            child: const Icon(
                                                Icons.menu_book_rounded,
                                                size: 48,
                                                color: AppColors.aqua),
                                          ),
                                    )
                                        : Container(
                                      color: AppColors.lightBlue,
                                      child: const Icon(
                                          Icons.menu_book_rounded,
                                          size: 48,
                                          color: AppColors.aqua),
                                    ),
                                  ),
                                  if (book.isOnSale)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 6, 10, 0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.pink,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'SALE',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 8, 10, 4),
                                    child: Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 0, 10, 2),
                                    child: Text(
                                      book.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 0, 10, 10),
                                    child: book.isOnSale
                                        ? Row(
                                      children: [
                                        Text(
                                          'Rs. ${book.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            decoration:
                                            TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Rs. ${book.discountPrice.toStringAsFixed(0)}',
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              color: AppColors.pink,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                        : Text(
                                      'Rs. ${book.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}