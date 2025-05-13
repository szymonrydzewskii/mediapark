import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
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

class _MainWindowState extends State<MainWindow> {
  Samorzad? aktywnySamorzad;
  bool showPanel = false;
  SamorzadSzczegoly? szczegolyInstytucji;
  bool loadingSzczegoly = false;

  @override
  void initState() {
    super.initState();
    aktywnySamorzad = widget.wybraneSamorzady.first;
    onHerbClick(widget.wybraneSamorzady.first);
  }

  void onSettingsClick() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height - 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Stack(
            children: [
              // Główna zawartość
              ListView(
                children: [
                  SizedBox(height: 40), // miejsce na przycisk Zamknij
                  Text(
                    'Ustawienia',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'O APLIKACJI',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildOptionTile('Wersja', '1.0.0'),
                  _buildOptionTile(
                    'Regulamin',
                    '',
                    onTap: () {
                      // np. navigator do strony regulaminu
                    },
                  ),
                  _buildOptionTile(
                    'Polityka prywatności',
                    '',
                    onTap: () {
                      // otwarcie Privacy Policy
                    },
                  ),
                  _buildOptionTile('Użytkownik', 'Jan Kowalski'),
                ],
              ),

              // Przyciski na górze (Zamknij)
              Positioned(
                right: 0,
                top: 0,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Zamknij',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 16)),
      subtitle:
          subtitle.isNotEmpty
              ? Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              )
              : null,
      trailing: onTap != null ? Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
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
    Navigator.pushReplacement(
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
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Stack(
        children: [
          //główny ekran
          Column(
            children: [
              CustomAppBar(
                active: aktywnySamorzad!,
                onLogoTap: () => setState(() => showPanel = !showPanel),
                onSettings: onSettingsClick,
              ),
              // konsultacje box
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child:
                      loadingSzczegoly
                          ? const Center(child: CircularProgressIndicator())
                          : szczegolyInstytucji == null
                          ? const Center(child: Text("Brak danych"))
                          : GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: buildModulyBoxy(
                              context,
                              aktywnySamorzad!,
                              szczegolyInstytucji!.modules,
                            ),
                          ),
                ),
              ),
            ],
          ),
          // panel przełączania samorządów
          if (showPanel)
            Positioned(
              top: kToolbarHeight,
              left: 15,
              right: 15,
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
                              onTap: () => onHerbClick(samorzad),
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
        ],
      ),
    );
  }
}
