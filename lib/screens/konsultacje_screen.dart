import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/helpers/prettify.dart';
import '../models/konsultacje.dart';
import '../services/global_data_service.dart';
import '../screens/konsultacje_details_screen.dart';
import 'package:mediapark/style/app_style.dart';

class KonsultacjeScreen extends StatefulWidget {
  final String idInstytucji;

  const KonsultacjeScreen({super.key, required this.idInstytucji});

  @override
  State<KonsultacjeScreen> createState() => _KonsultacjeScreenState();
}

class _KonsultacjeScreenState extends State<KonsultacjeScreen> {
  final GlobalDataService _globalService = GlobalDataService();
  Map<String, List<Konsultacje>> _konsultacjeData = {};
  final List<Map<String, String>> categories = [
    {'key': 'active', 'label': 'Trwające'},
    {'key': 'planned', 'label': 'Zaplanowane'},
    {'key': 'finished', 'label': 'Zakończone'},
  ];

  String selectedCategory = 'active';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Show data immediately if available, otherwise show what we have
    setState(() {
      _konsultacjeData = _globalService.konsultacje;
      _isLoading = false; // Always show UI immediately
    });

    // Ensure global data is loaded in background
    _globalService.loadMunicipalityData(widget.idInstytucji).then((_) {
      if (mounted) {
        setState(() {
          _konsultacjeData = _globalService.konsultacje;
        });
      }
    }).catchError((e) {
      print('Background loading error in KonsultacjeScreen: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.primary,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Text(
              "Konsultacje",
              style: GoogleFonts.poppins(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildCategoryChips(),
            SizedBox(height: 12.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _konsultacjeData.isEmpty
                      ? const Center(child: Text('Wystąpił błąd pobierania danych'))
                      : _buildKonsultacjeList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((cat) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text(
                    cat['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  selected: selectedCategory == cat['key'],
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primaryMedium,
                  onSelected:
                      (_) => setState(() => selectedCategory = cat['key']!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    side: BorderSide(
                      color: AppColors.primaryMedium,
                      width: 2.w,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildKonsultacjeList() {
    final konsultacje = _konsultacjeData[selectedCategory] ?? [];
    if (konsultacje.isEmpty) {
      return const Center(child: Text('Brak konsultacji'));
    }

    return ListView.builder(
      itemCount: konsultacje.length,
      itemBuilder: (context, index) {
        final k = konsultacje[index];
        return _buildKonsultacjaTile(k);
      },
    );
  }

  Widget _buildKonsultacjaTile(Konsultacje k) {
    final hasValidImage = _globalService.isKonsultacjaImageValid(k.photoUrl);

    return Card(
      color: AppColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasValidImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.network(
                    k.photoUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(height: 24.h),
            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: [_buildTag(prettify(k.categoryAlias))],
            ),
            SizedBox(height: 16.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                k.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 17.sp,
                  color: Colors.black,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text.rich(
                  TextSpan(
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
                        text: "${k.startDate} - ${k.endDate}",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => KonsultacjeDetailsPage(konsultacja: k),
              //     ),
              //   );
              // },
            ),
            Divider(thickness: 1, color: AppColors.primaryMedium),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 30.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h, right: 8.w),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => KonsultacjeDetailsPage(konsultacja: k),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: BorderSide(color: Color(0xFFACD2DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                        ),
                        child: Text(
                          'Więcej',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h, left: 8.w),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => KonsultacjeDetailsPage(konsultacja: k),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                        ),
                        child: Text(
                          'Weź udział',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTag(String label) {
  return Container(
    padding: EdgeInsets.only(right: 12.w, left: 12.w, top: 8.h, bottom: 8.h),
    decoration: BoxDecoration(
      color: AppColors.secondary,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
    ),
  );
}


