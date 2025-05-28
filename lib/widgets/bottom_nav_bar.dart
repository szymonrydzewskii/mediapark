import 'package:flutter/material.dart';
import 'package:mediapark/screens/main_window.dart';
import 'package:mediapark/screens/settings_screen.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/helpers/preferences_helper.dart';
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
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFCCE9F2),
                      blurRadius: 10,
                      offset: const Offset(0, 50),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Przesuwające się podświetlenie
                    AnimatedAlign(
                      alignment:
                          selectedIndex == 0
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        width:
                            (MediaQuery.of(context).size.width - 80) /
                            2, // szerokość połowy navbara
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 66, 66, 66),
                          borderRadius: BorderRadius.circular(30),
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
                            height: 25,
                            width: 25,
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
                            height: 25,
                            width: 25,
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
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromARGB(255, 66, 66, 66)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
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
