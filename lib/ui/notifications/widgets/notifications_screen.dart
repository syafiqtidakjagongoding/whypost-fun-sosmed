import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // jumlah tab
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              Icon(Icons.notifications),
              SizedBox(width: 8), // jarak antara icon dan text
              Text(
                "Notifications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Semua"),
              Tab(text: "Sebutan"),
              Tab(text: "Like"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text("Daftar semua notifikasi")),
            Center(child: Text("Notifikasi sebutan kamu")),
            Center(child: Text("Notifikasi likes")),
          ],
        ),
      ),
    );
  }
}
