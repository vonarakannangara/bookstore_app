import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> signUp(
      String email,
      String password, {
        required String name,
        required String phone,
        required String gender,
        required String dob,
        required String nic,
        required String address,
      }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'email': email.trim(),
        'role': 'customer',
        'name': name.trim(),
        'phone': phone.trim(),
        'gender': gender,
        'dob': dob,
        'nic': nic.trim(),
        'address': address.trim(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Signup failed';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'customer';
      } else {
        final email = _auth.currentUser?.email ?? '';
        await _db.collection('users').doc(uid).set({
          'email': email,
          'role': 'customer',
          'name': '',
          'phone': '',
          'gender': '',
          'dob': '',
          'nic': '',
          'address': '',
        });
        return 'customer';
      }
    } catch (e) {
      return 'customer';
    }
  }

  Future<void> signOut() => _auth.signOut();
}