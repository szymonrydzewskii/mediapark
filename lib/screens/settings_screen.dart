import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'o_aplikacji_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:mediapark/style/app_style.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushEnabled = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          // dodajemy zapas na lewitujący nav bar
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ustawienia',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30.h),
              _buildTile("Regulamin", onTap: () {}),
              _buildTile("Polityka prywatności", onTap: () {}),
              _buildTile("Deklaracja dostępności", onTap: () {}),
              _buildTile(
                "O aplikacji",
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const OAplikacjiScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 30.h),
              const Divider(thickness: 1, color: AppColors.divider),
              SizedBox(height: 49.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 12.w, top: 16.w),
                    child: AdaptiveAssetImage(
                      basePath: 'assets/icons/notifications',
                      width: 56.w,
                      height: 56.h,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Powiadomienia PUSH",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Czy chcesz otrzymywać powiadomienia na swoim telefonie?",
                          style: GoogleFonts.poppins(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: pushEnabled,
                    onChanged: (value) {
                      setState(() {
                        pushEnabled = value;
                      });
                    },
                    activeTrackColor: AppColors.blackMedium,
                  ),
                ],
              ),
              SizedBox(height: 49.h),
              const Divider(thickness: 1, color: AppColors.divider),
              SizedBox(height: 30.h),
              Center(
                child: Text(
                  'Wersja aplikacji: v 1.20.343',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackLight,
                  ),
                ),
              ),
            ],
          ),
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
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 25.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
