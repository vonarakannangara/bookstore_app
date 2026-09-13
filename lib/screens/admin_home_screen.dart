import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'add_edit_book_screen.dart';
import 'manage_users_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
        appBar: AppBar(
          title: const Text('Manage Books'),
          backgroundColor: AppColors.aqua,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Manage Users',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => AuthService().signOut(),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.pink,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong. Please try again.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs
              .map((doc) => Book.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          if (books.isEmpty) {
            return const Center(child: Text('No books yet. Tap + to add one.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final lowStock = book.stock <= 3;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 45,
                      height: 60,
                      child: book.imageUrl.isNotEmpty
                          ? Image.network(
                        book.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.menu_book_rounded),
                      )
                          : const Icon(Icons.menu_book_rounded),
                    ),
                  ),
                  title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${book.author} • Rs. ${book.price.toStringAsFixed(2)}'),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: lowStock ? Colors.redAccent : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.stock == 0 ? 'Out of stock' : '${book.stock} in stock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: lowStock ? FontWeight.bold : FontWeight.normal,
                              color: lowStock ? Colors.redAccent : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.aqua),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddEditBookScreen(book: book)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Book'),
                              content: Text('Delete "${book.title}"? This cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('books')
                                  .doc(book.id)
                                  .delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${book.title} deleted')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to delete. Please try again.')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}