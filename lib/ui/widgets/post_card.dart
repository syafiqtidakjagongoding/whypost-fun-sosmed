import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/ui/widgets/post_images.dart';

class PostCard extends StatefulWidget {
  final Posts post; // ✅ terima data post lewat constructor

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState(); // ✅ buat State
}

class _PostCardState extends State<PostCard> {
  late Posts post;
  bool isLiked = false;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked; // ✅ ubah state saat ditekan
    });
  }

  @override
  void initState() {
    super.initState();
    post = widget.post; // ✅ akses dari widget
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 10),
                // Expanded supaya area nickname + time memenuhi sisa ruang
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama user di kiri
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              post.nickname ?? "Anonymous",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "@${post.username ?? ''}",
                                overflow: TextOverflow
                                    .ellipsis, // tampil jadi "panjangsekaliuse..."
                                maxLines: 1, // penting biar satu baris aja
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Waktu di kanan
                      Text(
                        timeago.format(post.createdAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Konten teks
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 8),

            PostImages(images: post.images),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                  ), // ganti ke Icons.favorite kalau sudah like
                  color: Colors.red,
                  onPressed: () {
                    toggleLike();
                  },
                ),
                Text(
                  post.totalLiked.toString(), // contoh jumlah like
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),

                // 💬 Comment Button
                IconButton(
                  icon: Icon(Icons.comment_outlined),
                  color: Colors.grey[700],
                  onPressed: () {
                    // TODO: Navigasi ke kolom komentar
                    print('Comment pressed');
                  },
                ),
                Text(
                  post.totalComment.toString(),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),

                // 📤 Share Button
                IconButton(
                  icon: Icon(Icons.share),
                  color: Colors.grey[700],
                  onPressed: () {
                    // TODO: Bagikan postingan
                    print('Share pressed');
                  },
                ),
                Text(
                  post.totalShare.toString(),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
