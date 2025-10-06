import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routing/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/fid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await syncUserToFirestore(); // << langsung sync ke Firestore
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Untraced App",
      routerConfig: router,
    );
  }
}
