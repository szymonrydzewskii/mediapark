import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/webview_page.dart';

class OAplikacjiScreen extends StatefulWidget {
  const OAplikacjiScreen({super.key});

  @override
  State<OAplikacjiScreen> createState() => _OAplikacjiScreenState();
}

class _OAplikacjiScreenState extends State<OAplikacjiScreen> {
  static const backgroundColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: Transform.translate(
          offset: Offset(8.w, 0),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_button.svg',
              width: 40.w,
              height: 40.w,
            ),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Text(
              "O Aplikacji",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: AdaptiveAssetImage(
                basePath: 'assets/icons/logo_wdialogu',
                width: 124.w,
                height: 126.h,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Zalecamy regularne aktualizowanie aplikacji wDialogu. Dzięki temu masz pewność, że korzystasz z najnowszych funkcji i usprawnień.',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 22.5.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wersja aplikacji',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      AdaptiveAssetImage(
                        basePath: 'assets/icons/checked',
                        width: 20.w,
                        height: 20.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '1.0',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Masz najnowszą wersję',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.5.h),
            _buildTile(
              'Więcej o aplikacji',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => const WebViewPage(
                          url: 'https://wdialogu.pl/',
                          title: 'O aplikacji',
                        ),
                  ),
                );
              },
            ),
            SizedBox(height: 22.5.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 22.5.h),
            Center(
              child: Text(
                'Właścicielem aplikacji jest:',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 19.h),
            Center(
              child: AdaptiveAssetImage(
                basePath: 'assets/icons/logo_o_aplikacji',
                width: 200.w,
                height: 45.h,
              ),
            ),
            SizedBox(height: 40.h),
            _buildTile(
              'Więcej o MediaPark',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => const WebViewPage(
                          url: 'https://www.media-park.pl/',
                          title: 'MediaPark',
                        ),
                  ),
                );
              },
            ),
            // _buildTile('Deklaracja dostępności', onTap: () {}),
            Transform.translate(
              offset: Offset(20.w, 0),
              child: AdaptiveAssetImage(
                basePath: 'assets/icons/city',
                width: 380.w,
                height: 203.h,
              ),
            ),
            SizedBox(height: 19.h),
            Divider(height: 1.h, color: AppColors.divider),
            Center(
              child: Padding(
                padding: EdgeInsets.all(33.0.r),
                child: Text(
                  'Wersja aplikacji: v 1.20.343',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
