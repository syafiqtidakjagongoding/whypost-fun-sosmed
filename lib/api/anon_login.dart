import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapp/domain/users.dart';
import 'package:mobileapp/state/user.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/utils_api.dart';
import 'package:mobileapp/state/token.dart';

Future<void> initGuestUser(WidgetRef ref) async {
  final auth = FirebaseAuth.instance;

  // 1️⃣ Login anonim jika belum
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
    final token = await getToken(null);
    ref.read(tokenProvider.notifier).state = token;
  }

  final firebaseUser = auth.currentUser!;
  final usersRef = FirebaseFirestore.instance.collection('users');
  final docRef = usersRef.doc(firebaseUser.uid);
  final snapshot = await docRef.get();

  // 2️⃣ Buat user baru di Firestore jika belum ada
  if (!snapshot.exists) {
    await docRef.set({
      'uid': firebaseUser.uid,
      'is_guest': true,
      'nickname': "Anonymous",
      'username': "anon_${Uuid().v4()}",
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  } else {
    // update timestamp
    await docRef.update({'updated_at': FieldValue.serverTimestamp()});
  }

  // 3️⃣ Ambil ulang data Firestore (supaya pasti up-to-date)
  final freshSnapshot = await docRef.get();
  final data = freshSnapshot.data()!;
  final appUser = AppUser.fromFirestore(data);

  // 4️⃣ Simpan user state dari Firestore, bukan dari auth
  ref.read(userProvider.notifier).state = appUser;

  // 5️⃣ Perbarui token
  final token = await getToken(firebaseUser.uid);
  ref.read(tokenProvider.notifier).state = token;
}

Future<void> upgradeGuest(String email, String password) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("Tidak ada guest user yang sedang login.");
  }

  final credential = EmailAuthProvider.credential(
    email: email,
    password: password,
  );

  // 🔑 Link akun anonymous dengan email/password
  final result = await user.linkWithCredential(credential);

  // UID tetap sama dengan guest sebelumnya 👌
  final uid = result.user!.uid;
  final fid = await FirebaseInstallations.instance.getId();

  final usersRef = FirebaseFirestore.instance.collection('users');
  final existing = await usersRef
      .where('installation_id', isEqualTo: fid)
      .limit(1)
      .get();

  if (existing.docs.isNotEmpty) {
    await usersRef.doc(existing.docs.first.id).update({
      'email': email,
      'is_guest': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  } else {
    // fallback: kalau somehow gak ada guest doc
    await usersRef.doc(uid).set({
      'email': email,
      'nickname': "Anonymous",
      'username': "anon_" + existing.docs.first.id,
      'is_guest': false,
      'installation_id': fid,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
