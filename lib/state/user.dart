import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/domain/users.dart';

final userProvider = StateProvider<AppUser?>((ref) => null);

final postsByUserProvider = StreamProvider.family<List<Posts>, String>((
  ref,
  userId,
) {
  return streamPostsByUserId(userId);
});

final likedPostsStreamProvider = StreamProvider<List<Posts>>((ref) async* {
  final user = ref.watch(userProvider);
  if (user == null) {
    yield [];
    return;
  }

  // Ambil semua like user ini secara realtime
  final likesStream = FirebaseFirestore.instance
      .collection('like_post')
      .where('user_id', isEqualTo: user.uid)
      .snapshots();

  await for (final likeSnapshot in likesStream) {
    if (likeSnapshot.docs.isEmpty) {
      yield [];
      continue;
    }

    final likedPostIds = likeSnapshot.docs
        .map((doc) => doc['post_id'] as String)
        .toList();

    // Buat list untuk gabung semua batch
    List<Posts> allPosts = [];

    // Pecah batch (maks 10 per query Firestore)
    final batches = <List<String>>[];
    for (var i = 0; i < likedPostIds.length; i += 10) {
      batches.add(
        likedPostIds.sublist(
          i,
          i + 10 > likedPostIds.length ? likedPostIds.length : i + 10,
        ),
      );
    }

    for (var batch in batches) {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: batch)
          .snapshots()
          .first; // ambil data pertama saja (karena loop sudah di Stream utama)

      final userIds = postsSnapshot.docs
          .map((doc) => doc['user_id'] as String)
          .toSet()
          .toList();

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: userIds)
          .get();

      final userMap = {
        for (var doc in usersSnapshot.docs) doc['uid']: doc.data(),
      };

      final posts = postsSnapshot.docs.map((doc) {
        final data = doc.data();
        final userId = data['user_id'] as String;
        final userData = userMap[userId];
        return Posts.fromFirestore(
          doc.id,
          data,
          userData: userData,
          isLikedByMe: true,
        );
      }).toList();

      allPosts.addAll(posts);
    }

    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield allPosts;
  }
});

final bookmarkPostsStreamProvider = StreamProvider<List<Posts>>((ref) async* {
  final user = ref.watch(userProvider);
  if (user == null) {
    yield [];
    return;
  }

  // 1️⃣ Ambil semua bookmark user ini secara realtime
  final bookmarksStream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('bookmarks')
      .snapshots();

  await for (final bookmarkSnapshot in bookmarksStream) {
    if (bookmarkSnapshot.docs.isEmpty) {
      yield [];
      continue;
    }

    final bookmarkedPostIds = bookmarkSnapshot.docs
        .map((doc) => doc['post_id'] as String)
        .toList();

    // 2️⃣ Bagi menjadi batch (maks 10 per query Firestore)
    final batches = <List<String>>[];
    for (var i = 0; i < bookmarkedPostIds.length; i += 10) {
      batches.add(
        bookmarkedPostIds.sublist(
          i,
          i + 10 > bookmarkedPostIds.length ? bookmarkedPostIds.length : i + 10,
        ),
      );
    }

    // 3️⃣ Ambil data semua post berdasarkan batch
    List<Posts> allPosts = [];
    for (final batch in batches) {
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: batch)
          .get(); // ❗ pakai .get() bukan .snapshots().first

      final userIds = postsSnapshot.docs
          .map((doc) => doc['user_id'] as String)
          .toSet()
          .toList();

      // 4️⃣ Ambil info user dari batch user_id
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: userIds)
          .get();

      final userMap = {
        for (var doc in usersSnapshot.docs) doc['uid']: doc.data(),
      };

      // 5️⃣ Bentuk objek Posts lengkap
      final posts = postsSnapshot.docs.map((doc) {
        final data = doc.data();
        final userId = data['user_id'] as String;
        final userData = userMap[userId];

        return Posts.fromFirestore(
          doc.id,
          data,
          userData: userData,
          isBookmarked: true,
        );
      }).toList();

      allPosts.addAll(posts);
    }

    // 6️⃣ Urutkan berdasarkan tanggal terbaru
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 7️⃣ Emit hasil ke StreamProvider
    yield allPosts;
  }
});
