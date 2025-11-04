import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:store_redirect/store_redirect.dart';

class UpdateRequiredOverlay extends StatelessWidget {
  final VoidCallback onLater;

  const UpdateRequiredOverlay({super.key, required this.onLater});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 100.h), // << Wyższe przesunięcie w dół
              AdaptiveAssetImage(
                basePath: 'assets/icons/logo_wdialogu',
                width: 120.w,
                height: 120.h,
              ),
              SizedBox(height: 42.h),
              Text(
                'Dostępna jest nowa wersja\naplikacji wDialogu!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Aby korzystać z najnowszej wersji i zapewnić pełną funkcjonalność, zaktualizuj aplikację.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 56.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: onLater,
                      child: Text(
                        "Przypomnij później",
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blackMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        StoreRedirect.redirect();
                      },
                      child: Text(
                        "Aktualizuj",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AdaptiveAssetImage(
                basePath: 'assets/icons/illustration',
                width: 360.w,
                height: 180.h,
              ),
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }
}
