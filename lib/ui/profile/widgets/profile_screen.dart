import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Anonymous",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text("Total posts : 0"),
                      Text("Likes : 10"),
                    ],
                  )
                ],
              ),
            ),

            // 🔹 TabBar
            const TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Your posts"),
                Tab(text: "Likes"),
              ],
            ),

            // 🔹 TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  // 👉 Tab Postingan
                  ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Postingan anonim ke-${index + 1}"),
                        ),
                      );
                    },
                  ),

                  // 👉 Tab Likes
                  ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text("Anda menyukai postingan #${index + 1}"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
