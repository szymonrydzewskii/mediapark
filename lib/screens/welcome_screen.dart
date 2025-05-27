import 'package:flutter/material.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import '../widgets/adaptive_asset_image.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    Navigator.of(context).pushReplacement(slideFadeRouteTo(const SelectingSamorzad()));
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
                const SizedBox(height: 24),
                Center(
                  child: AdaptiveAssetImage(
                    basePath: 'assets/logo/mediapark',
                    width: 180,
                    height: 40,
                  ),
                ),
                const SizedBox(height: 180),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40), // przesunięcie wyżej
                      const Text(
                        'Wybierz',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'swój samorząd',
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _goToNextScreen,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                      const Spacer(), // zapewnia, że city.svg nie nachodzi
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: -140, // grafika "wychodzi" mocno za ekran
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: AdaptiveAssetImage(
                    basePath: 'assets/icons/city',
                    width: MediaQuery.of(context).size.width,
                    height: 520, // bardzo wysoka ilustracja
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
