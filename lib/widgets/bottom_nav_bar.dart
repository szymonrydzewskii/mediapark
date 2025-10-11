import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mediapark/screens/main_window.dart';
import 'package:mediapark/screens/notifications_screen.dart';
import 'package:mediapark/screens/settings_screen.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/style/app_style.dart';

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

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late Samorzad aktywnaGmina;

  final GlobalKey _navBoxKey = GlobalKey();
  OverlayEntry? _menuEntry;
  late final AnimationController _menuCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool get _isMenuOpen => _menuEntry != null;

  @override
  void initState() {
    super.initState();
    aktywnaGmina = widget.wybraneSamorzady.first;

    _menuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic);
    _slide = Tween(
      begin: const Offset(0, .06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _removeMenu(immediate: true);
    _menuCtrl.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != 0) _removeMenu();
    setState(() => selectedIndex = index);
  }

  Future<void> _zmienGmine() async {
    final nowyWybor = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectingSamorzad()),
    );
    if (!mounted) return;
    if (nowyWybor is Set<Samorzad> && nowyWybor.isNotEmpty) {
      setState(() => aktywnaGmina = nowyWybor.first);
    }
  }

  void _toggleMenu() {
    if (_menuEntry != null) {
      _removeMenu();
    } else {
      _showMenu();
    }
  }

  void _removeMenu({bool immediate = false}) {
    if (_menuEntry == null) return;
    if (immediate) {
      _menuEntry?.remove();
      _menuEntry = null;
      return;
    }
    _menuCtrl.reverse().whenComplete(() {
      _menuEntry?.remove();
      _menuEntry = null;
      setState(() {}); // odśwież strzałkę
    });
  }

  void _showMenu() {
    final navCtx = _navBoxKey.currentContext;
    if (navCtx == null) return;

    final RenderBox navBox = navCtx.findRenderObject() as RenderBox;
    final Size navSize = navBox.size;
    final Offset navPos = navBox.localToGlobal(Offset.zero);

    const tabsCount = 3;
    final perTabWidth = navSize.width / tabsCount;

    double menuWidth = perTabWidth - 20.w;
    menuWidth = menuWidth.clamp(220.w, 280.w);
    final itemsCount = widget.wybraneSamorzady.length;
    final double menuHeight = math.min(
      16.h + itemsCount * 48.h + 8.h + 44.h,
      260.h,
    );

    final double left = navPos.dx + 6.w;
    final double top = navPos.dy - menuHeight - 6.h;

    _menuEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeMenu,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              height: menuHeight,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _DropdownCard(
                      aktywnaGmina: aktywnaGmina,
                      wybraneSamorzady: widget.wybraneSamorzady,
                      onPick: (s) {
                        setState(() => aktywnaGmina = s);
                        _removeMenu();
                      },
                      onMore: () async {
                        _removeMenu();
                        await _zmienGmine();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_menuEntry!);
    _menuCtrl.forward(from: 0);
    setState(() {}); // odśwież strzałkę
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MainWindow(
        key: ValueKey(aktywnaGmina.id),
        wybraneSamorzady: {aktywnaGmina},
      ),
      const NotificationsScreen(),
      const SettingsScreen(),
    ];

    String label = aktywnaGmina.nazwa;
    if (label.length > 14) label = '${label.substring(0, 14)}…';

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: pages[selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Container(
            key: _navBoxKey,
            decoration: BoxDecoration(
              color: AppColors.blackMedium,
              borderRadius: BorderRadius.circular(90.r),
              boxShadow: [
                BoxShadow(color: AppColors.primary, blurRadius: 12.r),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // bazowy limit ~ 1/3 szerokości
                final double baseMaxTabWidth = (constraints.maxWidth / 3) - 6.w;

                // konserwatywna rezerwa dla dwóch pozostałych kafelków (ikonki + tekst)
                final double otherTabsReserve =
                    2 * 130.w; // dostosuj, jeśli masz inne paddingi/teksty
                final double safety = 24.w;

                // ile realnie możemy oddać aktywnemu kafelkowi
                final double availableForActive = (constraints.maxWidth -
                        otherTabsReserve -
                        safety)
                    .clamp(140.w, baseMaxTabWidth + 60.w);

                // nie przesadzaj – maks. 60% szerokości paska
                final double activeMaxWidth = math.min(
                  availableForActive,
                  constraints.maxWidth * 0.60,
                );

                return GNav(
                  backgroundColor: Colors.transparent,
                  tabBackgroundColor: AppColors.blackLight,
                  gap: 8.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  tabBorderRadius: 99.r,
                  color: Colors.white70,
                  activeColor: Colors.white,
                  iconSize: 22.sp,
                  duration: const Duration(milliseconds: 250),
                  selectedIndex: selectedIndex,
                  onTabChange: (i) => _onItemTapped(i),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  tabs: [
                    // HOME
                    GButton(
                      icon: Icons.home,
                      leading:
                          selectedIndex == 0
                              ? AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                // >>> tu robimy go SZERSZYM gdy aktywny <<<
                                constraints: BoxConstraints(
                                  maxWidth: activeMaxWidth, // szerszy limit
                                  minWidth:
                                      baseMaxTabWidth *
                                      0.85, // opcjonalnie: ładniejsza animacja
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: 24.w,
                                      height: 24.h,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: AdaptiveNetworkImage(
                                          key: ValueKey(aktywnaGmina.herb),
                                          url: aktywnaGmina.herb,
                                          height: 24.h,
                                          width: 24.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        // label jak wcześniej skracany
                                        (aktywnaGmina.nazwa.length > 14)
                                            ? '${aktywnaGmina.nazwa.substring(0, 14)}…'
                                            : aktywnaGmina.nazwa,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    AnimatedRotation(
                                      turns: _isMenuOpen ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : SvgPicture.asset(
                                'assets/icons/home.svg',
                                width: 22.w,
                                height: 22.h,
                              ),
                      text: '',
                      onPressed: () {
                        if (selectedIndex == 0) {
                          _toggleMenu();
                        } else {
                          _onItemTapped(0);
                        }
                      },
                    ),
                    GButton(
                      icon: Icons.notifications,
                      leading: SvgPicture.asset(
                        'assets/icons/powiadomienia.svg',
                        width: 22.w,
                        height: 22.h,
                      ),
                      text: 'Powiadomienia',
                    ),
                    GButton(
                      icon: Icons.settings,
                      leading: SvgPicture.asset(
                        'assets/icons/settings.svg',
                        width: 22.w,
                        height: 22.h,
                      ),
                      text: 'Ustawienia',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Mała karta „dropdown" nad paskiem.
class _DropdownCard extends StatelessWidget {
  final Samorzad aktywnaGmina;
  final Set<Samorzad> wybraneSamorzady;
  final ValueChanged<Samorzad> onPick;
  final VoidCallback onMore;

  const _DropdownCard({
    required this.aktywnaGmina,
    required this.wybraneSamorzady,
    required this.onPick,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      aktywnaGmina,
      ...wybraneSamorzady.where((s) => s.id != aktywnaGmina.id).toList()
        ..sort((a, b) => a.nazwa.compareTo(b.nazwa)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blackLight,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: AppColors.blackLight, blurRadius: 12.r)],
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder:
                  (_, __) => Divider(
                    color: Colors.white10,
                    height: 1.h,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
              itemBuilder: (context, i) {
                final s = items[i];
                return InkWell(
                  onTap: () => onPick(s),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: AdaptiveNetworkImage(
                            url: s.herb,
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            s.nazwa,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (s.id == aktywnaGmina.id) ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.check, color: Colors.white70, size: 18.sp),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SizedBox(
              width: double.infinity,
              height: 40.h,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF2E2E2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: onMore,
                child: Text(
                  'Pokaż więcej',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
