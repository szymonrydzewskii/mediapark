// lib/widgets/more_links_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/widgets/webview_page.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/helpers/url_launcher_helper.dart';

class MoreLinksPage extends StatelessWidget {
  final List<SamorzadModule> modules;
  final SamorzadSzczegoly aktywnySamorzad;

  const MoreLinksPage({
    super.key,
    required this.modules,
    required this.aktywnySamorzad,
  });

  Future<void> _openModule(BuildContext context, SamorzadModule modul) async {
    final alias = modul.alias.toLowerCase();

    // Sprawdź, czy to link zewnętrzny (social media)
    if (UrlLauncherHelper.shouldOpenExternally(alias)) {
      if (modul.url.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brak dostępnego linku'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Otwórz w aplikacji zewnętrznej lub przeglądarce
      final launched = await UrlLauncherHelper.launchExternalUrl(modul.url);

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nie można otworzyć linku'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Dla pozostałych - otwórz w WebView
    if (modul.url.isNotEmpty && context.mounted) {
      final title = _buildTitle(alias);
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => WebViewPage(url: modul.url, title: title),
        ),
      );
    }
  }

  String _buildTitle(String alias) {
    final words =
        alias
            .replaceAll('-', ' ')
            .split(' ')
            .where((w) => w.trim().isNotEmpty)
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .toList();
    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Więcej linków',
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 0.85,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final modul = modules[index];
              final alias = modul.alias.toLowerCase();
              final iconPath = 'assets/icons/$alias';
              final title = _buildTitle(alias);

              return GestureDetector(
                onTap: () => _openModule(context, modul),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60.w,
                        height: 60.h,
                        child: AdaptiveAssetImage(basePath: iconPath),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
