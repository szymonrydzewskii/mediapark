import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/animations/fade_in_up.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/screens/settings_screen.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/services/samorzad_details_service.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:mediapark/widgets/moduly_box_builder.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/widgets/tiles/modul_tile.dart';

class MainWindow extends StatefulWidget {
  final Set<Samorzad> wybraneSamorzady;

  const MainWindow({super.key, required this.wybraneSamorzady});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _panelController;
  late final Animation<double> _panelAnimation;
  Samorzad? aktywnySamorzad;
  bool showPanel = false;
  SamorzadSzczegoly? szczegolyInstytucji;
  bool loadingSzczegoly = false;
  static const backgroundColor = Color(0xFFBCE1EB);
  Set<String> animowaneModuly = {};

  @override
  void initState() {
    super.initState();
    aktywnySamorzad = widget.wybraneSamorzady.first;
    onHerbClick(widget.wybraneSamorzady.first);

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _panelAnimation = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  void onSettingsClick() {
    Navigator.of(context).push(slideFadeRouteTo(const SettingsScreen()));
  }

  void onHerbClick(Samorzad samorzad) async {
    setState(() {
      aktywnySamorzad = samorzad;
      showPanel = false;
      loadingSzczegoly = true;
    });
    try {
      final szczegoly = await fetchSzczegolyInstytucji(samorzad.id);
      setState(() {
        szczegolyInstytucji = szczegoly;
        loadingSzczegoly = false;
      });
    } catch (e) {
      setState(() {
        loadingSzczegoly = false;
      });
    }
  }

  void otworzWybieranie(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectingSamorzad()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.wybraneSamorzady.toList();
    final panelHeight = min(max(lista.length, 4) * 70.0, 370);
    final rawName = (aktywnySamorzad?.nazwa ?? '').trim();
    // rozbijamy po białych znakach (wiele spacji/znaków)
    final parts = rawName.split(RegExp(r'\s+'));

    final twoLineName =
        parts.length <= 1
            ? rawName
            : '${parts.first}\n${parts.sublist(1).join(' ')}';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: AppBar(
                  toolbarHeight: 100.h,
                  elevation: 0,
                  forceMaterialTransparency: true,
                  backgroundColor: backgroundColor,
                  centerTitle: true,
                  title: Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Text(
                      twoLineName,
                      textAlign: TextAlign.center,
                      maxLines: 2, // maks. dwie linie
                      softWrap: true, // pozwól zawijać
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.sp,
                        color: Colors.black,
                        height: 1.0, // gęstszy odstęp między liniami (dopasuj)
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        loadingSzczegoly
                            ? const Center(child: CircularProgressIndicator())
                            : szczegolyInstytucji == null
                            ? const Center(child: Text("Brak danych"))
                            : GridView.builder(
                              key: const PageStorageKey('moduly_grid'),
                              padding: EdgeInsets.only(
                                right: 16.w,
                                left: 16.w,
                                bottom: 100.h,
                                top: 20.h,
                              ),
                              itemCount:
                                  szczegolyInstytucji!.modules.length + 1,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10.w,
                                    mainAxisSpacing: 10.h,
                                  ),
                              itemBuilder: (context, index) {
                                if (index ==
                                    szczegolyInstytucji!.modules.length) {
                                  return const SizedBox();
                                }
                                final modul =
                                    szczegolyInstytucji!.modules[index];
                                final hasAnimated = animowaneModuly.contains(
                                  modul.alias,
                                );
                                animowaneModuly.add(modul.alias);
                                return FadeInUpWidget(
                                  key: ValueKey(modul.alias), // ważne!
                                  animate: !hasAnimated,
                                  delay: Duration(milliseconds: index * 100),
                                  child: ModulTile(
                                    key: ValueKey(modul.alias),
                                    modul: modul,
                                    samorzad: szczegolyInstytucji!,
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ),
            ],
          ),
          if (showPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  await _panelController.reverse();
                  setState(() => showPanel = false);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(),
              ),
            ),
          Positioned(
            top: kToolbarHeight,
            left: 15.w,
            right: 15.w,
            child: FadeTransition(
              opacity: _panelAnimation,
              child: SlideTransition(
                position: _panelAnimation.drive(
                  Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero),
                ),
                child: IgnorePointer(
                  ignoring: !showPanel,
                  child: Material(
                    elevation: 6,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: panelHeight.toDouble(),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: lista.length,
                              itemBuilder: (context, index) {
                                final samorzad = lista[index];
                                return ListTile(
                                  leading: AdaptiveNetworkImage(
                                    url: samorzad.herb,
                                    width: 30.w,
                                    height: 30.h,
                                  ),
                                  title: Text(samorzad.nazwa),
                                  onTap: () async {
                                    setState(() => showPanel = false);
                                    await _panelController.reverse();
                                    onHerbClick(samorzad);
                                  },
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => showPanel = false);
                                _panelController.reverse();
                                otworzWybieranie(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                "Pokaż wszystkie",
                                style: GoogleFonts.poppins(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
