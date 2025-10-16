import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/domain/users.dart';

// Provider untuk menyimpan token
final userProvider = StateProvider<AppUser?>((ref) => null);

final userPostsProvider = FutureProvider<List<Posts>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];
  return fetchPostsByUserId(user.uid);
});

