import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/helpers/preferences_helper.dart';
import 'package:mediapark/widgets/webview_page.dart';
import 'o_aplikacji_screen.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/services/cached_samorzad_details_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushEnabled = false;
  bool _isLoading = true;
  SamorzadSzczegoly? _szczegoly;

  Future<void> _loadSamorzadSzczegoly() async {
    final wybrane = await PreferencesHelper.getSelectedSamorzady();
    if (wybrane.isNotEmpty) {
      final szczegoly = await CachedSamorzadDetailsService()
          .fetchSzczegolyInstytucji(wybrane.first);
      if (mounted) {
        setState(() {
          _szczegoly = szczegoly;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPushPreference();
    _loadSamorzadSzczegoly();
  }

  /// Wczytuje zapisane ustawienie powiadomień PUSH z SharedPreferences
  Future<void> _loadPushPreference() async {
    final enabled = await PreferencesHelper.getPushNotificationsEnabled();
    if (mounted) {
      setState(() {
        pushEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  /// Zapisuje wybór użytkownika dotyczący powiadomień PUSH
  Future<void> _savePushPreference(bool value) async {
    await PreferencesHelper.savePushNotificationsEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildTile(
                "Regulamin",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => WebViewPage(
                            title: "Regulamin",
                            url: _regulaminUrl,
                          ),
                    ),
                  );
                },
              ),
              _buildTile(
                "Polityka prywatności",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => WebViewPage(
                            title: "Polityka prywatności",
                            url: _politykaUrl,
                          ),
                    ),
                  );
                },
              ),
              _buildTile(
                "Deklaracja dostępności",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => WebViewPage(
                            title: "Deklaracja dostępności",
                            url: _deklaracjaUrl,
                          ),
                    ),
                  );
                },
              ),
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
                  SizedBox(
                    width: 56.w + 12.w,
                    height: 56.h + 16.h,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.w, top: 16.h),
                      child: AdaptiveAssetImage(
                        basePath: 'assets/icons/notifications',
                        width: 56.w,
                        height: 56.h,
                      ),
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
                  // Wyświetl Switch dopiero po wczytaniu preferencji
                  if (!_isLoading)
                    Switch(
                      value: pushEnabled,
                      onChanged: (value) async {
                        setState(() {
                          pushEnabled = value;
                        });
                        await _savePushPreference(value);
                      },
                      activeTrackColor: AppColors.blackMedium,
                    )
                  else
                    // Placeholder podczas ładowania
                    SizedBox(
                      width: 51.w,
                      height: 31.h,
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
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

  String get _regulaminUrl =>
      _szczegoly?.regulationsLink.isNotEmpty == true
          ? _szczegoly!.regulationsLink
          : 'https://wdialogu.pl/aplikacja/regulamin';

  String get _politykaUrl =>
      _szczegoly?.privacyPolicyLink.isNotEmpty == true
          ? _szczegoly!.privacyPolicyLink
          : 'https://wdialogu.pl/aplikacja/polityka-prywatnosci';

  String get _deklaracjaUrl =>
      _szczegoly?.accessibilityDeclarationLink.isNotEmpty == true
          ? _szczegoly!.accessibilityDeclarationLink
          : 'https://wdialogu.pl/aplikacja/deklaracja-dostepnosci';

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
