// lib/widgets/tiles/modul_tile.dart
import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/screens/budzet_obywatelski_screen.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/widgets/webview_page.dart';
import 'package:mediapark/screens/konsultacje_screen.dart';

class ModulTile extends StatelessWidget {
  final SamorzadModule modul;

  const ModulTile({super.key, required this.modul});

  @override
  Widget build(BuildContext context) {
    final alias = modul.alias.toLowerCase();
    final iconPath = 'assets/icons/$alias.jpg';
    final title = alias.replaceAll('-', ' ').toUpperCase().trim();

    return GestureDetector(
      onTap: () {
        final page =
            alias == 'budzet-obywatelski'
                ? BudzetObywatelskiScreen(modul: modul)
                : alias == 'konsultacje-spoleczne'
                ? const KonsultacjeScreen()
                : WebViewPage(url: modul.url, title: title);

        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFD6F4FE),
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
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
