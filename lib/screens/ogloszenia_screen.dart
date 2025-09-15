import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mediapark/models/ogloszenia.dart';
import 'package:mediapark/screens/ogloszenia_details_screen.dart';
import 'package:mediapark/services/global_data_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OgloszeniaScreen extends StatefulWidget {
  final String idInstytucji;

  const OgloszeniaScreen({super.key, required this.idInstytucji});

  @override
  State<OgloszeniaScreen> createState() => _OgloszeniaScreenState();
}

class _OgloszeniaScreenState extends State<OgloszeniaScreen> {
  final GlobalDataService _globalService = GlobalDataService();
  List<Ogloszenia> _ogloszenia = [];
  List<KategoriaOgloszen> _kategorie = [];
  Map<int, String> _kategorieMap = {};
  int? _wybranaKategoria;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Show data immediately if available, otherwise show what we have
    setState(() {
      _kategorie = _globalService.kategorie;
      _kategorieMap = {for (var k in _kategorie) k.id: k.name};
      _ogloszenia = _globalService.ogloszenia;
      _isLoading = false; // Always show UI immediately
    });

    // Ensure global data is loaded in background
    _globalService.loadMunicipalityData(widget.idInstytucji).then((_) {
      if (mounted) {
        setState(() {
          _kategorie = _globalService.kategorie;
          _kategorieMap = {for (var k in _kategorie) k.id: k.name};
          _ogloszenia = _globalService.ogloszenia;
        });
      }
    }).catchError((e) {
      print('Background loading error in OgloszeniaScreen: $e');
    });
  }

  void _filtruj(int? id) {
    setState(() {
      _wybranaKategoria = id;
      _ogloszenia = _globalService.getOgloszeniaByCategory(id);
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Ogłoszenia",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildKategorieChips(),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ogloszenia.isEmpty
                      ? const Center(child: Text('Brak ogłoszeń'))
                      : ListView.builder(
                          itemCount: _ogloszenia.length,
                          itemBuilder: (context, index) {
                            final o = _ogloszenia[index];
                            final hasValidImage = _globalService.isImageValid(o.mainPhoto);

                            return hasValidImage
                                ? _buildOgloszenieTileWithImage(o)
                                : _buildOgloszenieTileWithoutImage(o);
                          },
                        ),
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
    );
  }

  Widget _buildKategorieChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        child: Row(
          children: [
            _buildChip("Najnowsze", null),
            ..._kategorie.map((k) => _buildChip(k.name, k.id)),
          ],
        ),
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
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: Color(0xFFACD2DD), width: 2.w),
        ),
      ),
    );
  }

  Widget _buildOgloszenieTileWithImage(Ogloszenia o) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => OgloszeniaDetailsScreen(
                  ogloszenie: o,
                  idInstytucji: widget.idInstytucji,
                ),
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
          padding: EdgeInsets.fromLTRB(22.w, 12.h, 12.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  o.mainPhoto!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (o.idCategory != null &&
                        _kategorieMap.containsKey(o.idCategory)) ...[
                      SizedBox(height: 12.h),
                      _buildTag(_kategorieMap[o.idCategory]!),
                      SizedBox(height: 12.h),
                    ],
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Text(
                        o.title,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "dodane ",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                          TextSpan(
                            text: _czasDodania(o.datetime),
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOgloszenieTileWithoutImage(Ogloszenia o) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => OgloszeniaDetailsScreen(
                  ogloszenie: o,
                  idInstytucji: widget.idInstytucji,
                ),
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
          padding: EdgeInsets.fromLTRB(22.w, 12.h, 12.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (o.idCategory != null &&
                  _kategorieMap.containsKey(o.idCategory)) ...[
                SizedBox(height: 12.h),
                _buildTag(_kategorieMap[o.idCategory]!),
                SizedBox(height: 12.h),
              ],
              Padding(
                padding: EdgeInsets.only(right: 30.w),
                child: Text(
                  o.title,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(right: 60.w),
                child: Text(
                  _globalService.getOgloszenieContent(o.id),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 24.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "dodane ",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    TextSpan(
                      text: _czasDodania(o.datetime),
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFACD2DD),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
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
