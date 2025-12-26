import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class IllustrationEmptyState extends StatelessWidget {
  final String mainText;
  final String secondaryText;
  final String assetPath;
  final String secondAssetPath;
  final int type;

  const IllustrationEmptyState({
    super.key,
    required this.mainText,
    required this.secondaryText,
    this.type = 1,
    this.secondAssetPath = "assets/icons/trees.svg",
    this.assetPath = "assets/icons/park.svg",

  });

  @override
  Widget build(BuildContext context) {
    if (type == 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80.h),
            SvgPicture.asset(assetPath),
            SizedBox(height: 80.h),
            Text(
              mainText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              secondaryText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 220.h),
            SvgPicture.asset(secondAssetPath),
            
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              mainText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              secondaryText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 60.h),
            SvgPicture.asset(assetPath),
            SizedBox(height: 140.h),
          ],
        ),
      );
    }
  }
}
