import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
 String? fid;

 @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
           Text("Search"),
          ],
        ),
      )
       
    );
  }
}
