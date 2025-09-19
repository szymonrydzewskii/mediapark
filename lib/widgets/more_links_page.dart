import 'package:flutter/material.dart';
import 'package:mediapark/animations/fade_in_up.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/style/app_style.dart';

class MoreLinksPage extends StatelessWidget {
  final List<SamorzadModule> modules;
  final SamorzadSzczegoly aktywnySamorzad;

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
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: AppColors.primaryLight,
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Text(
            aktywnySamorzad.name.isNotEmpty ? aktywnySamorzad.name : '',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 35.sp,
              color: Colors.black,
              height: 1.0, // nie skalujemy height w TextStyle
            ),
          ),
        ),
      ),
      body: GridView.count(
        padding: EdgeInsets.all(10.w),
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        children: modules.asMap().entries.map((entry) {
          final index = entry.key;
          final modul = entry.value;
          final alias = modul.alias.toLowerCase();
          final iconPath = 'assets/icons/$alias';

          return FadeInUpWidget(
            delay: Duration(milliseconds: index * 100),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: GestureDetector(
                onTap: () {
                  openUrlExternally(modul.url);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 50.h,
                        child: AdaptiveAssetImage(basePath: iconPath),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        alias.replaceAll('-', ' ').toUpperCase(),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
