import 'package:flutter/material.dart';
import 'package:mediapark/animations/fade_in_up.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mediapark/widgets/custom_appbar.dart';

class MoreLinksPage extends StatelessWidget {
  final List<SamorzadModule> modules;
  final Samorzad aktywnySamorzad;

  const MoreLinksPage({
    super.key,
    required this.modules,
    required this.aktywnySamorzad,
  });

  @override
  Widget build(BuildContext context) {
    void openUrlExternally(String url) async {
      final cleanedUrl = url.trim();

      try {
        await launchUrlString(cleanedUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nie można otworzyć linku: $cleanedUrl")),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: CustomAppBar(
        active: aktywnySamorzad,
        onLogoTap: () => () {},
        onSettings: () => pokazUstawienia(context),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(10),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children:
            modules.asMap().entries.map((entry) {
              final index = entry.key;
              final modul = entry.value;
              final alias = modul.alias.toLowerCase();
              final iconPath = 'assets/icons/$alias.jpg';

              return FadeInUpWidget(
                delay: Duration(milliseconds: index * 100),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      openUrlExternally(modul.url);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFB5D7E4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: AdaptiveAssetImage(basePath: iconPath),
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
                ),
              );
            }).toList(),
      ),
    );
  }
}
