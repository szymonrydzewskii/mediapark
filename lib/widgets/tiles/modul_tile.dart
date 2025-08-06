// lib/widgets/tiles/modul_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/screens/budzet_obywatelski_screen.dart';
import 'package:mediapark/screens/ogloszenia_screen.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/widgets/webview_page.dart';
import 'package:mediapark/screens/konsultacje_screen.dart';

class ModulTile extends StatelessWidget {
  final SamorzadModule modul;
  final SamorzadSzczegoly samorzad;

  const ModulTile({super.key, required this.modul, required this.samorzad});

  @override
  Widget build(BuildContext context) {
    final alias = modul.alias.toLowerCase();
    final iconPath = 'assets/icons/$alias';
    final words =
        alias
            .replaceAll('-', ' ')
            .split(' ')
            .where((w) => w.trim().isNotEmpty)
            .toList();

    String cap(String w) =>
        w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase();

    String buildTitle(List<String> ws) {
      if (ws.isEmpty) return '';
      if (ws.length == 1) return cap(ws[0]);

      // domyślnie: nie łamiemy linii
      int breakAt = -1;

      // jeśli 2. słowo ma >= 3 litery – łamiemy przed nim
      if (ws[1].length >= 3) {
        breakAt = 1;
      }

      // złożenie wyniku
      final left = ws
          .take(breakAt == -1 ? ws.length : breakAt)
          .map(cap)
          .join(' ');
      final right = breakAt == -1 ? '' : ws.skip(breakAt).map(cap).join(' ');
      return breakAt == -1 ? left : '$left\n$right';
    }

    final title = buildTitle(words);
    final isTwoLines = title.contains('\n');

    return GestureDetector(
      onTap: () {
        final page =
            alias == 'budzet-obywatelski'
                ? BudzetObywatelskiScreen(modul: modul, samorzad: samorzad)
                : alias == 'konsultacje-spoleczne'
                ? const KonsultacjeScreen()
                : alias == 'ogloszenia'
                ? OgloszeniaScreen(
                  idInstytucji:
                      modul.url.split('/').contains('i')
                          ? modul.url.split(
                            '/',
                          )[modul.url.split('/').indexOf('i') + 1]
                          : '10',
                )
                : WebViewPage(url: modul.url, title: title);

        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: SizedBox(
        width: 175.w,
        height: 205.h,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCAECF4),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFCAECF4),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Spacer(), // pcha w dół
                // Ikona
                SizedBox(
                  width: 60.w,
                  height: 60.h,
                  child: AdaptiveAssetImage(basePath: iconPath),
                ),
                // Odstęp między ikoną a tekstem – nieco mniejszy przy 2 liniach
                SizedBox(height: 12.h),

                // Tekst (2 linie max, wyśrodkowany)
                Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                  ),
                ),
                const Spacer(), // pcha w górę
              ],
            ),
          ),
        ),
      ),
    );
  }
}
