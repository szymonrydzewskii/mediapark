import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/models/ogloszenia.dart';
import 'package:mediapark/screens/ogloszenia_details_screen.dart';
import 'package:mediapark/services/global_data_service.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/common_widgets.dart';
import 'package:mediapark/widgets/illustration_empty_state.dart'; // <-- NOWY IMPORT

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _error = null;

      // wczytaj cache jeśli jest
      _kategorie = _globalService.kategorie;
      _kategorieMap = {for (var k in _kategorie) k.id: k.name};
      _ogloszenia = _globalService.ogloszenia;

      // ✅ klucz: dopóki nie wiemy co z API, traktuj jako loading
      _isLoading = true;
    });

    try {
      await _globalService.loadMunicipalityData(widget.idInstytucji);

      if (!mounted) return;
      setState(() {
        _error = null;
        _kategorie = _globalService.kategorie;
        _kategorieMap = {for (var k in _kategorie) k.id: k.name};
        _ogloszenia = _globalService.ogloszenia;
        _isLoading = false; // ✅ koniec
      });
    } catch (e) {
      debugPrint('Background loading error in OgloszeniaScreen: $e');

      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _wybranaKategoria = null;
        _kategorie = [];
        _kategorieMap = {};
        _ogloszenia = [];
        _isLoading = false; // ✅ koniec
      });
    }
  }

  void _filtruj(dynamic id) {
    setState(() {
      _wybranaKategoria = id as int?;
      _ogloszenia = _globalService.getOgloszeniaByCategory(_wybranaKategoria);
    });
  }

  List<ChipCategory> get _chipCategories => [
    const ChipCategory(label: "Najnowsze", value: null),
    ..._kategorie.map((k) => ChipCategory(label: k.name, value: k.id)),
  ];

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null;
    final hideChips = hasError || _isLoading;

    return ListScreenLayoutWithPhoto(
      title: "Ogłoszenia",

      // ✅ na błędzie nie pokazuj chipów
      categoryBar:
          hideChips
              ? const SizedBox.shrink()
              : CategoryChipBar(
                categories: _chipCategories,
                selectedValue: _wybranaKategoria,
                onSelected: _filtruj,
              ),

      isLoading: _isLoading,

      // ✅ nie pozwól, żeby layout wszedł w "empty" przy błędzie (bo chcesz custom widget)
      isEmpty: !_isLoading && !hasError && _ogloszenia.isEmpty,

      mainEmptyMessage: 'Brak ogłoszeń\nw tej okolicy',
      secondEmptyMessage: 'Zajrzyj do nas jutro',

      // ✅ zawartość: na błędzie pokaż IllustrationEmptyState
      listContent:
          hasError
              ? Center(
                child: IllustrationEmptyState(
                  mainText: "Przepraszamy, wystąpił chwilowy problem.",
                  secondaryText: "Już nad nim pracujemy.",
                  assetPath: "assets/icons/network-error.svg",
                  type: 2,
                ),
              )
              : ListView.builder(
                itemCount: _ogloszenia.length,
                itemBuilder: (context, index) {
                  final o = _ogloszenia[index];
                  return _buildOgloszenieTile(o);
                },
              ),
    );
  }

  Widget _buildOgloszenieTile(Ogloszenia o) {
    // final hasValidImage = _globalService.isImageValid(o.photoUrl);
    final hasCategory =
        o.idCategory != null && _kategorieMap.containsKey(o.idCategory);

    final url = o.photoUrl?.trim();
    final hasValidImage = url != null && url.isNotEmpty;

    return BaseListCard(
      onTap: () => _navigateToDetails(o),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasValidImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Image.network(
                  o.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          if (hasCategory) ...[
            CategoryTag(label: _kategorieMap[o.idCategory!]!),
            SizedBox(height: 16.h),
          ],

          Text(
            o.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 12.h),

          // możesz użyć intro zamiast getOgloszenieContent (zależnie co chcesz pokazać)
          Text(
            o.intro,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 16.h),
          _buildDateInfo(o.datetime),
          SizedBox(height: 16.h),
          Divider(thickness: 1, color: AppColors.divider),
          SizedBox(height: 16.h),

          Center(
            child: CardActionButton(
              label: 'Więcej',
              onPressed: () => _navigateToDetails(o),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String datetime) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "dodane ",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: _czasDodania(datetime),
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(Ogloszenia o) {
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
  }

  String _czasDodania(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final diff = DateTime.now().difference(dt);

      if (diff.inDays == 7) return "tydzień temu";
      if (diff.inDays > 7) {
        return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }
      if (diff.inDays >= 1) return "${diff.inDays} dni temu";
      if (diff.inHours >= 1) return "${diff.inHours} godzin temu";
      return "dzisiaj";
    } catch (_) {
      return datetime;
    }
  }
}
