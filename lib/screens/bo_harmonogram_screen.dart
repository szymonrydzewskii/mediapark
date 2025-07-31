import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:mediapark/models/bo_harmonogram.dart';
import 'package:mediapark/services/bo_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/helpers/html_helper.dart';

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

  DateTime _parse(String s) =>
      DateFormat(
        "dd.MM.yyyy",
      ).parse(s.replaceAll(RegExp(r"[^\d.]"), ""), true).toLocal();
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
                  final stages =
                      harmonogram.phases.map((p) {
                        // tutaj czyścimy tytuł z HTML‑a
                        final name = cleanHtmlString(p.name);
                        final start = _parse(p.start);
                        final rawEnd = p.end.isEmpty ? null : _parse(p.end);
                        PhaseType typeForRawKey(String key) {
                          switch (key) {
                            case 'promo_name':
                              return PhaseType.promo;
                            case 'add_projects_name':
                              return PhaseType.addProjects;
                            case 'verification_projects_name':
                              return PhaseType.verification;
                            case 'choosing_projects_for_voting_name':
                              return PhaseType.choosing;
                            case 'voting_for_projects_name':
                              return PhaseType.voting;
                            case 'voting_results_verification_name':
                              return PhaseType.resultsVerification;
                            case 'voting_results_name':
                              return PhaseType.officialResults;
                            default:
                              return PhaseType.unknown;
                          }
                        }

                        final type = typeForRawKey(p.key);
                        return _Stage(
                          type: type,
                          title: name,
                          start: start,
                          endDisplay: rawEnd ?? DateTime(2100),
                        );
                      }).toList();

                  final now = DateTime.now();
                  int activeIndex = stages.indexWhere(
                    (s) => now.isAfter(s.start) && now.isBefore(s.endLogic),
                  );
                  if (activeIndex < 0) {
                    activeIndex =
                        now.isBefore(stages.first.start)
                            ? 0
                            : stages.length - 1;
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
                                      : const Color(0xFFCAECF4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerLeft,
                            child:
                                i == activeIndex
                                    ? _buildActiveContent(s)
                                    : Text(
                                      s.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                        color: const Color(0xFFF13636),
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
                                      color: const Color(0xFFACD2DD),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    )
                                    : DotIndicator(
                                      size: 12.w,
                                      color: const Color(0xFF96C5D1),
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
                          color: const Color(0xFF96C5D1),
                          gapColor: Colors.transparent,
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
    switch (s.type) {
      case PhaseType.promo:
        return _ActiveStageCard(stage: s, showVoteButton: false,);
      case PhaseType.addProjects:
        return _ActiveStageCard(stage: s, showVoteButton: false,);
      case PhaseType.verification:
        return _ActiveStageCard(stage: s, showAddProjectButton: false, showVoteButton: false,);
      case PhaseType.choosing:
        return _ActiveStageCard(stage: s, showAddProjectButton: false, showVoteButton: false,);
      case PhaseType.voting:
        return _ActiveStageCard(stage: s, showAddProjectButton: false,);
      case PhaseType.resultsVerification:
        return _ActiveStageCard(stage: s, showAddProjectButton: false, showVoteButton: false,);
      case PhaseType.officialResults:
        return _ActiveStageCard(stage: s, showAddProjectButton: false, showVoteButton: false, showCountdown: false, showEnd: false,);
      case PhaseType.unknown:
      return _ActiveStageCard(stage: s, showAddProjectButton: false, showCountdown: false, showVoteButton: false,);
      default:
        // standardowy pasek z odliczaniem i przyciskiem „Głosuj”
        return _ActiveStageCard(stage: s, showAddProjectButton: false,);
        
    }
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
  unknown
}

class _Stage {
  final PhaseType type;
  final String title;
  final DateTime start, endDisplay, endLogic;
  _Stage({
    required this.type,
    required this.title,
    required this.start,
    required this.endDisplay,
  }) : endLogic = endDisplay.add(const Duration(days: 1));
}

class _ActiveStageCard extends StatelessWidget {
  final _Stage stage;
  final bool showStart;
  final bool showEnd;
  final bool showCountdown;
  final bool showVoteButton;
  final bool showAddProjectButton;

  const _ActiveStageCard({
    required this.stage,
    this.showStart = true,
    this.showEnd = true,
    this.showCountdown = true,
    this.showVoteButton = true,
    this.showAddProjectButton = true,
  });

  @override
  Widget build(BuildContext c) {
    final df = DateFormat('dd.MM.yyyy');
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
        const Divider(thickness: 1, color: Color(0xFFCAECF4)),
        SizedBox(height: 16.h),
        // ---- start ----
        if (showStart)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'start: ', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w400)),
                TextSpan(text: df.format(stage.start), style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        // ---- koniec ----
        if (showEnd)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'koniec: ', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w400)),
                TextSpan(text: df.format(stage.endDisplay), style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        SizedBox(height: 16.h),
        // ---- odliczanie ----
        if (showCountdown) ...[
          Text("POZOSTAŁO:", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w800)),
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
          if (showVoteButton || showAddProjectButton)
            const Divider(thickness: 1, color: Color(0xFFCAECF4)),
            SizedBox(height: 12.h),
        ],
        // ---- przycisk ----
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
              backgroundColor: Color(0xFF1D1F1F),
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
              backgroundColor: Color(0xFF1D1F1F),
            ),
            child: Text("Zgłoś projekt", style: TextStyle(color: Colors.white)),
          )
      ],
    );
  }

  Widget _countdownTile(String value, String label) {
    return Container(
      width: 80.w, // tu szerokość każdego kafelka
      height: 104.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1C3),
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
