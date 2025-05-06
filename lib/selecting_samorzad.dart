import 'package:flutter/material.dart';
import 'package:mediapark/preferences_helper.dart';
import 'package:mediapark/samorzad_service.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'package:mediapark/main_window.dart';
=======
import 'package:mediapark/selected_samorzady.dart';
>>>>>>> ea4c2708a84cf12032b2ff5ba854d472391106a3

class SelectingSamorzad extends StatefulWidget {
  const SelectingSamorzad({super.key});

  @override
  State<SelectingSamorzad> createState() => _SelectingSamorzadState();
}

class _SelectingSamorzadState extends State<SelectingSamorzad> {
  static const backgroundColor = Color.fromARGB(255, 246, 246, 246);
  List<Samorzad> wszystkieSamorzady = [];
  List<Samorzad> filtrowaneSamorzady = [];
  Set<String> wybraneSamorzady = {};
  String wpisanyText = '';

  @override
  void initState() {
    super.initState();
    loadData();
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
      if (wybraneSamorzady.contains(samorzad.id)) {
        wybraneSamorzady.remove(samorzad.id);
      } else {
        wybraneSamorzady.add(samorzad.id);
      }
    });
  }

  void onSubmit() async {
    if (wybraneSamorzady.isNotEmpty) {
      await PreferencesHelper.saveSelectedSamorzady(wybraneSamorzady);
      final wybraneObiekty =
          wszystkieSamorzady
              .where((s) => wybraneSamorzady.contains(s.id))
              .toSet();
      Navigator.push(
        context,
        MaterialPageRoute(
<<<<<<< HEAD
          builder: (context) => MainWindow(wybraneSamorzady: wybraneObiekty),
=======
          builder:
              (context) => SelectedSamorzady(wybraneSamorzady: wybraneObiekty),
>>>>>>> ea4c2708a84cf12032b2ff5ba854d472391106a3
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: Text("Wybór samorządów", style: GoogleFonts.kanit(fontSize: 30)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Wyszukaj',
                hintStyle: GoogleFonts.roboto(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onSearch,
            ),
          ),
          Expanded(
            child:
                filtrowaneSamorzady.isEmpty
<<<<<<< HEAD
                    ? Center(child: CircularProgressIndicator(year2023: true),)
=======
                    ? Center(child: Text("Brak samorządów do wyświetlenia"))
>>>>>>> ea4c2708a84cf12032b2ff5ba854d472391106a3
                    : SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: List.generate(filtrowaneSamorzady.length, (
                          index,
                        ) {
                          final samorzad = filtrowaneSamorzady[index];
                          final isSelected = wybraneSamorzady.contains(
                            samorzad.id,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => onSelect(samorzad),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: ListTile(
                                    leading: Image.network(
                                      samorzad.herb,
                                      width: 40,
                                      height: 40,
                                    ),
                                    title: Text(
                                      samorzad.nazwa,
                                      style: TextStyle(fontSize: 18),
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
              child: Text("Gotowe", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
