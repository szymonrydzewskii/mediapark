import 'package:flutter/material.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/screens/settings_screen.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/services/samorzad_details_service.dart';
import 'package:mediapark/screens/selecting_samorzad.dart';
import 'package:mediapark/widgets/custom_appbar.dart';
import 'package:mediapark/widgets/moduly_box_builder.dart';
import 'dart:math';

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
  static const backgroundColor = Color(0xFFCCE9F2);

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
      MaterialPageRoute(builder: (context) => SelectingSamorzad()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.wybraneSamorzady.toList();
    final panelHeight = min(max(lista.length, 4) * 70.0, 370);

    // final moduly = {
    //   'konsultacje' : aktywnySamorzad?.konsultacje ?? false,
    //   'kalendarz' : aktywnySamorzad?.kalendarz ?? false,
    //   'ogloszenia' : aktywnySamorzad?.ogloszenia ?? false
    // };

    // final widgetMap = {
    //   'konsultacje' : const KonsultacjeBox(),
    //   'kalendarz' : const KalendarzBox(),
    //   'ogloszenia' : const OgloszeniaBox()
    // };

    // final aktywneModuly = moduly.entries.where((entry) => entry.value == true).map((entry) => widgetMap[entry.key]!).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          //główny ekran
          Column(
            children: [
              // CustomAppBar(
              //   active: aktywnySamorzad!,
              //   onLogoTap: () {
              //     setState(() {
              //       showPanel = !showPanel;
              //     });

              //     if (showPanel) {
              //       _panelController.forward();
              //     } else {
              //       _panelController.reverse();
              //     }
              //   },
              //   onSettings: onSettingsClick,
              // ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: AppBar(
                  elevation: 0,
                  forceMaterialTransparency: true,
                  backgroundColor: backgroundColor,
                  centerTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      aktywnySamorzad?.nazwa ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        color: Colors.black,
                        height: 0.5,
                      ),
                    ),
                  ),
                  // actions: [
                  //   IconButton(
                  //     onPressed: onSettingsClick,
                  //     icon: Icon(Icons.settings, color: Colors.black),
                  //   ),
                  // ],
                ),
              ),

              // konsultacje box
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child:
                        loadingSzczegoly
                            ? const Center(child: CircularProgressIndicator())
                            : szczegolyInstytucji == null
                            ? const Center(child: Text("Brak danych"))
                            : GridView.count(
                              key: const PageStorageKey('moduly_grid'),
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              children: [
                                ...buildModulyBoxy(
                                context,
                                aktywnySamorzad!,
                                szczegolyInstytucji!.modules,
                              ),
                              SizedBox()
                              ]
                            ),
                  ),
                ),
              ),
              
            ],
          ),
          // panel przełączania samorządów
          if (showPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  await _panelController.reverse();
                  setState(() => showPanel = false);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(), // pusta warstwa "kliknięcia"
              ),
            ),
          Positioned(
            top: kToolbarHeight,
            left: 15,
            right: 15,
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
                    borderRadius: BorderRadius.circular(15),
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
                                    width: 30,
                                    height: 30,
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => showPanel = false);
                                _panelController.reverse();
                                otworzWybieranie(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Pokaż wszystkie",
                                style: TextStyle(color: Colors.black),
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
