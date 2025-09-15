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

  // ▼ Dropdown z Overlaya
  final GlobalKey _navBoxKey = GlobalKey(); // klucz do kontenera z GNav
  OverlayEntry? _menuEntry;
  late final AnimationController _menuCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

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
    if (index != 0) _removeMenu(); // zmiana taba zamyka menu
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
    });
  }

  void _showMenu() {
    final navCtx = _navBoxKey.currentContext;
    if (navCtx == null) return;

    final RenderBox navBox = navCtx.findRenderObject() as RenderBox;
    final Size navSize = navBox.size;
    final Offset navPos = navBox.localToGlobal(Offset.zero);

    // szerokość jednego taba (masz 3)
    const tabsCount = 3;
    final perTabWidth = navSize.width / tabsCount;

    // szerokość i wysokość panelu
    double menuWidth = perTabWidth - 20.w;
    menuWidth = menuWidth.clamp(220.w, 280.w); // sensowny zakres
    final itemsCount = widget.wybraneSamorzady.length;
    final double menuHeight = math.min(
      16.h + itemsCount * 48.h + 8.h + 44.h,
      260.h,
    ); // lista + przycisk

    // pozycja: nad lewą krawędzią pierwszego taba z lekkim odsunięciem
    final double left = navPos.dx + 6.w; // padding wewnętrzny paska
    final double top = navPos.dy - menuHeight - 6.h; // 8.h odstępu nad paskiem

    _menuEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // półprzezroczysty „barrier” — kliknięcie poza zamyka menu
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
    if (label.length > 16) label = '${label.substring(0, 16)}…';

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: pages[selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Container(
            key: _navBoxKey, // << potrzebne do pozycjonowania menu
            decoration: BoxDecoration(
              color: const Color(0xFF1D1F1F),
              borderRadius: BorderRadius.circular(90.r),
              boxShadow: [
                BoxShadow(color: const Color(0xFFBCE1EB), blurRadius: 12.r),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GNav(
                  backgroundColor: Colors.transparent,
                  tabBackgroundColor: const Color(0xFF373737),
                  gap: 10.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  tabBorderRadius: 99.r,
                  color: Colors.white70,
                  activeColor: Colors.white,
                  iconSize: 24.sp,
                  duration: const Duration(milliseconds: 250),
                  selectedIndex: selectedIndex,
                  onTabChange: (i) => _onItemTapped(i),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  tabs: [
                    // HOME – klik przełącza lub rozwija/zamyka menu
                    GButton(
                      icon: Icons.home,
                      leading:
                          selectedIndex == 0
                              ? Container(
                                width: 20.w,
                                height: 20.h,
                                alignment: Alignment.center,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: AdaptiveNetworkImage(
                                    key: ValueKey(aktywnaGmina.herb),
                                    url: aktywnaGmina.herb,
                                    height: 20.h,
                                    width: 20.w,
                                  ),
                                ),
                              )
                              : SvgPicture.asset(
                                'assets/icons/home.svg',
                                width: 22.w,
                                height: 22.h,
                              ),
                      text: selectedIndex == 0 ? label : '',
                      onPressed: () {
                        if (selectedIndex == 0) {
                          _toggleMenu(); // << rozwijaj/zamykaj dropdown
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

/// Mała karta „dropdown” nad paskiem.
/// Pokazuje listę Twoich wybranych gmin (do szybkiego przełączenia)
/// oraz przycisk „Wybierz inną…”, który otwiera SelectingSamorzad.
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
        color: const Color(0xFF373737),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: Color(0xFF373737), blurRadius: 12.r)],
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        children: [
          // Lista szybkiego wyboru (scrolluje się, jeśli duża)
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
                        Container(
                          width: 20.w,
                          height: 20.h,
                          alignment: Alignment.center,
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

          // „Wybierz inną…” – przejście do SelectingSamorzad
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
