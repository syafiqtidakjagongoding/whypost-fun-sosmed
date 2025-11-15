import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/auth_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/instance.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mobileapp/state/token.dart';
import 'routing/router.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(Phoenix(child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDeepLinks();
    });
  }

  void _setupDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((Uri uri) async {
      print("DEEP LINK: $uri");

      final code = uri.queryParameters['code'];
      if (code != null) {
        await _handleOAuthCode(code);
      }
    });
  }

  Future<void> _handleOAuthCode(String code) async {
    final instance = ref.read(instanceProvider);
    final accToken = await getAccessToken(
      instanceBaseUrl: instance!.url,
      clientId: instance.clientId,
      clientSecret: instance.clientSecret,
      code: code,
    );
    // Lanjut proses tukar token...
    final repo = ref.read(tokenRepoProvider);
    await repo.saveToken(accToken!);
    await repo.saveInstanceUrl(instance.url);
    // ignore: use_build_context_synchronously
    Phoenix.rebirth(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "WhyPost App",
      routerConfig: router,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          primary: Color.fromRGBO(255, 117, 31, 1),
          seedColor: Colors.white,
        ),
        useMaterial3: true,
      ),
    );
  }
}
