import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Heading styles
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle headingBold = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  // Body text styles
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  // Special styles
  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
  );

  // Search/Input styles
  static TextStyle inputText = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle hintText = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  // Helper method for custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Helper method for custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size.sp);
  }
}
