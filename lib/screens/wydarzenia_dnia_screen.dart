// lib/screens/wydarzenia_dnia_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// 👇 model listy wydarzeń (tu jest WydarzenieListItem)
import 'package:mediapark/models/wydarzenia_models.dart';

// 👇 czyszczenie HTML w intro
import 'package:mediapark/helpers/html_helper.dart';

// 👇 ekran szczegółów jednego wydarzenia
import 'kalendarz_wydarzen_details_screen.dart';

class WydarzeniaDniaScreen extends StatelessWidget {
  final int idInstytucji;
  final DateTime day;
  final List<WydarzenieListItem> events;

  const WydarzeniaDniaScreen({
    super.key,
    required this.idInstytucji,
    required this.day,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final dfDay = DateFormat('d MMMM yyyy', 'pl_PL');
    final dfTime = DateFormat('HH:mm');

    String czas(WydarzenieListItem e) {
      if (e.allDay) return 'cały dzień';
      final s = dfTime.format(e.start);
      final ee = (e.end != null) ? dfTime.format(e.end!) : '';
      return ee.isEmpty ? s : '$s–$ee';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFBCE1EB),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFBCE1EB),
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          dfDay.format(day),
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            events.isEmpty
                ? Center(
                  child: Text(
                    'Brak wydarzeń',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) {
                    final e = events[i];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => KalendarzWydarzenDetailsScreen(
                                  idInstytucji: idInstytucji,
                                  idWydarzenia: e.id,
                                  tytul: e.title,
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // chip z czasem
                            Container(
                              width: 70.w,
                              padding: EdgeInsets.symmetric(
                                vertical: 6.h,
                                horizontal: 8.w,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFACD2DD),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                czas(e),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // tytuł + intro
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if ((e.intro ?? '').isNotEmpty) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      cleanHtmlString(e.intro!),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
