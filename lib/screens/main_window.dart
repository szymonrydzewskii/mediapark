import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/animations/fade_in_up.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/screens/settings_screen.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/services/cached_samorzad_details_service.dart';
import 'package:mediapark/services/global_data_service.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/widgets/tiles/modul_tile.dart';
import 'package:mediapark/style/app_style.dart';

class MainWindow extends StatefulWidget {
  final Set<Samorzad> wybraneSamorzady;

  const MainWindow({super.key, required this.wybraneSamorzady});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow>
    with SingleTickerProviderStateMixin {
  final _detailsService = CachedSamorzadDetailsService();
  final _globalDataService = GlobalDataService();
  late final AnimationController _panelController;
  late final Animation<double> _panelAnimation;
  Samorzad? aktywnySamorzad;
  bool showPanel = false;
  SamorzadSzczegoly? szczegolyInstytucji;
  bool loadingSzczegoly = false;
  static const backgroundColor = AppColors.primary;
  Set<String> animowaneModuly = {};
  static Set<String> globalAnimatedModules = {};
  bool _isFirstLoad = true;
  bool _isAnimatingOut = false;
  bool _isAnimatingIn = false;
  String? _previousMunicipalityId;

  @override
  void initState() {
    super.initState();
    aktywnySamorzad = widget.wybraneSamorzady.first;
    loadingSzczegoly = false;
    _previousMunicipalityId = widget.wybraneSamorzady.first.id.toString();
    _isFirstLoad = true;
    _loadInitialData();

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

  Future<void> _loadInitialData() async {
    final firstSamorzad = widget.wybraneSamorzady.first;
    final municipalityId = firstSamorzad.id.toString();

    try {
      final szczegoly = await _detailsService.fetchSzczegolyInstytucji(
        firstSamorzad.id,
      );
      if (mounted) {
        setState(() {
          szczegolyInstytucji = szczegoly;
        });
      }
    } catch (e) {
      _detailsService
          .fetchSzczegolyInstytucji(firstSamorzad.id)
          .then((szczegoly) {
            if (mounted) {
              setState(() {
                szczegolyInstytucji = szczegoly;
              });
            }
          })
          .catchError((_) {});
    }

    _globalDataService.loadMunicipalityData(municipalityId).catchError((_) {});
  }

  void onSettingsClick() {
    Navigator.of(context).push(slideFadeRouteTo(const SettingsScreen()));
  }

  void onHerbClick(Samorzad samorzad) async {
    final municipalityId = samorzad.id.toString();

    if (_previousMunicipalityId != null &&
        _previousMunicipalityId != municipalityId) {
      setState(() {
        _isAnimatingOut = true;
      });

      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      aktywnySamorzad = samorzad;
      showPanel = false;
      loadingSzczegoly = false;
      _isFirstLoad = false;
      _isAnimatingOut = false;
      _isAnimatingIn = true;
      _previousMunicipalityId = municipalityId;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isAnimatingIn = false;
        });
      }
    });

    Future.wait([
      _detailsService
          .fetchSzczegolyInstytucji(samorzad.id)
          .then((szczegoly) {
            if (mounted && aktywnySamorzad?.id == samorzad.id) {
              setState(() {
                szczegolyInstytucji = szczegoly;
              });
            }
          })
          .catchError((_) {}),
      _globalDataService.loadMunicipalityData(municipalityId),
    ]).catchError((e) {
      print('Background loading error: $e');
    });
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
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.sp,
                        color: Colors.black,
                        height: 1.0,
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
                    child: SingleChildScrollView(
                      // POPRAWKA: Dodany padding na dole, aby ostatnie kafelki nie były zasłonięte przez bottom navigation bar
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        20.h,
                        16.w,
                        120.h, // Zwiększony padding z 100.h na 120.h, aby zapewnić wystarczający margines
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const columns = 2;
                          final spacing = 10.w;
                          final runSpacing = 10.h;
                          final tileW =
                              (constraints.maxWidth - spacing) / columns;

                          final mods = szczegolyInstytucji?.modules ?? [];

                          if (mods.isEmpty) {
                            return const SizedBox();
                          }

                          if (_isAnimatingOut) {
                            return AnimatedOpacity(
                              opacity: 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Wrap(
                                spacing: spacing,
                                runSpacing: runSpacing,
                                children: List.generate(mods.length, (index) {
                                  final modul = mods[index];
                                  return SizedBox(
                                    width: tileW,
                                    child: ModulTile(
                                      key: ValueKey('${modul.alias}_fadeout'),
                                      modul: modul,
                                      samorzad: szczegolyInstytucji!,
                                    ),
                                  );
                                }),
                              ),
                            );
                          }

                          return Wrap(
                            spacing: spacing,
                            runSpacing: runSpacing,
                            children: List.generate(mods.length, (index) {
                              final modul = mods[index];
                              final moduleKey =
                                  '${aktywnySamorzad?.id}_${modul.alias}';
                              final hasAnimated = globalAnimatedModules
                                  .contains(moduleKey);
                              globalAnimatedModules.add(moduleKey);

                              return SizedBox(
                                width: tileW,
                                child:
                                    _isFirstLoad
                                        ? FadeInUpWidget(
                                          key: ValueKey(modul.alias),
                                          animate: !hasAnimated,
                                          delay: Duration(
                                            milliseconds: index * 100,
                                          ),
                                          child: ModulTile(
                                            key: ValueKey(modul.alias),
                                            modul: modul,
                                            samorzad: szczegolyInstytucji!,
                                          ),
                                        )
                                        : AnimatedOpacity(
                                          opacity: _isAnimatingIn ? 0.0 : 1.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: ModulTile(
                                            key: ValueKey(modul.alias),
                                            modul: modul,
                                            samorzad: szczegolyInstytucji!,
                                          ),
                                        ),
                              );
                            }),
                          );
                        },
                      ),
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
