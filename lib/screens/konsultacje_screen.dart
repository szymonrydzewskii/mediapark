import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/helpers/prettify.dart';
import 'package:mediapark/models/konsultacje.dart';
import 'package:mediapark/screens/konsultacje_details_screen.dart';
import 'package:mediapark/services/global_data_service.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/common_widgets.dart';
import 'package:mediapark/widgets/webview_page.dart'; // <-- NOWY IMPORT

class KonsultacjeScreen extends StatefulWidget {
  final String idInstytucji;

  const KonsultacjeScreen({super.key, required this.idInstytucji});

  @override
  State<KonsultacjeScreen> createState() => _KonsultacjeScreenState();
}

class _KonsultacjeScreenState extends State<KonsultacjeScreen> {
  final GlobalDataService _globalService = GlobalDataService();
  Map<String, List<Konsultacje>> _konsultacjeData = {};
  String selectedCategory = 'active';
  bool _isLoading = true;

  static const List<ChipCategory> _chipCategories = [
    ChipCategory(label: 'Trwające', value: 'active'),
    ChipCategory(label: 'Zaplanowane', value: 'planned'),
    ChipCategory(label: 'Zakończone', value: 'finished'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _konsultacjeData = _globalService.konsultacje;
      _isLoading = false;
    });

    _globalService
        .loadMunicipalityData(widget.idInstytucji)
        .then((_) {
          if (mounted) {
            setState(() {
              _konsultacjeData = _globalService.konsultacje;
            });
          }
        })
        .catchError((e) {
          debugPrint('Background loading error in KonsultacjeScreen: $e');
        });
  }

  void _onCategorySelected(dynamic value) {
    setState(() {
      selectedCategory = value as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    final konsultacje = _konsultacjeData[selectedCategory] ?? [];

    return ListScreenLayoutWithPhoto(
      title: "Konsultacje",
      categoryBar: CategoryChipBar(
        categories: _chipCategories,
        selectedValue: selectedCategory,
        onSelected: _onCategorySelected,
      ),
      isLoading: _isLoading,
      // Pusty stan zależy od aktualnie wybranej kategorii:
      isEmpty: !_isLoading && konsultacje.isEmpty,
      mainEmptyMessage: 'Brak konsultacji\nw tej okolicy',
      secondEmptyMessage: 'Zajrzyj do nas jutro',
      listContent: ListView.builder(
        itemCount: konsultacje.length,
        itemBuilder: (context, index) {
          return _buildKonsultacjaTile(konsultacje[index]);
        },
      ),
    );
  }

  Widget _buildKonsultacjaTile(Konsultacje k) {
    final hasValidImage = _globalService.isKonsultacjaImageValid(k.photoUrl);
    final hasCategory = k.categoryAlias.trim().isNotEmpty; // 👈 NOWE

    return BaseListCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasValidImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Image.network(k.photoUrl!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // 👇 Pokaż CategoryTag tylko jeśli jest categoryAlias
          if (hasCategory) ...[
            CategoryTag(
              label: prettify(k.categoryAlias),
              backgroundColor: AppColors.secondary,
            ),
            SizedBox(height: 16.h),
          ],

          Text(
            k.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDateRange(k.startDate, k.endDate),
          SizedBox(height: 16.h),
          Divider(thickness: 1, color: AppColors.primaryMedium),
          SizedBox(height: 16.h),
          _buildActionButtons(k),
        ],
      ),
    );
  }

  Widget _buildDateRange(String startDate, String endDate) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Konsultacja trwa\n',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: "$startDate - $endDate",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Konsultacje k) {
    final hasPoll = k.idPoll != 0 && k.pollUrl != null && k.pollUrl!.isNotEmpty;

    // 🔹 PRZYPADEK: brak ankiety → zachowuj się jak w ogłoszeniach
    if (!hasPoll) {
      return Center(
        child: CardActionButton(
          label: 'Więcej',
          onPressed: () => _navigateToDetails(k),
        ),
      );
    }

    // 🔹 PRZYPADEK: jest ankieta → dwa przyciski obok siebie (jak masz teraz)
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          Expanded(
            child: CardActionButton(
              label: 'Więcej',
              onPressed: () => _navigateToDetails(k),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CardActionButton(
              label: 'Weź udział',
              isPrimary: true,
              onPressed: () => _navigateToPoll(k),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPoll(Konsultacje k) {
    if (k.pollUrl == null || k.pollUrl!.isEmpty) {
      // opcjonalnie: można pokazać SnackBar z błędem
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => WebViewPage(
              url: k.pollUrl!,
              title: k.title, // możesz dać np. "Weź udział"
            ),
      ),
    );
  }

  void _navigateToDetails(Konsultacje k) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KonsultacjeDetailsPage(konsultacja: k, idInstytucji: widget.idInstytucji,)),
    );
  }
}
