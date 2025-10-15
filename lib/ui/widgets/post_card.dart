import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/ui/widgets/post_images.dart';

class PostCard extends StatelessWidget {
  final Posts post;

  const PostCard({Key? key, required this.post}) : super(key: key);

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
                                post.username ?? "",
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
            Text(post.content),
            const SizedBox(height: 8),

            PostImages(images: post.images),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
