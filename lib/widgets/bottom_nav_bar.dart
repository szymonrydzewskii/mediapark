import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/screens/main_window.dart';
import 'package:mediapark/screens/settings_screen.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';

class BottomNavBar extends StatefulWidget {
  final Set<Samorzad> wybraneSamorzady;
  final Samorzad aktywnySamorzad;

  const BottomNavBar({
    super.key,
    required this.aktywnySamorzad,
    required this.wybraneSamorzady,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;
  late Samorzad aktywnaGmina;

  @override
  void initState() {
    super.initState();
    aktywnaGmina = widget.wybraneSamorzady.first;
  }

  void _onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  void _zmienGmine() async {
    final nowyWybor = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectingSamorzad()),
    );
    if (nowyWybor is Set<Samorzad> && nowyWybor.isNotEmpty) {
      setState(() => aktywnaGmina = nowyWybor.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MainWindow(wybraneSamorzady: {aktywnaGmina}),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pages[selectedIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Container(
                height: 70.h,
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  borderRadius: BorderRadius.circular(35.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCCE9F2),
                      blurRadius: 10.r,
                      offset: Offset(0, 50.h),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Przesuwające się podświetlenie
                    AnimatedAlign(
                      alignment: selectedIndex == 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 80.w) / 2,
                        height: 56.h,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 66, 66, 66),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),

                    // Przycisk z ikonami
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: AdaptiveAssetImage(
                            basePath: 'assets/icons/home',
                            height: 25.h,
                            width: 25.w,
                          ),
                          label: aktywnaGmina.nazwa,
                          onTap: () {
                            if (selectedIndex == 0) {
                              _zmienGmine();
                            } else {
                              _onItemTapped(0);
                            }
                          },
                        ),
                        _buildNavItem(
                          index: 1,
                          icon: AdaptiveAssetImage(
                            basePath: 'assets/icons/settings',
                            height: 25.h,
                            width: 25.w,
                          ),
                          label: 'Ustawienia',
                          onTap: () => _onItemTapped(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black87,
    );
  }

  Widget _buildNavItem({
    required int index,
    required AdaptiveAssetImage icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      flex: isSelected ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56.h,
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 66, 66, 66)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
