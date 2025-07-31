import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';

class OAplikacjiScreen extends StatefulWidget {
  const OAplikacjiScreen({super.key});

  @override
  State<OAplikacjiScreen> createState() => _OAplikacjiScreenState();
}

class _OAplikacjiScreenState extends State<OAplikacjiScreen> {
  static const backgroundColor = Color(0xFFBCE1EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFBCE1EB),
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
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 39.h),
            Text(
              "O Aplikacji",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.h),
            Center(
              child: AdaptiveAssetImage(
                basePath: 'assets/icons/logo_wdialogu',
                width: 124.w,
                height: 126.h,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'Nowoczesny tor do jazdy na rowerze, hulajnodze i deskorolce, zaprojektowany z myślą o bezpieczeństwie i dobrej zabawie. Idealne miejsce dla młodszych i starszych mieszkańców',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 44.5.h),
            Divider(height: 1),
            SizedBox(height: 44.5.h),
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
                basePath: 'assets/icons/logo_mediapark',
                width: 149.w,
                height: 28.h,
              ),
            ),
            SizedBox(height: 40.h),
            _buildTile('Więcej o MediaPark', onTap: () {}),
            _buildTile('Deklaracja dostępności', onTap: () {}),
            Transform.translate(
              offset: Offset(20.w, 0),
              child: AdaptiveAssetImage(
                basePath: 'assets/icons/city',
                width: 380.w,
                height: 203.h,
              ),
            ),
            SizedBox(height: 19.h),
            Divider(height: 1.h),
            Center(
              child: Padding(
                padding: EdgeInsets.all(33.0.r),
                child: Text(
                  'Wersja aplikacji: v 1.20.343',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF373737),
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
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFCAECF4),
            borderRadius: BorderRadius.circular(16.r),
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
