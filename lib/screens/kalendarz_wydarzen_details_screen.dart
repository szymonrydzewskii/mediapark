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
  State<KalendarzWydarzenDetailsScreen> createState() => _KalendarzWydarzenDetailsScreenState();
}

class _KalendarzWydarzenDetailsScreenState extends State<KalendarzWydarzenDetailsScreen> {
  static const backgroundColor = Color(0xFFBCE1EB);
  late final WydarzeniaService _service;
  late Future<WydarzenieDetails> _future;
  final _df = DateFormat('dd.MM.yyyy HH:mm');

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
        leading: Transform.translate(
          offset: Offset(8.w, 0),
          child: IconButton(
            icon: SvgPicture.asset('assets/icons/back_button.svg', width: 40.w, height: 40.w),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(
          widget.tytul,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<WydarzenieDetails>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || !snap.hasData) {
              return Center(child: Text('Błąd: ${snap.error ?? 'brak danych'}'));
            }
            final d = snap.data!;
            final czas = d.allDay
                ? 'cały dzień'
                : d.end == null
                    ? _df.format(d.start)
                    : '${_df.format(d.start)} – ${_df.format(d.end!)}';

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // meta
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCAECF4),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: Colors.black87),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            czas,
                            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // treść
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      cleanHtmlString(d.contentHtml),
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w400),
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
