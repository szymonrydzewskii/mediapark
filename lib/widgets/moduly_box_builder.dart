import 'package:flutter/material.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/services/samorzad_details_service.dart';
import 'package:mediapark/widgets/webview_page.dart';
import 'package:mediapark/widgets/more_links_page.dart';

List<String> externalAliases = [
  'facebook',
  'youtube',
  'instagram',
  'portal-x'
];

List<Widget> buildModulyBoxy(
  BuildContext context,
  List<SamorzadModule> modules,
) {
  final zwykle = modules.where((m) => !externalAliases.contains(m.alias)).toList();
  final zewnetrzne = modules.where((m) => externalAliases.contains(m.alias)).toList();

  final List<Widget> boxy = zwykle.map((modul) {
    final alias = modul.alias.toLowerCase();
    final iconPath = 'assets/icons/$alias.jpg';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              url: modul.url,
              title: modul.alias.replaceAll('-', ' ').toUpperCase(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: AdaptiveAssetImage(
                  basePath: iconPath,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                alias.replaceAll('-', ' ').toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }).toList();

  if (zewnetrzne.isNotEmpty) {
    boxy.add(
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoreLinksPage(modules: zewnetrzne),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[800]!, Colors.grey[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'WIĘCEJ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return boxy;
}
