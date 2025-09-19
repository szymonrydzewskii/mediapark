import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/services/global_data_service.dart';
import '../models/konsultacje.dart';
import '../helpers/prettify.dart';

class KonsultacjeDetailsPage extends StatelessWidget {
  final Konsultacje konsultacja;

  const KonsultacjeDetailsPage({super.key, required this.konsultacja});

  @override
  Widget build(BuildContext context) {
    final GlobalDataService globalService = GlobalDataService();

    return Scaffold(
      backgroundColor: AppColors.primary,
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
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Chip kategorii
            _buildCategoryChip(),
            SizedBox(height: 16.h),

            // Tytuł konsultacji
            SizedBox(
              width: double.infinity,
              child: Text(
                konsultacja.title,
                style: GoogleFonts.poppins(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 12.h),

            // Status i daty
            Text(
              "Status: ${konsultacja.status}",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.blackLight,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Od: ${konsultacja.startDate}  Do: ${konsultacja.endDate}",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.blackLight,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20.h),

            // Zdjęcie jeśli dostępne
            if (globalService.isKonsultacjaImageValid(konsultacja.photoUrl)) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  konsultacja.photoUrl!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // Krótki opis
            if (konsultacja.shortDescription.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: Html(
                  data: konsultacja.shortDescription,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      fontSize: FontSize(16.sp),
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      margin: Margins.only(bottom: 12),
                      padding: HtmlPaddings.zero,
                    ),
                    "div": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Główny opis
            SizedBox(
              width: double.infinity,
              child: Html(
                data: konsultacja.description,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "p": Style(
                    fontSize: FontSize(16.sp),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    margin: Margins.only(bottom: 12),
                    padding: HtmlPaddings.zero,
                  ),
                  "div": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                },
              ),
            ),
            SizedBox(height: 24.h),

            // Przycisk "Weź udział"
            if ((konsultacja.pollUrl ?? '').isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implementuj otwieranie URL konsultacji
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                  ),
                  child: Text(
                    'Weź udział',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFACD2DD),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          prettify(konsultacja.categoryAlias),
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}