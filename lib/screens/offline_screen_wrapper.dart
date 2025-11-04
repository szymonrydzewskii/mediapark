import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';

class OfflineScreenWrapper extends StatefulWidget {
  final Widget child;

  const OfflineScreenWrapper({super.key, required this.child});

  @override
  State<OfflineScreenWrapper> createState() => _OfflineScreenWrapperState();
}

class _OfflineScreenWrapperState extends State<OfflineScreenWrapper> {
  bool _isOffline = false;
  bool _hasTriedRefresh = false;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnection();

    // Aktualizuj tylko isOffline – nie przełączaj ekranu
    _connectivity.onConnectivityChanged.listen((results) {
      final isDisconnected =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = isDisconnected;
        });
      }
    });
  }

  Future<void> _checkConnection() async {
    final results = await _connectivity.checkConnectivity();

    final isDisconnected =
        results is List<ConnectivityResult>
            ? results.isEmpty ||
                results.every((r) => r == ConnectivityResult.none)
            : results == ConnectivityResult.none;

    if (mounted) {
      setState(() {
        _isOffline = isDisconnected;
        _hasTriedRefresh = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline && _hasTriedRefresh)
          Positioned.fill(
            child: Scaffold(
              backgroundColor: AppColors.primary,
              body: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 140.h,
                      left: 16.w,
                      right: 16.w,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 400.w,
                      ), // dla responsywności
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AdaptiveAssetImage(
                            basePath: 'assets/icons/network-error',
                            width: 43.w,
                            height: 43.h,
                          ),
                          const SizedBox(height: 35),
                          Text(
                            'Las szumi,\nale danych nie przesyła.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 33.h),
                          Text(
                            'Sprawdź połączenie',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 120.w,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _checkConnection,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: AppColors.blackMedium,
                              ),
                              child: Text(
                                "Odśwież",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          AdaptiveAssetImage(
                            basePath: 'assets/icons/illustration',
                            width: 340.w,
                            height: 160.h,
                          ),
                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
