import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/ui/instance/widgets/RulesRenderer.dart';
import 'package:mobileapp/ui/utils/InstanceLink.dart';
import 'package:url_launcher/url_launcher.dart';
import 'TermsRenderer.dart';

class InstanceAuthPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> instanceData;
  final Map<String, dynamic> authInstanceInfo;

  const InstanceAuthPage({
    super.key,
    required this.instanceData,
    required this.authInstanceInfo,
  });

  @override
  ConsumerState<InstanceAuthPage> createState() => _InstanceAuthPage();
}

class _InstanceAuthPage extends ConsumerState<InstanceAuthPage> {
  late Map<String, dynamic> instanceData;
  late Map<String, dynamic> authInstanceInfo;

  Future<void> _handleAuthorizationToServer() async {
    final redirectUri = dotenv.get("REDIRECT_URI");
    final authUrl = Uri.https(instanceData['uri'], "/oauth/authorize", {
      'response_type': 'code',
      'client_id': authInstanceInfo['client_id'],
      'redirect_uri': redirectUri,
      'scope': 'read write follow push',
    });

    print("Auth URL: $authUrl");

    // nanti kamu bisa buka ini memakai url_launcher:
    await launchUrl(authUrl, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();
    instanceData = widget.instanceData;
    authInstanceInfo = widget.authInstanceInfo;
  }

  @override
  Widget build(BuildContext context) {
    final title = instanceData['title'] ?? instanceData['uri'] ?? 'Unknown';
    final description = instanceData['short_description'] ?? '';
    final uri = instanceData['uri'] ?? '';
    final thumbnail = instanceData['thumbnail'];
    final registrations = instanceData['registrations'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (thumbnail != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(thumbnail),
                    backgroundColor: Colors.grey[200],
                  ),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (description.isNotEmpty)
                  Html(
                    data: description,
                    style: {
                      "body": Style(
                        fontSize: FontSize(15),
                        color: Colors.grey[800],
                        textAlign: TextAlign.center,
                      ),
                      "b": Style(fontWeight: FontWeight.bold),
                      "i": Style(fontStyle: FontStyle.italic),
                      "p": Style(margin: Margins.only(bottom: 8)),
                    },
                  ),
                if (uri.isNotEmpty) InstanceLink(uri: uri),
                const SizedBox(height: 24),

                RulesRenderer(rules: instanceData['rules']),
                TermsRenderer(
                  htmlTerms: instanceData['terms'],
                  textFallback: instanceData['terms_text'],
                ),

                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _handleAuthorizationToServer,
                      label: const Text("Next"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
