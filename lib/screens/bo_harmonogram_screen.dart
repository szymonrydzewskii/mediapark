import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediapark/screens/bo_wyniki_glosowania_screen.dart';
import 'package:mediapark/widgets/illustration_empty_state.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:mediapark/models/bo_harmonogram.dart';
import 'package:mediapark/services/bo_service.dart';
import 'package:mediapark/services/cached_samorzad_details_service.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/webview_page.dart';

class BOHarmonogramScreen extends StatefulWidget {
  final int idInstytucji;
  final String idSamorzadu;
  const BOHarmonogramScreen({
    super.key,
    required this.idInstytucji,
    required this.idSamorzadu,
  });

  @override
  State<BOHarmonogramScreen> createState() => _BOHarmonogramScreenState();
}

class _BOHarmonogramScreenState extends State<BOHarmonogramScreen> {
  late Future<BOHarmonogram> _harmonogramFuture;
  late Future<SamorzadSzczegoly> _szczegolyFuture;

  @override
  void initState() {
    super.initState();
    print('BOHarmonogramScreen idInstytucji = ${widget.idInstytucji}');
    _harmonogramFuture =
        BOService(institutionId: widget.idInstytucji).fetchHarmonogram();
    _szczegolyFuture = CachedSamorzadDetailsService().fetchSzczegolyInstytucji(
      widget.idSamorzadu.toString(),
    );
  }

  String? _extractBoUrl(SamorzadSzczegoly s) {
    for (final m in s.modules) {
      final alias = (m.alias).trim().toLowerCase();
      final url = (m.url).trim();
      if (alias == 'budzet-obywatelski' && url.isNotEmpty) {
        return (url);
      }
    }
    return null;
  }

  DateTime _parse(String s) {
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
            Expanded(
              child: FutureBuilder<BOHarmonogram>(
                future: _harmonogramFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError || !snap.hasData) {
                    return Center(
                      child: IllustrationEmptyState(
                        mainText: "Przepraszamy, wystąpił\nchwilowy problem.",
                        secondaryText: "Już nad nim pracujemy.",
                        assetPath: "assets/icons/network-error.svg",
                        type: 2,
                      ),
                    );
                  }

                  final harmonogram = snap.data!;
                  final phases = harmonogram.phases;
                  final stages =
                      phases.asMap().entries.map((entry) {
                        final p = entry.value;
                        final name = p.name;
                        final start = _parse(p.dateFrom);
                        final end = _parse(p.dateTo);
                        return _Stage(
                          type: PhaseType.unknown,
                          title: name,
                          start: start,
                          endDisplay: end,
                          phase: p,
                        );
                      }).toList();

                  int activeIndex = phases.indexWhere((p) => p.isActive);
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

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Timeline.tileBuilder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          theme: TimelineThemeData(
                            nodePosition: 0.07,
                            connectorTheme: const ConnectorThemeData(
                              thickness: 2,
                            ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                s.title,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  s.phase.date,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
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
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
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
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: const Divider(
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Kafelek z linkiem do BO
                        FutureBuilder<SamorzadSzczegoly>(
                          future: _szczegolyFuture,
                          builder: (ctx, snapDetails) {
                            if (snapDetails.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: EdgeInsets.all(16.w),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapDetails.hasError || !snapDetails.hasData) {
                              // Nic nie renderuj, gdy brak danych
                              return const SizedBox.shrink();
                            }

                            final szczegoly = snapDetails.data!;
                            final boUrl = _extractBoUrl(szczegoly);

                            if (boUrl == null) {
                              // Brak modułu BO lub pusty URL → nic nie pokazuj
                              return const SizedBox.shrink();
                            }

                            // Mamy URL → pokaż kafelek
                            return _buildBottomTile(
                              context,
                              url: boUrl,
                              title: 'Budżet Obywatelski',
                            );
                          },
                        ),

                        SizedBox(height: 16.h),
                      ],
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

  Widget _buildBottomTile(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => WebViewPage(url: url, title: title),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12.h),
                      Text(
                        'Przejdź do strony',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 20.w, color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveContent(_Stage s) {
    return _ActiveStageCard(
      stage: s,
      institutionId: widget.idInstytucji,
      showStart: true,
      showEnd: true,
      showCountdown: s.phase.showCounter == true,
      showVoteButton: s.phase.actionUrl?.isNotEmpty == true,
      showAddProjectButton: false,
      showProjectsButton: false,
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
  final int institutionId;
  final bool showStart;
  final bool showEnd;
  final bool showCountdown;
  final bool showVoteButton;
  final bool showAddProjectButton;
  final bool showProjectsButton;

  const _ActiveStageCard({
    required this.stage,
    required this.institutionId,
    this.showStart = true,
    this.showEnd = true,
    this.showCountdown = true,
    this.showVoteButton = true,
    this.showAddProjectButton = true,
    this.showProjectsButton = true,
  });

  @override
  Widget build(BuildContext c) {
    String iconAssetForPhase(String? alias) {
      if (alias == null || alias.trim().isEmpty) {
        return 'assets/icons/list.svg';
      }
      return 'assets/icons/${alias.trim().toLowerCase()}.svg';
    }

    final phase = stage.phase;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w),
          child: SvgPicture.asset(
            iconAssetForPhase(phase.alias),
            width: 32.w,
            height: 32.w,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stage.title,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(thickness: 1, color: AppColors.primaryLight),
              SizedBox(height: 16.h),
              if (phase.date.isNotEmpty)
                Text(
                  phase.date,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              if (phase.date.isNotEmpty) SizedBox(height: 16.h),
              if (showCountdown && phase.showCounter == true) ...[
                Text(
                  phase.counterText.isNotEmpty
                      ? phase.counterText.toUpperCase()
                      : "POZOSTAŁO:",
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
                if (showVoteButton ||
                    showAddProjectButton ||
                    showProjectsButton)
                  const Divider(thickness: 1, color: AppColors.primaryLight),
                SizedBox(height: 12.h),
              ],
              if (phase.actionUrl?.isNotEmpty == true &&
                  phase.actionUrlAnchor?.isNotEmpty == true) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(c).push(
                      CupertinoPageRoute(
                        builder:
                            (_) => WebViewPage(
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ] else ...[
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
                    child: const Text(
                      "Zagłosuj",
                      style: TextStyle(color: Colors.white),
                    ),
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
                    child: const Text(
                      "Zgłoś projekt",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (showProjectsButton)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(c).push(
                        CupertinoPageRoute(
                          builder:
                              (_) => BoWynikiGlosowaniaScreen(
                                institutionId: institutionId,
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
                    child: const Text(
                      "Zobacz wyniki głosowania",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _countdownTile(String value, String label) {
    return Container(
      width: 80.w,
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
