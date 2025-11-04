import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/helpers/dashed_border_painter.dart';
import 'package:mediapark/helpers/haptics.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/adaptive_asset_image.dart';
import 'package:mediapark/style/app_style.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // odległości między którymi się powiększa i pomniejsza kółko
    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.8).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    //prędkość obrotu kresek
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10.h).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    Navigator.of(
      context,
    ).pushReplacement(slideFadeRouteTo(const SelectingSamorzad()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 95.h),
                Center(
                  child: AdaptiveAssetImage(
                    basePath: 'assets/icons/logo_wdialogu',
                    width: 80.w,
                    height: 82.h,
                  ),
                ),
                SizedBox(height: 73.h),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      Text(
                        'Wybierz\nsamorząd',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _rotationController,
                              _scaleAnimation,
                            ]),
                            builder: (_, child) {
                              return Transform.rotate(
                                angle: _rotationController.value * 2 * 3.1416,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: CustomPaint(
                              painter: DashedBorderPainter(color: Colors.white),
                              size: Size(120.w, 120.h),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Haptics.tap();
                              _goToNextScreen();
                            },
                            child: Container(
                              width: 85.w,
                              height: 85.h,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/plus.svg',
                                  width: 80.w,
                                  height: 80.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: -130.h,
              left: 140.w,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.scale(
                  scale: 1.8,
                  child: SizedBox(
                    width: 1.sw,
                    child: AdaptiveAssetImage(
                      basePath: 'assets/icons/city',
                      width: 1.sw,
                      height: 520.h,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
