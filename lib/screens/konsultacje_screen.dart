import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/helpers/prettify.dart';
import '../models/konsultacje.dart';
import '../services/konsultacje_service.dart';
import '../screens/konsultacje_details_screen.dart';

class KonsultacjeScreen extends StatefulWidget {
  const KonsultacjeScreen({super.key});

  @override
  State<KonsultacjeScreen> createState() => _KonsultacjeScreenState();
}

class _KonsultacjeScreenState extends State<KonsultacjeScreen> {
  final _service = KonsultacjeService();
  late Future<Map<String, List<Konsultacje>>> _future;
  final List<Map<String, String>> categories = [
    {'key': 'active', 'label': 'Trwające'},
    {'key': 'planned', 'label': 'Zaplanowane'},
    {'key': 'finished', 'label': 'Zakończone'},
  ];

  String selectedCategory = 'active';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchKonsultacje();
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
              child: FutureBuilder<Map<String, List<Konsultacje>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Wystąpił błąd pobierania danych'),
                    );
                  }

                  final konsultacje = snapshot.data![selectedCategory] ?? [];
                  if (konsultacje.isEmpty) {
                    return const Center(child: Text('Brak konsultacji'));
                  }

                  return ListView.builder(
                    key: PageStorageKey<String>(
                      'konsultacjeList_$selectedCategory',
                    ),
                    itemCount: konsultacje.length,
                    itemBuilder: (context, index) {
                      final k = konsultacje[index];
                      return _buildKonsultacjaTile(k);
                    },
                  );
                },
              ),
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
                  selectedColor: const Color(0xFFBCE1EB),
                  backgroundColor: const Color(0xFFACD2DD),
                  onSelected:
                      (_) => setState(() => selectedCategory = cat['key']!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    side: BorderSide(
                      color: const Color(0xFFACD2DD),
                      width: 2.w,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildKonsultacjaTile(Konsultacje k) {
    return Card(
      color: const Color(0xFFCAECF4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((k.photoUrl ?? '').isNotEmpty)
              Image.network(
                k.photoUrl!,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: AspectRatio(aspectRatio: 3 / 2, child: child),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
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
            Divider(thickness: 1, color: Color(0xFFACD2DD)),
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
                          backgroundColor: const Color(0xFFCAECF4),
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

Future<bool> _checkImageExists(String url) async {
  try {
    final client = HttpClient();
    final request = await client.headUrl(Uri.parse(url));
    final response = await request.close();
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Widget _buildTag(String label) {
  return Container(
    padding: EdgeInsets.only(right: 12.w, left: 12.w, top: 8.h, bottom: 8.h),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F1C3),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
    ),
  );
}


