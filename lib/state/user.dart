import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider untuk menyimpan token
final userProvider = StateProvider<User?>((ref) => null);
