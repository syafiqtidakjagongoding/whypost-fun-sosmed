import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/state/token.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

Future<void> createPost({
  required String content,
  required WidgetRef ref,
  required BuildContext context,
  List<File>? images,
}) async {
  final messenger = ScaffoldMessenger.of(context); // ✅ ambil sebelum await
  try {
    final user = FirebaseAuth.instance.currentUser;
    final fid = await FirebaseInstallations.instance.getId();

    // 🔹 Upload semua gambar ke Storage (jika ada)
    List<String> imageUrls = [];
    if (images != null && images.isNotEmpty) {
      for (var img in images) {
        final String fName = await uploadFileToR2(ref, messenger, img);
        imageUrls.add("https://bucket.syafiq-paradisam.my.id/$fName");
      }
    }

    // 🔹 Simpan ke Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'user_id':
          user?.uid ??
          fid, // pakai uid kalau login, fallback ke installation ID
      'content': content,
      'images': imageUrls, // bisa kosong []
      'created_at': FieldValue.serverTimestamp(),
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('✅ Postingan berhasil dibuat'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // biar melayang
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('❌ Postingan gagal dibuat'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // biar melayang
        duration: Duration(seconds: 2),
      ),
    );
    rethrow;
  }
}

Future<String> uploadFileToR2(
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  File file,
) async {
  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
  final token = ref.watch(tokenProvider); // ambil token global`
  final response = await http.get(
    Uri.parse(
      "https://presign-worker.syafiq-paradisam.my.id/get-presigned?filename=$fileName",
    ),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final url = data['url'] as String;
    final bytes = await file.readAsBytes();
    final uploadResp = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": mimeType, // atau sesuai type file
      },
      body: bytes,
    );

    if (uploadResp.statusCode != 200) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('❌ Gambar gagal di posting'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // biar melayang
          duration: Duration(seconds: 2),
        ),
      );
    }
  } else {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('❌ Gambar gagal di posting'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // biar melayang
        duration: Duration(seconds: 2),
      ),
    );
  }

  return fileName;
}


