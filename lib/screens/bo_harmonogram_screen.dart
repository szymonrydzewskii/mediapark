import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediapark/screens/bo_wyniki_glosowania_screen.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:mediapark/models/bo_harmonogram.dart';
import 'package:mediapark/services/bo_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/webview_page.dart';

class BOHarmonogramScreen extends StatefulWidget {
  final int idInstytucji;
  const BOHarmonogramScreen({super.key, required this.idInstytucji});

  @override
  State<BOHarmonogramScreen> createState() => _BOHarmonogramScreenState();
}

class _BOHarmonogramScreenState extends State<BOHarmonogramScreen> {
  late Future<BOHarmonogram> _future;

  @override
  void initState() {
    super.initState();
    _future = BOService(institutionId: widget.idInstytucji).fetchHarmonogram();
  }

  DateTime _parse(String s) {
    // Obsługuje formaty: "2025-03-01 00:00:00", "2025-05-01", "2025-10-03 10:30:00"
    try {
      if (s.contains(":")) {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(s, true).toLocal();
      } else {
        return DateFormat("yyyy-MM-dd").parse(s, true).toLocal();
      }
    } catch (_) {
      return DateTime.now();
    }
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Text(
                'Harmonogram',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Flexible(
              child: FutureBuilder<BOHarmonogram>(
                future: _future,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError || !snap.hasData) {
                    return Center(
                      child: Text("Błąd: ${snap.error ?? 'brak danych'}"),
                    );
                  }

                  final harmonogram = snap.data!;
                  final phases = harmonogram.phases;
                  final stages = phases.asMap().entries.map((entry) {
                    final p = entry.value;
                    
                    final name = p.name;
                    final start = _parse(p.dateFrom);
                    final end = _parse(p.dateTo);
                    
                    return _Stage(
                      type: PhaseType.unknown, // Nie potrzebujemy już typu, używamy danych z API
                      title: name,
                      start: start,
                      endDisplay: end,
                      phase: p,
                    );
                  }).toList();

                  // Znajdź aktywną fazę bezpośrednio z API
                  int activeIndex = phases.indexWhere((p) => p.isActive);
                  
                  // Jeśli API nie wskazuje aktywnej fazy, użyj logiki dat
                  if (activeIndex < 0) {
                    final now = DateTime.now();
                    activeIndex = stages.indexWhere(
                      (s) => now.isAfter(s.start) && now.isBefore(s.endLogic),
                    );
                    if (activeIndex < 0) {
                      activeIndex =
                          now.isBefore(stages.first.start)
                              ? 0
                              : stages.length - 1;
                    }
                  }

                  return Timeline.tileBuilder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    theme: TimelineThemeData(
                      nodePosition: 0.07,
                      connectorTheme: ConnectorThemeData(thickness: 2),
                    ),
                    builder: TimelineTileBuilder.connected(
                      itemCount: stages.length,
                      contentsBuilder: (c, i) {
                        final s = stages[i];
                        final isActive = i == activeIndex;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                              vertical: isActive ? 12 : 6,
                            ),
                            constraints:
                                isActive
                                    ? const BoxConstraints()
                                    : BoxConstraints(minHeight: 80.h),
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? Colors.white
                                      : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerLeft,
                            child:
                                i == activeIndex
                                    ? _buildActiveContent(s)
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            s.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        ],
                                      ),
                          ),
                        );
                      },
                      indicatorBuilder: (c, i) {
                        final isDone = i < activeIndex;
                        final isActive = i == activeIndex;
                        return SizedBox(
                          width: 40.w,
                          height: 32.h,
                          child: Center(
                            child:
                                isActive
                                    ? Container(
                                      width: 40.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.red,
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Trwa',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                    : isDone
                                    ? DotIndicator(
                                      size: 32.w,
                                      color: AppColors.primaryMedium,
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    )
                                    : DotIndicator(
                                      size: 12.w,
                                      color: AppColors.divider,
                                    ),
                          ),
                        );
                      },
                      connectorBuilder: (c, i, type) {
                        return DashedLineConnector(
                          thickness: 1,
                          dash: 2,
                          gap: 5,
                          indent: type == ConnectorType.start ? 8.h : 0,
                          endIndent: type == ConnectorType.end ? 8.h : 0,
                          color: AppColors.divider,
                          gapColor: Colors.white.withValues(alpha: 0),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent(_Stage s) {
    // Używamy bezpośrednio danych z API zamiast przełączania po typu
    return _ActiveStageCard(
      stage: s,
      showStart: true,
      showEnd: true,
      showCountdown: s.phase.showCounter == true,
      showVoteButton: s.phase.actionUrl?.isNotEmpty == true,
      showAddProjectButton: false, // Przycisk będzie obsługiwany przez actionUrl
      showProjectsButton: false,   // Przycisk będzie obsługiwany przez actionUrl
    );
  }
}

enum PhaseType {
  promo,
  addProjects,
  verification,
  choosing,
  voting,
  resultsVerification,
  officialResults,
  unknown,
}

class _Stage {
  final PhaseType type;
  final String title;
  final DateTime start, endDisplay, endLogic;
  final Phase phase;
  _Stage({
    required this.type,
    required this.title,
    required this.start,
    required this.endDisplay,
    required this.phase,
  }) : endLogic = endDisplay.add(const Duration(days: 1));
}

class _ActiveStageCard extends StatelessWidget {
  final _Stage stage;
  final bool showStart;
  final bool showEnd;
  final bool showCountdown;
  final bool showVoteButton;
  final bool showAddProjectButton;
  final bool showProjectsButton;

  const _ActiveStageCard({
    required this.stage,
    this.showStart = true,
    this.showEnd = true,
    this.showCountdown = true,
    this.showVoteButton = true,
    this.showAddProjectButton = true,
    this.showProjectsButton = true,
  });

  @override
  Widget build(BuildContext c) {
    
    // Użyjemy nowych pól z API dla aktywnej karty
    final phase = stage.phase;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- tytuł zawsze ----
        Text(
          stage.title,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Divider(thickness: 1, color: AppColors.primaryLight),
        SizedBox(height: 16.h),
        
        // Pokazujemy opis daty z API
        if (phase.date.isNotEmpty)
          Text(
            phase.date,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        if (phase.date.isNotEmpty)
          SizedBox(height: 16.h),
        
        // ---- odliczanie (jeśli ma być pokazane) ----
        if (showCountdown && phase.showCounter == true) ...[
          Text(
            phase.counterText.isNotEmpty ? phase.counterText.toUpperCase() : "POZOSTAŁO:",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _countdownTile(
                "${stage.endLogic.difference(DateTime.now()).inDays}",
                "dni",
              ),
              _countdownTile(
                "${stage.endLogic.difference(DateTime.now()).inHours % 24}",
                "godzin",
              ),
              _countdownTile(
                "${stage.endLogic.difference(DateTime.now()).inMinutes % 60}",
                "minut",
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (showVoteButton || showAddProjectButton || showProjectsButton)
            const Divider(thickness: 1, color: AppColors.primaryLight),
          SizedBox(height: 12.h),
        ],
        
        // ---- przyciski akcji (jeśli API udostępnia) ----
        if (phase.actionUrl?.isNotEmpty == true && phase.actionUrlAnchor?.isNotEmpty == true) ...[
          ElevatedButton(
            onPressed: () {
              Navigator.of(c).push(
                CupertinoPageRoute(
                  builder: (_) => WebViewPage(
                    url: phase.actionUrl!,
                    title: phase.actionUrlAnchor!,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: AppColors.blackMedium,
            ),
            child: Text(
              phase.actionUrlAnchor!,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ] else ...[
          // Domyślne przyciski
          if (showVoteButton)
            ElevatedButton(
              onPressed: () {
                // TODO zagłosuj
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: AppColors.blackMedium,
              ),
              child: Text("Zagłosuj", style: TextStyle(color: Colors.white)),
            ),
          if (showAddProjectButton)
            ElevatedButton(
              onPressed: () {
                // TODO zgłoś projekt
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: AppColors.blackMedium,
              ),
              child: Text("Zgłoś projekt", style: TextStyle(color: Colors.white)),
            ),
          if (showProjectsButton)
            ElevatedButton(
              onPressed: () {
                Navigator.of(c).push(
                  CupertinoPageRoute(
                    builder:
                        (_) => BoWynikiGlosowaniaScreen(
                          institutionId: stage.type.index,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: AppColors.blackMedium,
              ),
              child: Text(
                "Zobacz wyniki głosowania",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ],
    );
  }

  Widget _countdownTile(String value, String label) {
    return Container(
      width: 80.w, // tu szerokość każdego kafelka
      height: 104.h,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}