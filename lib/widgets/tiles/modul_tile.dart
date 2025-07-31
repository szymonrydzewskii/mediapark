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
    final title = alias.replaceAll('-', ' ').toUpperCase().trim();

    return GestureDetector(
      onTap: () {
        final page =
            alias == 'budzet-obywatelski'
                ? BudzetObywatelskiScreen(modul: modul, samorzad: samorzad,)
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
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCAECF4),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80.w,
                height: 80.h,
                child: AdaptiveAssetImage(basePath: iconPath),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
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
