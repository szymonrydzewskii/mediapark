import 'package:flutter/material.dart';
import 'package:mediapark/preferences_helper.dart';
import 'package:mediapark/samorzad_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/main_window.dart';

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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainWindow(wybraneSamorzady: wybraneObiekty),
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Wyszukaj',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ), // GoogleFonts.roboto dynamiczne
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
              ),
              // onChanged dynamiczne, nie const
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
