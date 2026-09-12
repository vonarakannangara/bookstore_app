import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book; // null means "Add new", non-null means "Edit"
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _genreController;
  late final TextEditingController _discountPriceController;
  bool _isOnSale = false;
  bool _isBestSeller = false;
  bool _isNewArrival = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _priceController = TextEditingController(text: b != null ? b.price.toString() : '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _imageUrlController = TextEditingController(text: b?.imageUrl ?? '');
    _genreController = TextEditingController(text: b?.genre ?? '');
    _discountPriceController =
        TextEditingController(text: b != null && b.discountPrice > 0 ? b.discountPrice.toString() : '');
    _isOnSale = b?.isOnSale ?? false;
    _isBestSeller = b?.isBestSeller ?? false;
    _isNewArrival = b?.isNewArrival ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _genreController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'description': _descriptionController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
      'genre': _genreController.text.trim(),
      'isOnSale': _isOnSale,
      'discountPrice': _isOnSale && _discountPriceController.text.trim().isNotEmpty
          ? double.parse(_discountPriceController.text.trim())
          : 0.0,
      'isBestSeller': _isBestSeller,
      'isNewArrival': _isNewArrival,
    };

    try {
      if (widget.book == null) {
        await FirebaseFirestore.instance.collection('books').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.book!.id)
            .update(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.book == null ? 'Book added' : 'Book updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add Book'),
        backgroundColor: AppColors.aqua,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Author is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Price (Rs.)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid price greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Genre is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('On Sale'),
                value: _isOnSale,
                activeThumbColor: AppColors.pink,
                onChanged: (v) => setState(() => _isOnSale = v),
              ),
              if (_isOnSale)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _discountPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Discounted Price (Rs.)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (!_isOnSale) return null;
                      if (v == null || v.trim().isEmpty) return 'Discount price required when on sale';
                      final parsed = double.tryParse(v.trim());
                      final regularPrice = double.tryParse(_priceController.text.trim()) ?? 0;
                      if (parsed == null || parsed <= 0) return 'Enter a valid discount price';
                      if (parsed >= regularPrice) return 'Discount price must be less than regular price';
                      return null;
                    },
                  ),
                ),
              SwitchListTile(
                title: const Text('Best Seller'),
                value: _isBestSeller,
                activeThumbColor: AppColors.aqua,
                onChanged: (v) => setState(() => _isBestSeller = v),
              ),
              SwitchListTile(
                title: const Text('New Arrival'),
                value: _isNewArrival,
                activeThumbColor: AppColors.aqua,
                onChanged: (v) => setState(() => _isNewArrival = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.aqua,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveBook,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Update Book' : 'Add Book', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}