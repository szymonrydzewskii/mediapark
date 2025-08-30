import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediapark/helpers/html_helper.dart';
import 'package:mediapark/models/wydarzenia_models.dart';
import 'package:mediapark/services/wydarzenia_service.dart';

class KalendarzWydarzenDetailsScreen extends StatefulWidget {
  final int idInstytucji;
  final int idWydarzenia;
  final String tytul; // szybciej pokażemy tytuł

  const KalendarzWydarzenDetailsScreen({
    super.key,
    required this.idInstytucji,
    required this.idWydarzenia,
    required this.tytul,
  });

  @override
  State<KalendarzWydarzenDetailsScreen> createState() =>
      _KalendarzWydarzenDetailsScreenState();
}

class _KalendarzWydarzenDetailsScreenState
    extends State<KalendarzWydarzenDetailsScreen> {
  static const backgroundColor = Color(0xFFBCE1EB);
  late final WydarzeniaService _service;
  late Future<WydarzenieDetails> _future;

  final _df = DateFormat('dd.MM.yyyy HH:mm');
  final _dfTimeOnly = DateFormat('HH:mm');
  final _dfDayShort = DateFormat('dd.MM.yy');

  @override
  void initState() {
    super.initState();
    _service = WydarzeniaService(institutionId: widget.idInstytucji);
    _future = _service.fetchSzczegoly(widget.idWydarzenia);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/quit_button.svg',
                width: 40.w,
                height: 40.w,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<WydarzenieDetails>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || !snap.hasData) {
              return Center(
                child: Text('Błąd: ${snap.error ?? 'brak danych'}'),
              );
            }

            final d = snap.data!;

            // === TYLKO ZMIANA TEGO TEKSTU ===
            String chipText;
            DateTime norm(DateTime x) => DateTime(x.year, x.month, x.day);
            final today = norm(DateTime.now());
            final tomorrow = norm(DateTime.now().add(const Duration(days: 1)));
            final eventDay = norm(d.start);

            if (d.allDay) {
              chipText = '${_dfDayShort.format(d.start)} / Cały dzień';
            } else if (eventDay == today) {
              chipText = 'Dzisiaj / ${_dfTimeOnly.format(d.start)}';
            } else if (eventDay == tomorrow) {
              chipText = 'Jutro / ${_dfTimeOnly.format(d.start)}';
            } else {
              chipText =
                  '${_dfDayShort.format(d.start)} / ${_dfTimeOnly.format(d.start)}';
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 CHIP pod AppBarem po lewej
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F1C3),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      chipText,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 🔹 Tytuł wydarzenia
                  Text(
                    widget.tytul,
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.125,
                      letterSpacing: 0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // 🖼️ Obraz wydarzenia (jeśli istnieje) - osobny kontener
                  if (d.mainPhoto != null && d.mainPhoto!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 24.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40.r),
                        child: Image.network(
                          d.mainPhoto!,
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200.h,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // 📝 Treść wydarzenia - bezpośrednio na niebieskim tle
                  Text(
                    cleanHtmlString(d.contentHtml),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}