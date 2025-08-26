// lib/screens/kalendarz_wydarzen_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediapark/screens/wydarzenia_dnia_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mediapark/models/wydarzenia_models.dart';
import 'package:mediapark/services/wydarzenia_service.dart';
import 'package:mediapark/helpers/html_helper.dart';
import 'kalendarz_wydarzen_details_screen.dart';

class KalendarzWydarzenScreen extends StatefulWidget {
  final int idInstytucji;
  const KalendarzWydarzenScreen({super.key, required this.idInstytucji});

  @override
  State<KalendarzWydarzenScreen> createState() =>
      _KalendarzWydarzenScreenState();
}

class _KalendarzWydarzenScreenState extends State<KalendarzWydarzenScreen> {
  // Константы UI
  static const _cellW = 43.0;
  static const _cellH = 65.6;
  static const _cellGapX = 10.0;
  static const _cellGapY = 10.0;
  static const _cellRadius = 15.0;
  static const _padL = 10.0;
  static const _padR = 10.0;
  static const _padSafeV = 6.0;
  static const backgroundColor = Color(0xFFBCE1EB);
  static const _navigationDebounce = Duration(milliseconds: 300);

  // Kontrolery i stan
  PageController? _calPageController;
  late final WydarzeniaService _service;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  DateTime? _lastNavigation;

  // Dane wydarzeń
  final Map<DateTime, List<WydarzenieListItem>> _eventsByDay = {};
  List<WydarzenieListItem> _allEvents = [];
  List<WydarzenieListItem> _upcoming = [];
  late Future<void> _loadFuture;

  // Formatery dat (const dla wydajności)
  static final _dfDay = DateFormat('dd.MM.yy');
  static final _dfTime = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _service = WydarzeniaService(institutionId: widget.idInstytucji);
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = _normalize(now);
    _loadFuture = _load();
  }

  @override
  void dispose() {
    // Bezpieczne dispose PageController
    if (_calPageController != null) {
      try {
        if (_calPageController!.hasClients) {
          _calPageController!.dispose();
        }
      } catch (e) {
        // PageController został już disposed przez TableCalendar
        debugPrint('PageController już disposed: $e');
      }
      _calPageController = null;
    }
    super.dispose();
  }

  Future<void> _load() async {
    final list = await _service.fetchWszystkieStrony(startPage: 1);
    _allEvents = List<WydarzenieListItem>.from(list);

    // Grupowanie i filtrowanie w jednej pętli
    _eventsByDay.clear();
    final now = DateTime.now();
    final upcomingEvents = <WydarzenieListItem>[];

    for (final event in _allEvents) {
      // Grupowanie do kalendarza
      final day = _normalize(event.start);
      (_eventsByDay[day] ??= []).add(event);

      // Filtrowanie nadchodzących
      if (event.start.isAfter(now) ||
          isSameDay(event.start, now) ||
          (event.end?.isAfter(now) ?? false)) {
        upcomingEvents.add(event);
      }
    }

    // Sortowanie w każdym dniu kalendarza
    _eventsByDay.forEach(
      (_, events) => events.sort((a, b) => a.start.compareTo(b.start)),
    );

    // Sortowanie nadchodzących lub fallback
    _upcoming =
        upcomingEvents.isEmpty
            ? List<WydarzenieListItem>.from(_allEvents)
            : upcomingEvents;
    _upcoming.sort((a, b) => a.start.compareTo(b.start));

    if (mounted) setState(() {});
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  List<WydarzenieListItem> _getEventsForDay(DateTime day) =>
      _eventsByDay[_normalize(day)] ?? const [];

  void _goPrevMonth() {
    // Debounce - zapobiega zbyt szybkim kliknięciom
    final now = DateTime.now();
    if (_lastNavigation != null &&
        now.difference(_lastNavigation!) < _navigationDebounce) {
      return;
    }
    _lastNavigation = now;

    // Sprawdź czy widget jest jeszcze zamontowany i controller istnieje
    if (!mounted || _calPageController == null) return;

    try {
      // Sprawdź czy controller ma jeszcze aktywnych klientów
      if (_calPageController!.hasClients) {
        _calPageController!.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      // PageController został już disposed
      debugPrint('PageController już disposed w _goPrevMonth: $e');
    }
  }

  void _goNextMonth() {
    // Debounce - zapobiega zbyt szybkim kliknięciom
    final now = DateTime.now();
    if (_lastNavigation != null &&
        now.difference(_lastNavigation!) < _navigationDebounce) {
      return;
    }
    _lastNavigation = now;

    // Sprawdź czy widget jest jeszcze zamontowany i controller istnieje
    if (!mounted || _calPageController == null) return;

    try {
      // Sprawdź czy controller ma jeszcze aktywnych klientów
      if (_calPageController!.hasClients) {
        _calPageController!.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      // PageController został już disposed
      debugPrint('PageController już disposed w _goNextMonth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Błąd ładowania: ${snap.error}'));
            }
            return _buildContent();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    forceMaterialTransparency: true,
    backgroundColor: backgroundColor,
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
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    ),
    centerTitle: true,
  );

  Widget _buildContent() => CustomScrollView(
    slivers: [
      // Kalendarz
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        sliver: SliverToBoxAdapter(child: _buildCalendar()),
      ),

      // Divider z paddingiem
      SliverPadding(
        padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 24.h),
        sliver: SliverToBoxAdapter(child: _calendarDivider()),
      ),

      // Nagłówek
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
        sliver: SliverToBoxAdapter(
          child: Text(
            'Nadchodzące\nwydarzenia',
            style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),

      // Lista wydarzeń
      _upcoming.isEmpty ? _buildEmptySliver() : _buildEventsList(),
    ],
  );

  Widget _calendarDivider() => SizedBox(
    width: ((_cellW + _cellGapX) * 7).w,
    child: const Divider(color: Color(0xFF96C5D1), thickness: 1, height: 1),
  );

  Widget _buildCalendar() {
    final calendarWidth = ((_cellW + _cellGapX) * 7).w;
    final title = toBeginningOfSentenceCase(
      DateFormat('LLLL yyyy', 'pl_PL').format(_focusedDay),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        SizedBox(
          width: calendarWidth,
          child: Row(
            children: [
              Text(
                title ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              _buildNavButton(Icons.chevron_left, _goPrevMonth),
              SizedBox(width: 4.w),
              _buildNavButton(Icons.chevron_right, _goNextMonth),
            ],
          ),
        ),

        SizedBox(height: 24.h),
        _calendarDivider(),
        SizedBox(height: 24.h),

        // Kalendarz
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: calendarWidth,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: _buildTableCalendar(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) => IconButton(
    icon: Icon(icon, color: Colors.black),
    iconSize: 24.w,
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    onPressed: onPressed,
  );

  Widget _buildTableCalendar() {
    final now = DateTime.now();
    return TableCalendar<WydarzenieListItem>(
      locale: 'pl_PL',
      firstDay: DateTime(now.year - 2),
      lastDay: DateTime(now.year + 2, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      onCalendarCreated: (pc) => _calPageController = pc,
      onPageChanged: (fd) {
        if (mounted) {
          setState(() => _focusedDay = fd);
        }
      },
      onDaySelected: _onDaySelected,
      headerVisible: false,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: (_cellH + _cellGapY).h,
      daysOfWeekStyle: _buildDaysOfWeekStyle(),
      calendarStyle: _buildCalendarStyle(),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) => _buildDayCell(date),
        todayBuilder: (context, date, _) => _buildDayCell(date, isToday: true),
        selectedBuilder:
            (context, date, _) => _buildDayCell(
              date,
              isSelected: true,
              isToday: isSameDay(date, now),
            ),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!mounted) return;

    setState(() {
      _selectedDay = _normalize(selectedDay);
      _focusedDay = focusedDay;
    });

    final events = _getEventsForDay(selectedDay);
    if (events.isNotEmpty && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => WydarzeniaDniaScreen(
                idInstytucji: widget.idInstytucji,
                day: _normalize(selectedDay),
                events: events,
              ),
        ),
      );
    }
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle() => DaysOfWeekStyle(
    weekdayStyle: GoogleFonts.poppins(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    weekendStyle: GoogleFonts.poppins(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  CalendarStyle _buildCalendarStyle() {
    final mX = _cellGapX / 2;
    return CalendarStyle(
      outsideDaysVisible: false,
      defaultTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      weekendTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      outsideTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black38,
      ),
      // Transparent decorations
      defaultDecoration: const BoxDecoration(color: Colors.transparent),
      weekendDecoration: const BoxDecoration(color: Colors.transparent),
      outsideDecoration: const BoxDecoration(color: Colors.transparent),
      disabledDecoration: const BoxDecoration(color: Colors.transparent),
      selectedDecoration: const BoxDecoration(color: Colors.transparent),
      todayDecoration: const BoxDecoration(color: Colors.transparent),
      cellMargin: EdgeInsets.symmetric(
        horizontal: mX.w,
        vertical: (_cellGapY / 2).h,
      ),
      cellPadding: EdgeInsets.zero,
      markersMaxCount: 0,
    );
  }

  Widget _buildDayCell(
    DateTime date, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final d = _normalize(date);
    final today = _normalize(DateTime.now());
    final hasEvents = _getEventsForDay(date).isNotEmpty;

    // Obliczanie tła
    Color bg = Colors.transparent;
    if (isToday && hasEvents) {
      bg = const Color(0xFFF7F1C3);
    } else if (hasEvents) {
      bg =
          d.isBefore(today) ? const Color(0xFFCAECF4) : const Color(0xFFF7F1C3);
    }

    return SizedBox(
      width: _cellW.w,
      height: _cellH.h,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          _padL.w,
          _padSafeV.h,
          _padR.w,
          _padSafeV.h,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(_cellRadius.r),
          border:
              isSelected ? Border.all(color: const Color(0xFF1D1F1F)) : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isToday ? const Color(0xFFF13636) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySliver() => SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    sliver: SliverToBoxAdapter(
      child: _emptyCard('Brak nadchodzących wydarzeń'),
    ),
  );

  Widget _buildEventsList() => SliverList(
    delegate: SliverChildBuilderDelegate((context, index) {
      final isLast = index == _upcoming.length - 1;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          index == 0 ? 8.h : 5.h,
          16.w,
          isLast ? 120.h : 5.h,
        ),
        child: _eventTile(_upcoming[index]),
      );
    }, childCount: _upcoming.length),
  );

  Widget _eventTile(WydarzenieListItem e) {
    // Chip: Dziś/Jutro/data + opcjonalnie godzina
    final String chipDate = _dfDay.format(e.start);
    final String chipTime = _dfTime.format(e.start);

    final DateTime today = _normalize(DateTime.now());
    final DateTime tomorrow = _normalize(
      DateTime.now().add(const Duration(days: 1)),
    );
    final DateTime eventDay = _normalize(e.start);

    late final String chipText;
    if (e.allDay) {
      // Zawsze tylko data dla wydarzeń całodniowych
      chipText = chipDate;
    } else if (eventDay == today) {
      chipText = 'Dziś / $chipTime';
    } else if (eventDay == tomorrow) {
      chipText = 'Jutro / $chipTime';
    } else {
      chipText = '$chipDate / $chipTime';
    }

    // Stylowanie „dzisiaj” (karta)
    final bool isToday = eventDay == today;
    final Color cardBg = isToday ? Colors.white : const Color(0xFFCAECF4);

    return InkWell(
      onTap: () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => KalendarzWydarzenDetailsScreen(
                  idInstytucji: widget.idInstytucji,
                  idWydarzenia: e.id,
                  tytul: e.title,
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tytuł
            Text(
              e.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            // Opis
            if (e.intro?.isNotEmpty == true) ...[
              SizedBox(height: 6.h),
              Text(
                cleanHtmlString(e.intro!),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],

            SizedBox(height: 12.h),

            // Chip z datą/godziną
            Row(
              children: [
                Container(
                  height: 32.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isToday
                            ? const Color(0xFFF13636)
                            : const Color(0xFFF7F1C3),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Center(
                    child: Text(
                      chipText, // np. 26.08.25/23:12 lub 26.08.25 (allDay)
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isToday ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String msg) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFCAECF4),
      borderRadius: BorderRadius.circular(20.r),
    ),
    padding: EdgeInsets.all(20.w),
    child: Text(
      msg,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}
