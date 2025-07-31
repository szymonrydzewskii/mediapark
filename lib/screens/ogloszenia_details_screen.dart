import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mediapark/models/ogloszenia.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OgloszeniaDetailsScreen extends StatelessWidget {
  final Ogloszenia ogloszenie;

  const OgloszeniaDetailsScreen({super.key, required this.ogloszenie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCE1EB),
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Szczegóły ogłoszenia",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (ogloszenie.mainPhoto != null &&
                ogloszenie.mainPhoto!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  ogloszenie.mainPhoto!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16.h),
            if (ogloszenie.categoryName != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFACD2DD),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  ogloszenie.categoryName!,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(height: 10.h),
            Text(
              ogloszenie.title,
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Dodane ${_formatDate(ogloszenie.datetime)}",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              ogloszenie.intro,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      return "${dt.day}.${dt.month}.${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return datetime;
    }
  }
}
