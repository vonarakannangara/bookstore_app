import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nicController = TextEditingController();
  final _addressController = TextEditingController();

  String? _gender;
  DateTime? _dob;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      _nameController.text = data?['name'] ?? '';
      _phoneController.text = data?['phone'] ?? '';
      _nicController.text = data?['nic'] ?? '';
      _addressController.text = data?['address'] ?? '';
      _gender = (data?['gender'] ?? '').toString().isEmpty ? null : data?['gender'];
      final dobString = data?['dob'] ?? '';
      if (dobString.isNotEmpty) {
        final parts = dobString.split('-');
        if (parts.length == 3) {
          _dob = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      }
    } catch (e) {
      // Fields stay empty if loading fails - user can fill them in
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    final user = AuthService().currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    final dobString =
        '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}';

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _gender,
        'dob': dobString,
        'nic': _nicController.text.trim(),
        'address': _addressController.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.aqua,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: AppColors.aqua,
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.person_outline), text: 'Account'),
                  Tab(icon: Icon(Icons.receipt_long_outlined), text: 'My Orders'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ACCOUNT TAB
                  _isLoadingProfile
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.aqua,
                                child: Icon(Icons.person, size: 28, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  user?.email ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(_isEditing ? Icons.close : Icons.edit,
                                    color: AppColors.aqua),
                                onPressed: () => setState(() => _isEditing = !_isEditing),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) => (_isEditing && (v == null || v.trim().isEmpty))
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) {
                              if (!_isEditing) return null;
                              if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                              if (v.trim().length < 9) return 'Enter a valid mobile number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          IgnorePointer(
                            ignoring: !_isEditing,
                            child: DropdownButtonFormField<String>(
                              initialValue: _gender,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: const Icon(Icons.wc_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Male', child: Text('Male')),
                                DropdownMenuItem(value: 'Female', child: Text('Female')),
                                DropdownMenuItem(value: 'Other', child: Text('Other')),
                                DropdownMenuItem(
                                    value: 'Prefer not to say', child: Text('Prefer not to say')),
                              ],
                              onChanged: _isEditing ? (value) => setState(() => _gender = value) : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _isEditing ? _pickDob : null,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                prefixIcon: const Icon(Icons.cake_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                _dob == null
                                    ? 'Not set'
                                    : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nicController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'NIC Number',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) {
                              if (!_isEditing) return null;
                              if (v == null || v.trim().isEmpty) return 'NIC number is required';
                              final nic = v.trim();
                              final oldFormat = RegExp(r'^[0-9]{9}[vVxX]$');
                              final newFormat = RegExp(r'^[0-9]{12}$');
                              if (!oldFormat.hasMatch(nic) && !newFormat.hasMatch(nic)) {
                                return 'Enter a valid NIC (9 digits + V, or 12 digits)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressController,
                            enabled: _isEditing,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) => (_isEditing && (v == null || v.trim().isEmpty))
                                ? 'Address is required'
                                : null,
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.aqua,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _isSaving ? null : _saveProfile,
                                child: _isSaving
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => AuthService().signOut(),
                              icon: const Icon(Icons.logout, color: Colors.redAccent),
                              label:
                              const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ORDERS TAB
                  user == null
                      ? const Center(child: Text('Please log in to view your orders.'))
                      : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong. Please try again.'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final orders = snapshot.data!.docs;

                      if (orders.isEmpty) {
                        return const Center(child: Text('You have no orders yet.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final data = orders[index].data() as Map<String, dynamic>;
                          final items = (data['items'] as List<dynamic>? ?? []);
                          final status = data['status'] ?? 'pending';
                          final total = (data['total'] ?? 0).toDouble();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${items.length} item(s)',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.aqua,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status.toString().toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ...items.map((item) {
                                    final map = item as Map<String, dynamic>;
                                    return Text(
                                      '• ${map['title']} x${map['quantity']}',
                                      style: const TextStyle(fontSize: 13),
                                    );
                                  }),
                                  const SizedBox(height: 6),
                                  Text('Total: Rs. ${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}