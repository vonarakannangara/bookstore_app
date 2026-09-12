import 'package:flutter/material.dart';
import '../models/book.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});

  double get subtotal =>
      (book.isOnSale ? book.discountPrice : book.price) * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  void addToCart(Book book) {
    if (_items.containsKey(book.id)) {
      _items[book.id]!.quantity += 1;
    } else {
      _items[book.id] = CartItem(book: book);
    }
    notifyListeners();
  }

  void removeFromCart(String bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void increaseQuantity(String bookId) {
    if (_items.containsKey(bookId)) {
      _items[bookId]!.quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(String bookId) {
    if (_items.containsKey(bookId)) {
      if (_items[bookId]!.quantity > 1) {
        _items[bookId]!.quantity -= 1;
      } else {
        _items.remove(bookId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}