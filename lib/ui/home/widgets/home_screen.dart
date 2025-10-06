import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? fid;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.home),
            SizedBox(width: 8), // jarak antara icon dan text
            Text(
              "For you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5, // contoh dummy 5 postingan
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post content
                  const Text(
                    "Ini adalah contoh postingan user di aplikasi sosmed anonymous. "
                    "Kamu bisa menuliskan apapun di sini.",
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  // Post image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://picsum.photos/400/200?random=$index",
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // aksi saat tombol + ditekan
          print("Tombol + ditekan");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
