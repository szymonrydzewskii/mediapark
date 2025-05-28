import 'package:flutter/material.dart';
import 'package:mediapark/animations/fade_in_up.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/helpers/preferences_helper.dart';
import 'package:mediapark/services/samorzad_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/screens/main_window.dart';
import 'package:mediapark/widgets/bottom_nav_bar.dart';

class SelectingSamorzad extends StatefulWidget {
  const SelectingSamorzad({super.key});

  @override
  State<SelectingSamorzad> createState() => _SelectingSamorzadState();
}

class _SelectingSamorzadState extends State<SelectingSamorzad> {
  static const backgroundColor = Color(0xFFCCE9F2);
  List<Samorzad> wszystkieSamorzady = [];
  List<Samorzad> filtrowaneSamorzady = [];
  Set<String> wybraneSamorzady = {};
  String wpisanyText = '';
  bool showLoader = true;

  @override
  void initState() {
    super.initState();
    loadData();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showLoader = false;
        });
      }
    });
  }

  Future<void> loadData() async {
    final samorzady = await loadSamorzad();
    final zapisaneId = await PreferencesHelper.getSelectedSamorzady();
    setState(() {
      wszystkieSamorzady = samorzady;
      filtrowaneSamorzady = samorzady;
      wybraneSamorzady = zapisaneId;
    });
  }

  void onSearch(String value) {
    setState(() {
      wpisanyText = value;
      filtrowaneSamorzady =
          wszystkieSamorzady
              .where(
                (samorzad) =>
                    samorzad.nazwa.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
    });
  }

  void onSelect(Samorzad samorzad) {
    setState(() {
      final noweWybrane = Set<String>.from(wybraneSamorzady);
      if (noweWybrane.contains(samorzad.id)) {
        noweWybrane.remove(samorzad.id);
      } else {
        noweWybrane.add(samorzad.id);
      }
      wybraneSamorzady = noweWybrane;
    });
  }

  void onSubmit() async {
    if (wybraneSamorzady.isNotEmpty) {
      await PreferencesHelper.saveSelectedSamorzady(wybraneSamorzady);
      if (!mounted) return;

      final wybraneObiekty =
          wszystkieSamorzady
              .where((s) => wybraneSamorzady.contains(s.id))
              .toSet();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => BottomNavBar(
                aktywnySamorzad:
                    wybraneObiekty.first, // ← przekazujemy pierwszy wybrany
                wybraneSamorzady:
                    wybraneObiekty, // ← przekazujemy cały Set<Samorzad>
              ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: AppBar(
          elevation: 0,
          forceMaterialTransparency: true,
          backgroundColor: backgroundColor,
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Szukaj',
                hintStyle: TextStyle(color: Color.fromARGB(255, 80, 93, 97)),
                filled: true,
                fillColor: Color(0xFFB5D7E4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onSearch,
            ),
          ),
          Expanded(
            child:
                filtrowaneSamorzady.isEmpty
                    ? Center(
                      child:
                          showLoader
                              ? const CircularProgressIndicator()
                              : const Text("Nie znaleziono samorządu"),
                    )
                    : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: List.generate(filtrowaneSamorzady.length, (
                          index,
                        ) {
                          final samorzad = filtrowaneSamorzady[index];
                          final isSelected = wybraneSamorzady.contains(
                            samorzad.id,
                          );
                          return FadeInUpWidget(
                            delay: Duration(milliseconds: index * 100),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => onSelect(samorzad),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: ListTile(
                                      leading: AdaptiveNetworkImage(
                                        url: samorzad.herb,
                                        width: 40,
                                        height: 40,
                                      ),
                                      title: Text(
                                        samorzad.nazwa,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      trailing:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: Color.fromARGB(
                                                  255,
                                                  0,
                                                  145,
                                                  0,
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
          ),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text('Zawsze możesz zmienić swój wybór później'),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: wybraneSamorzady.isNotEmpty ? onSubmit : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                "Gotowe",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
