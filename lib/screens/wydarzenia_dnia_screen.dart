// lib/screens/wydarzenia_dnia_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// 👇 model listy wydarzeń (tu jest WydarzenieListItem)
import 'package:mediapark/models/wydarzenia_models.dart';

// 👇 serwis do pobierania szczegółów
import 'package:mediapark/services/wydarzenia_service.dart';

// 👇 czyszczenie HTML w intro
import 'package:mediapark/helpers/html_helper.dart';

// 👇 ekran szczegółów jednego wydarzenia
import 'kalendarz_wydarzen_details_screen.dart';
import 'package:mediapark/style/app_style.dart';

class WydarzeniaDniaScreen extends StatefulWidget {
  final int idInstytucji;
  final DateTime day;
  final List<WydarzenieListItem> events;
  final Map<int, WydarzenieDetails>? preloadedDetails; // Nowy parametr

  const WydarzeniaDniaScreen({
    super.key,
    required this.idInstytucji,
    required this.day,
    required this.events,
    this.preloadedDetails, // Opcjonalny parametr
  });

  @override
  State<WydarzeniaDniaScreen> createState() => _WydarzeniaDniaScreenState();
}

class _WydarzeniaDniaScreenState extends State<WydarzeniaDniaScreen> {
  late final WydarzeniaService _service;
  final Map<int, WydarzenieDetails> _eventDetails = {};

  @override
  void initState() {
    super.initState();
    _service = WydarzeniaService(institutionId: widget.idInstytucji);

    // Jeśli mamy preloadowane szczegóły, użyj ich
    if (widget.preloadedDetails != null) {
      _eventDetails.addAll(widget.preloadedDetails!);
    }
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    forceMaterialTransparency: true,
    backgroundColor: AppColors.primary,
    elevation: 0,
    foregroundColor: AppColors.blackMedium,
    leading: Transform.translate(
      offset: Offset(8.w, 0),
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/back_button.svg',
          width: 40.w,
          height: 40.w,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    ),
    centerTitle: true,
  );

  @override
  Widget build(BuildContext context) {
    final dfTime = DateFormat('HH:mm');

    // Funkcja do formatowania czasu - tylko godzina rozpoczęcia
    String formatCzas(WydarzenieListItem e) {
      if (e.allDay) return 'Cały dzień';
      return dfTime.format(e.start);
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tytuł dnia pod AppBarem
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Text(
                _formatDayTitle(widget.day),
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 36.sp / 28.sp, // line-height: 36px
                  letterSpacing: 0,
                  color: AppColors.blackMedium,
                ),
              ),
            ),
            // Lista wydarzeń
            Expanded(
              child:
                  widget.events.isEmpty
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
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        itemCount: widget.events.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, i) {
                          final e = widget.events[i];
                          return _buildEventTile(context, e, formatCzas);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDayTitle(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(day.year, day.month, day.day);

    if (eventDay == today) {
      return 'Dzisiaj ${DateFormat('d.MM', 'pl_PL').format(day)}';
    } else if (eventDay == tomorrow) {
      return 'Jutro ${DateFormat('d.MM', 'pl_PL').format(day)}';
    } else {
      String formatted = DateFormat('EEEE d.MM', 'pl_PL').format(day);
      return formatted[0].toUpperCase() + formatted.substring(1);
    }
  }

  Widget _buildEventTile(
    BuildContext context,
    WydarzenieListItem event,
    String Function(WydarzenieListItem) formatCzas,
  ) {
    final details = _eventDetails[event.id];

    return InkWell(
      onTap: () => _openDetailsBottomSheet(context, event),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 361.w,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child:
            event.mainPhoto != null && event.mainPhoto!.isNotEmpty
                ? _buildEventTileWithImage(event, details, formatCzas)
                : _buildEventTileWithoutImage(event, details, formatCzas),
      ),
    );
  }

  Future<void> _openDetailsBottomSheet(
    BuildContext context,
    WydarzenieListItem event,
  ) async {
    final mq = MediaQuery.of(context);
    await showModalBottomSheet(
      context: context,
      useSafeArea: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // żeby było widać zaokrąglenie
      barrierColor: AppColors.blackMedium,
      builder: (ctx) {
        final sheetHeight = mq.size.height * 0.96;
        final topRadius = Radius.circular(24.r);
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            // obsługa klawiatury
            padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: topRadius),
                child: SizedBox(
                  height: sheetHeight,
                  child: Material(
                    // zapewnia efekt tła pod Scaffoldem childa
                    type: MaterialType.transparency,
                    child: KalendarzWydarzenDetailsScreen(
                      idInstytucji: widget.idInstytucji,
                      idWydarzenia: event.id,
                      tytul: event.title,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Kafelek bez zdjęcia
  Widget _buildEventTileWithoutImage(
    WydarzenieListItem event,
    WydarzenieDetails? details,
    String Function(WydarzenieListItem) formatCzas,
  ) {
    final description = details?.contentHtml ?? '';
    final cleanDescription = cleanHtmlString(description);

    return Container(
      width: 361.w,
      padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tytuł
          Text(
            details?.title ?? event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackMedium,
            ),
          ),
          SizedBox(height: 12.h),

          // Opis
          if (cleanDescription.isNotEmpty)
            Text(
              cleanDescription.length <= 120
                  ? cleanDescription
                  : '${cleanDescription.substring(0, 120)}...',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.blackMedium,
              ),
            ),
          SizedBox(height: 16.h),

          // Czas
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              formatCzas(event),
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.blackMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kafelek ze zdjęciem
  Widget _buildEventTileWithImage(
    WydarzenieListItem event,
    WydarzenieDetails? details,
    String Function(WydarzenieListItem) formatCzas,
  ) {
    return Container(
      width: 361.w,
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obrazek wydarzenia
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 100.w,
              height: 140.h,
              child: Image.network(event.mainPhoto!, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 24.w),
          // Szczegóły wydarzenia (rosnące)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  details?.title ?? event.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackMedium,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    formatCzas(event),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
