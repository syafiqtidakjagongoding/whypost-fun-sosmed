import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/state/postNotifier.dart';
import 'package:mobileapp/state/user.dart';
import 'package:mobileapp/ui/widgets/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() {
    final user = ref.read(userProvider);
    // fetch hanya saat pertama kali masuk, tidak setiap navigasi
    if (user != null && user.uid.isNotEmpty) {
      if (ref.read(postsProvider).isEmpty) {
        ref.read(postsProvider.notifier).fetch(user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('For you'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
        titleTextStyle: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetch();
        },
        child: posts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(), // penting!
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(post: post);
                },
              ),
      ),
    );
  }
}
