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
      // 4️⃣ Ambil data bookmark user ini
      final bookmarkSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .where('post_id', whereIn: batch)
          .get();

      final bookmarkedIds = bookmarkSnapshot.docs
          .map((doc) => doc['post_id'] as String)
          .toSet();

      final posts = postsSnapshot.docs.map((doc) {
        final data = doc.data();
        final userId = data['user_id'] as String;
        final userData = userMap[userId];
        final isBookmarkedByMe = bookmarkedIds.contains(doc.id);

        return Posts.fromFirestore(
          doc.id,
          data,
          userData: userData,
          isLikedByMe: true,
          isBookmarked: isBookmarkedByMe,
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

  // 1️⃣ Stream realtime untuk bookmarks user
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

    List<Posts> allPosts = [];

    // 3️⃣ Loop tiap batch
    for (final batch in batches) {
      // 🔸 Ambil posts yang di-bookmark
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      // 🔸 Ambil semua user_id unik
      final userIds = postsSnapshot.docs
          .map((doc) => doc['user_id'] as String)
          .toSet()
          .toList();

      // 🔸 Ambil data user (creator)
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: userIds)
          .get();

      final userMap = {
        for (var doc in usersSnapshot.docs) doc['uid']: doc.data(),
      };

      // 🔸 Cek mana post yang user like
      final likeSnapshot = await FirebaseFirestore.instance
          .collection('like_post')
          .where('user_id', isEqualTo: user.uid)
          .where('post_id', whereIn: batch)
          .get();

      final likedIds = likeSnapshot.docs
          .map((doc) => doc['post_id'] as String)
          .toSet();

      // 🔸 Bangun objek post lengkap
      final posts = postsSnapshot.docs.map((doc) {
        final data = doc.data();
        final userId = data['user_id'] as String;
        final userData = userMap[userId];
        final postId = doc.id;

        return Posts.fromFirestore(
          postId,
          data,
          userData: userData,
          isLikedByMe: likedIds.contains(postId),
          isBookmarked: true,
        );
      }).toList();

      allPosts.addAll(posts);
    }

    // 4️⃣ Urutkan berdasarkan tanggal terbaru
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 5️⃣ Emit hasil setiap kali ada perubahan bookmark
    yield allPosts;
  }
});
