import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> likePost(String userId, String postId) async {
  try {
    final docId = '${userId}_$postId'; // 🔸 kombinasi unik
    final likeRef = FirebaseFirestore.instance
        .collection('like_post')
        .doc(docId);

    await likeRef.set({
      'user_id': userId,
      'post_id': postId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

     // 2️⃣ Increment total_liked di dokumen post
    final postRef = FirebaseFirestore.instance.collection("posts").doc(postId);
    await postRef.update({
      "total_liked": FieldValue.increment(1),
    });

    print('✅ Berhasil like post $postId oleh user $userId');
  } catch (e) {
    print('❌ Gagal like post: $e');
    rethrow;
  }
}

Future<void> unlikePost(String userId, String postId) async {
  try {
    final docId = '${userId}_$postId';
    final likeRef = FirebaseFirestore.instance
        .collection('like_post')
        .doc(docId);

    await likeRef.delete();

    // 2️⃣ Increment total_liked di dokumen post
    final postRef = FirebaseFirestore.instance.collection("posts").doc(postId);
    await postRef.update({
      "total_liked": FieldValue.increment(-1),
    });

    print('✅ Unlike berhasil untuk post $postId oleh user $userId');
  } catch (e) {
    print('❌ Gagal unlike post: $e');
    rethrow;
  }
}
