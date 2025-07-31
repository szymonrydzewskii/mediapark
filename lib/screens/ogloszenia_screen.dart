import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mediapark/models/ogloszenia.dart';
import 'package:mediapark/screens/ogloszenia_details_screen.dart';
import 'package:mediapark/services/ogloszenia_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OgloszeniaScreen extends StatefulWidget {
  final String idInstytucji;

  const OgloszeniaScreen({super.key, required this.idInstytucji});

  @override
  State<OgloszeniaScreen> createState() => _OgloszeniaScreenState();
}

class _OgloszeniaScreenState extends State<OgloszeniaScreen> {
  late OgloszeniaService _service;
  late Future<List<Ogloszenia>> _future;
  List<KategoriaOgloszen> _kategorie = [];
  int? _wybranaKategoria;

  @override
  void initState() {
    super.initState();
    _service = OgloszeniaService(idInstytucji: widget.idInstytucji);
    _loadData();
  }

  Future<void> _loadData() async {
    _future = _service.fetchWszystkie();
    final kategorie = await _service.fetchKategorie();
    setState(() {
      _kategorie = kategorie;
    });
  }

  void _filtruj(int? id) {
    setState(() {
      _wybranaKategoria = id;
      _future =
          id == null ? _service.fetchWszystkie() : _service.fetchZKategorii(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCE1EB),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFBCE1EB),
        elevation: 0,
        foregroundColor: Colors.black,
        leading: Transform.translate(
          offset: Offset(8.w, 0),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_button.svg',
              width: 40.w,
              height: 40.w,
            ),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Ogłoszenia",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildKategorieChips(),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Ogloszenia>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final err = snapshot.error.toString().toLowerCase();
                    final isBrakDanych =
                        err.contains("nie znaleziono") || err.contains("brak");
                    return Center(
                      child: Text(
                        isBrakDanych
                            ? 'Nie znaleziono ogłoszeń'
                            : 'Wystąpił błąd pobierania danych',
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Brak ogłoszeń'));
                  }

                  final ogloszenia = snapshot.data!;
                  return ListView.builder(
                    itemCount: ogloszenia.length,
                    itemBuilder: (context, index) {
                      final o = ogloszenia[index];
                      return _buildOgloszenieTile(o);
                    },
                  );
                },
              ),
            ),

            // PRZYCISK POKAZ WIECEJ

            // const SizedBox(height: 10),
            // Center(
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Color(0xFF1D1F1F),
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(25),
            //       ),
            //     ),
            //     onPressed: () {}, // TODO: Pokaż więcej
            //     child: const Padding(
            //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            //       child: Text("Pokaż więcej"),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKategorieChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip("Najnowsze", null),
          ..._kategorie.map((k) => _buildChip(k.name, k.id)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int? id) {
    final isSelected = _wybranaKategoria == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        showCheckmark: false,
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFFBCE1EB),
        backgroundColor: const Color(0xFFACD2DD),
        onSelected: (_) => _filtruj(id),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Color(0xFFACD2DD), width: 2.w),
        ),
      ),
    );
  }

  Widget _buildOgloszenieTile(Ogloszenia o) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OgloszeniaDetailsScreen(ogloszenie: o),
          ),
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Card(
        color: const Color(0xFFCAECF4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (o.mainPhoto != null && o.mainPhoto!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    o.mainPhoto!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: -8,
                      children: [
                        if (o.categoryName != null)
                          _buildTag(o.categoryName!)
                        else
                          Text(o.alias),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o.intro,
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "dodane ${_czasDodania(o.datetime)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFACD2DD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _czasDodania(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 1) return "${diff.inDays} dni temu";
      if (diff.inHours >= 1) return "${diff.inHours} godzin temu";
      return "dzisiaj";
    } catch (_) {
      return datetime;
    }
  }
}
