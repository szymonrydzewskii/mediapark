import 'package:flutter/material.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/helpers/dashed_border_painter.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import '../widgets/adaptive_asset_image.dart';

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

    _scaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    Navigator.of(context).push(slideFadeRouteTo(const SelectingSamorzad()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9F2),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: AdaptiveAssetImage(
                    basePath: 'assets/icons/wdialogu',
                    width: 180,
                    height: 40,
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Wybierz',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'swój samorząd',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Przerywana obwódka z animacjami obrotu i skalowania
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _rotationController,
                              _scaleAnimation,
                            ]),
                            builder: (_, child) {
                              return Transform.rotate(
                                angle:
                                    _rotationController.value *
                                    2 *
                                    3.141592653589793,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: CustomPaint(
                              painter: DashedBorderPainter(color: Colors.white),
                              size: const Size(120, 120),
                            ),
                          ),
                          // Właściwy przycisk
                          GestureDetector(
                            onTap: _goToNextScreen,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 32,
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
              bottom: -120,
              left: 140,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.scale(
                  scale: 1.8,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: AdaptiveAssetImage(
                      basePath: 'assets/icons/city',
                      width: MediaQuery.of(context).size.width,
                      height: 520,
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
