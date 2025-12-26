import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/animations/fade_in_up.dart';
import 'package:mediapark/helpers/haptics.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/helpers/preferences_helper.dart';
import 'package:mediapark/widgets/bottom_nav_bar.dart';
import 'package:mediapark/services/cached_samorzad_service.dart';
import 'package:mediapark/services/cached_samorzad_details_service.dart';
import 'package:mediapark/services/global_data_service.dart';
import 'package:mediapark/style/app_style.dart';

class SelectingSamorzad extends StatefulWidget {
  const SelectingSamorzad({super.key});

  @override
  State<SelectingSamorzad> createState() => _SelectingSamorzadState();
}

class _SelectingSamorzadState extends State<SelectingSamorzad> {
  final _samorzadService = CachedSamorzadService();
  final _detailsService = CachedSamorzadDetailsService();
  final _globalDataService = GlobalDataService();
  static const backgroundColor = AppColors.primary;

  List<Samorzad> wszystkieSamorzady = [];
  List<Samorzad> filtrowaneSamorzady = [];
  Set<String> wybraneSamorzady = {};
  String wpisanyText = '';
  bool showLoader = true;
  bool dataLoaded = false;

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
    try {
      final samorzady = await _samorzadService.loadSamorzad();
      final zapisaneId = await PreferencesHelper.getSelectedSamorzady();

      if (!mounted) return;
      setState(() {
        wszystkieSamorzady = samorzady;
        filtrowaneSamorzady = samorzady;
        wybraneSamorzady = zapisaneId;
        dataLoaded = true;
        showLoader = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => showLoader = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd ładowania: $e')));
      }
    }
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
    if (wybraneSamorzady.isEmpty) return;

    await PreferencesHelper.saveSelectedSamorzady(wybraneSamorzady);
    if (!mounted) return;

    final wybraneObiekty =
        wszystkieSamorzady
            .where((s) => wybraneSamorzady.contains(s.id))
            .toSet();

    // Navigate immediately without waiting
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) => BottomNavBar(
              aktywnySamorzad: wybraneObiekty.first,
              wybraneSamorzady: wybraneObiekty,
            ),
      ),
      (route) => false,
    );

    // ✅ Preload data for all selected municipalities in background (bez crashy)
    () async {
      try {
        await Future.wait([
          // Load details for all selected municipalities
          ...wybraneObiekty.map(
            (samorzad) => _detailsService
                .fetchSzczegolyInstytucji(samorzad.id)
                .catchError((_) {}),
          ),

          // Load module data for all selected municipalities
          ...wybraneObiekty.map(
            (samorzad) => _globalDataService
                .loadMunicipalityData(samorzad.id.toString())
                .catchError((_) {}),
          ),
        ]);
      } catch (e) {
        debugPrint('Background preloading error: $e');
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SizedBox(height: 64.h),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Szukaj',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: AppColors.primaryMedium,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.r)),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onSearch,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _buildScrollableListCard(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Text(
              'Zawsze możesz zmienić swój wybór później',
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: ElevatedButton(
              onPressed: wybraneSamorzady.isNotEmpty ? onSubmit : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text(
                "Gotowe",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableListCard() {
    if (showLoader) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filtrowaneSamorzady.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'Brak wyników dla wyszukiwania.',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(filtrowaneSamorzady.length, (index) {
            final samorzad = filtrowaneSamorzady[index];
            final isSelected = wybraneSamorzady.contains(samorzad.id);
            final isFirst = index == 0;
            final isLast = index == filtrowaneSamorzady.length - 1;

            return FadeInUpWidget(
              key: ValueKey(samorzad.id),
              delay: Duration(milliseconds: 50 * index),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: isFirst ? Radius.circular(20.r) : Radius.zero,
                      bottom: isLast ? Radius.circular(20.r) : Radius.zero,
                    ),
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Haptics.tap();
                          onSelect(samorzad);
                        },
                        child: SizedBox(
                          height: 70.h,
                          child: Row(
                            children: [
                              SizedBox(width: 19.w),
                              AdaptiveNetworkImage(
                                key: ValueKey('herb_${samorzad.id}'),
                                url: samorzad.herb,
                                width: 32.w,
                                height: 32.h,
                              ),
                              SizedBox(width: 23.w),
                              Expanded(
                                child: Text(
                                  samorzad.nazwa,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: EdgeInsets.only(right: 20.w),
                                  child: SvgPicture.asset(
                                    'assets/icons/picked.svg',
                                    width: 24.w,
                                    height: 24.h,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
