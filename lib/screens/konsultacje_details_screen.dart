import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/illustration_empty_state.dart';
import 'package:mediapark/widgets/webview_page.dart';

import '../helpers/prettify.dart';
import '../models/konsultacje.dart';
import '../models/konsultacje_details.dart';
import '../services/konsultacje_service.dart';

class KonsultacjeDetailsPage extends StatefulWidget {
  final Konsultacje konsultacja;
  final String idInstytucji;

  const KonsultacjeDetailsPage({
    super.key,
    required this.konsultacja,
    required this.idInstytucji,
  });

  @override
  State<KonsultacjeDetailsPage> createState() => _KonsultacjeDetailsPageState();
}

class _KonsultacjeDetailsPageState extends State<KonsultacjeDetailsPage> {
  final KonsultacjeService _service = KonsultacjeService();

  KonsultacjeDetails? _details;
  bool _isLoading = true;
  String? _error;

  final Set<String> _failedImages = {};
  final Map<int, String> _resolvedFileUrls = {};

  static const String _host = 'https://test.wdialogu.pl';
  static const String _fallbackInstitutionFolder = 'demo';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final d = await _service.fetchSzczegoly(
        idInstytucji: widget.idInstytucji,
        idKonsultacji: widget.konsultacja.id,
      );

      // 1) Zbierz wszystkie URL-e obrazków do walidacji (hero + galeria + img w HTML)
      final urlsToValidate = <String>[];

      final hero = (d.photoUrl ?? '').trim();
      if (hero.isNotEmpty) urlsToValidate.add(hero);

      final gallery = _buildGalleryUrls(d);
      urlsToValidate.addAll(gallery);

      // IMG z HTML (short/desc/sekcje)
      final htmlImgUrls = <String>[];
      htmlImgUrls.addAll(
        _extractImgSrcs(d.shortDescription).map(_resolveHtmlUrl),
      );
      htmlImgUrls.addAll(_extractImgSrcs(d.description).map(_resolveHtmlUrl));
      htmlImgUrls.addAll(
        _extractImgSrcs(d.informationText).map(_resolveHtmlUrl),
      );
      htmlImgUrls.addAll(_extractImgSrcs(d.legalBasis).map(_resolveHtmlUrl));
      htmlImgUrls.addAll(
        _extractImgSrcs(d.whoCanParticipate).map(_resolveHtmlUrl),
      );
      htmlImgUrls.addAll(
        _extractImgSrcs(d.purposeOfConsultation).map(_resolveHtmlUrl),
      );
      htmlImgUrls.addAll(_extractImgSrcs(d.subject).map(_resolveHtmlUrl));
      htmlImgUrls.addAll(
        _extractImgSrcs(d.responsibilityText).map(_resolveHtmlUrl),
      );

      urlsToValidate.addAll(htmlImgUrls);

      // 2) Waliduj obrazki (HEAD)
      await _validateImages(urlsToValidate);

      // 3) Resolve pliki (jak w ogłoszeniach)
      final fileUrls = await _resolveFileUrls(d);

      if (!mounted) return;
      setState(() {
        _details = d;
        _resolvedFileUrls
          ..clear()
          ..addAll(fileUrls);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ========= WEBVIEW / ATTACHMENTS =========

  void _openInWebView(String url, String title) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => WebViewPage(url: url, title: title)),
    );
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się otworzyć załącznika')),
      );
    }
  }

  // ========= IMAGE HELPERS (jak ogłoszenia) =========

  Future<void> _validateImages(List<String> urls) async {
    final uniq = urls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();

    final futures = uniq.map((u) async {
      try {
        final res = await http.head(Uri.parse(u));
        final isImg = res.headers['content-type']?.startsWith('image/') == true;
        if (res.statusCode != 200 || !isImg) _failedImages.add(u);
      } catch (_) {
        _failedImages.add(u);
      }
    });

    await Future.wait(futures);
  }

  // ========= HTML <img> helpers =========

  List<String> _extractImgSrcs(String html) {
    final reg = RegExp(
      "<img[^>]*\\bsrc\\s*=\\s*['\\\"]([^'\\\"]+)['\\\"]",
      caseSensitive: false,
    );

    return reg
        .allMatches(html)
        .map((m) => (m.group(1) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _resolveHtmlUrl(String src) {
    final u = Uri.tryParse(src.trim());
    if (u == null) return src.trim();
    if (u.hasScheme) return src.trim(); // już jest https://...
    return Uri.parse(_host).resolveUri(u).toString(); // względny -> absolutny
  }

  TagExtension _imgTagExtension() {
    return TagExtension(
      tagsToExtend: {"img"},
      builder: (context) {
        final rawSrc = (context.attributes['src'] ?? '').trim();
        if (rawSrc.isEmpty) return const SizedBox.shrink();

        final src = _resolveHtmlUrl(rawSrc);

        // jak nie przeszło HEAD -> nie pokazuj
        if (_failedImages.contains(src)) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Image.network(
                src,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _htmlBlock(String html) {
    return Html(
      data: html,
      style: _htmlStyle(),
      extensions: [_imgTagExtension()],
    );
  }

  // 1) wyciągnij folder instytucji z photo_url: /institutions/<folder>/...
  String _institutionFolderFromPhotoUrl(String? photoUrl) {
    final u = Uri.tryParse((photoUrl ?? '').trim());
    if (u == null) return _fallbackInstitutionFolder;

    final seg = u.pathSegments;
    final idx = seg.indexOf('institutions');
    if (idx >= 0 && idx + 1 < seg.length) {
      final folder = seg[idx + 1].trim();
      if (folder.isNotEmpty) return folder;
    }
    return _fallbackInstitutionFolder;
  }

  // 2) build URL zdjęć z main_photos
  List<String> _buildGalleryUrls(KonsultacjeDetails d) {
    if (d.mainPhotos.isEmpty) return const [];
    final folder = _institutionFolderFromPhotoUrl(d.photoUrl);

    return d.mainPhotos
        .where(
          (p) => p.filename.trim().isNotEmpty && p.extension.trim().isNotEmpty,
        )
        .map((p) {
          return '$_host/institutions/$folder/consultations/${d.idConsultation}/photos/${p.filename}.${p.extension}';
        })
        .toList();
  }

  // ========= FILES HELPERS =========
  Future<Map<int, String>> _resolveFileUrls(KonsultacjeDetails d) async {
    final out = <int, String>{};
    if (d.files.isEmpty) return out;

    final folder = _institutionFolderFromPhotoUrl(d.photoUrl);

    for (final f in d.files) {
      final name = f.filename.trim();
      final ext = f.extension.trim();
      if (name.isEmpty || ext.isEmpty) continue;

      final candidates = <String>[
        '$_host/institutions/$folder/consultations/${d.idConsultation}/files/$name.$ext',
        '$_host/institutions/$folder/consultations/${d.idConsultation}/attachments/$name.$ext',
      ];

      String? okUrl;
      for (final c in candidates) {
        if (await _headOk(c)) {
          okUrl = c;
          break;
        }
      }
      if (okUrl != null) out[f.idFile] = okUrl;
    }

    return out;
  }

  Future<bool> _headOk(String url) async {
    try {
      final res = await http.head(Uri.parse(url));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ========= BUILD =========

  @override
  Widget build(BuildContext context) {
    final d = _details;

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
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_error != null || d == null)
              ? IllustrationEmptyState(
                mainText: "Przepraszamy, wystąpił chwilowy problem.",
                secondaryText: "Już nad nim pracujemy.",
                assetPath: "assets/icons/network-error.svg",
                type: 2,
              )
              : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Builder(
                  builder: (context) {
                    // ======= LOGIKA zdjęć jak w ogłoszeniach =======
                    final mainPhoto = (d.photoUrl ?? '').trim();
                    final mainPhotoValid =
                        mainPhoto.isNotEmpty &&
                        !_failedImages.contains(mainPhoto);

                    final galleryAll =
                        _buildGalleryUrls(
                          d,
                        ).where((u) => !_failedImages.contains(u)).toList();

                    final galleryFiltered =
                        mainPhotoValid
                            ? galleryAll
                                .where((g) => !_sameImage(g, mainPhoto))
                                .toList()
                            : galleryAll;

                    final String? singleGalleryImage =
                        (galleryFiltered.length == 1)
                            ? galleryFiltered.first
                            : null;

                    final List<String> galleryToShow =
                        (galleryFiltered.length >= 2)
                            ? galleryFiltered
                            : const <String>[];

                    final String? heroPhoto =
                        mainPhotoValid ? mainPhoto : singleGalleryImage;

                    final bool hasMainPhoto = mainPhotoValid;

                    final start =
                        d.dateOfConsultationStartFormatted.trim().isNotEmpty
                            ? d.dateOfConsultationStartFormatted
                            : d.dateOfConsultationStart;

                    final end =
                        d.dateOfConsultationEndFormatted.trim().isNotEmpty
                            ? d.dateOfConsultationEndFormatted
                            : d.dateOfConsultationEnd;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        if (d.categoryAlias.trim().isNotEmpty) ...[
                          _buildCategoryChip(d.categoryAlias),
                          SizedBox(height: 16.h),
                        ],

                        Text(
                          d.title.trim().isNotEmpty
                              ? d.title
                              : widget.konsultacja.title,
                          style: GoogleFonts.poppins(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Divider(height: 1, color: AppColors.divider),
                        SizedBox(height: 12.h),

                        if (d.statusName.trim().isNotEmpty) ...[
                          Text(
                            "Status: ${d.statusName}",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.blackLight,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                        if (start.trim().isNotEmpty ||
                            end.trim().isNotEmpty) ...[
                          Text(
                            "Od: $start  Do: $end",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.blackLight,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],

                        if (heroPhoto != null && heroPhoto.isNotEmpty) ...[
                          _buildHeroImage(heroPhoto),
                          SizedBox(height: 20.h),
                        ],

                        // ======= HTML (z obsługą <img>) =======
                        if (d.shortDescription.trim().isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          _htmlBlock(d.shortDescription),
                        ],

                        if (d.description.trim().isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          _htmlBlock(d.description),
                          SizedBox(height: 12.h),
                        ],

                        _sectionIfNotEmpty(
                          "Cel konsultacji",
                          d.purposeOfConsultation,
                        ),

                        // drugie duże zdjęcie (jak ogłoszenia)
                        if (hasMainPhoto &&
                            singleGalleryImage != null &&
                            singleGalleryImage.isNotEmpty) ...[
                              Divider(),
                              SizedBox(height: 10.h),
                          _buildHeroImage(singleGalleryImage),
                          SizedBox(height: 20.h),
                        ],

                        // ======= MAPA =======
                        if (_hasLocationData(d)) ...[
                          Divider(height: 1, color: AppColors.divider),
                          SizedBox(height: 20.h),
                          _buildLocationSection(d),
                          SizedBox(height: 20.h),
                        ],

                        // ======= DEBATY =======
                        if (d.debates.isNotEmpty) ...[
                          Divider(height: 1, color: AppColors.divider),
                          SizedBox(height: 20.h),
                          Text(
                            "Debaty",
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...d.debates.map(_buildDebateCard),
                          SizedBox(height: 8.h),
                        ],

                        _sectionIfNotEmpty("Temat", d.subject),
                        if (d.responsibilityHeader == 1)
                          _sectionIfNotEmpty(
                            "Jednostka odpowiedzialna",
                            d.responsibilityText,
                          ),
                        _sectionIfNotEmpty("Podstawa prawna", d.legalBasis),
                        _sectionIfNotEmpty(
                          "Kto może wziąć udział",
                          d.whoCanParticipate,
                        ),
                        if (d.informationHeader == 1)
                          _sectionIfNotEmpty(
                            "Forma konsultacji",
                            d.informationText,
                          ),

                        // galeria 2+
                        if (galleryToShow.isNotEmpty) ...[
                          _buildGallery(galleryToShow),
                          SizedBox(height: 20.h),
                        ],

                        // ======= PLIKI =======
                        if (_resolvedFileUrls.isNotEmpty) ...[
                          Divider(height: 1, color: AppColors.divider),
                          SizedBox(height: 20.h),
                          Text(
                            "Załączniki",
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...d.files.map((f) {
                            final url = _resolvedFileUrls[f.idFile];
                            if (url == null) return const SizedBox.shrink();

                            final label =
                                f.description.trim().isNotEmpty
                                    ? f.description.trim()
                                    : Uri.parse(url).pathSegments.last;

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Material(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(18.r),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18.r),
                                  onTap: () => _openAttachment(url),
                                  child: Padding(
                                    padding: EdgeInsets.all(24.w),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        SvgPicture.asset(
                                          'assets/icons/download.svg',
                                          width: 20.w,
                                          height: 20.w,
                                        ),
                                        SizedBox(width: 10.w),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],

                        // ======= ANKIETA =======
                        if ((d.pollUrl ?? '').trim().isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  () => _openInWebView(
                                    d.pollUrl!,
                                    d.title.trim().isNotEmpty
                                        ? d.title
                                        : widget.konsultacja.title,
                                  ),
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
                        ],
                      ],
                    );
                  },
                ),
              ),
    );
  }

  // ========= UI HELPERS =========

  Widget _sectionIfNotEmpty(String title, String value) {
    final v = value.trim();
    if (v.isEmpty) return const SizedBox.shrink();

    final looksLikeHtml = RegExp(r'<[^>]+>').hasMatch(v);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 18.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          looksLikeHtml
              ? _htmlBlock(v)
              : Text(
                v,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Map<String, Style> _htmlStyle() {
    return {
      "body": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(16.sp),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      "p": Style(
        fontSize: FontSize(16.sp),
        fontFamily: GoogleFonts.poppins().fontFamily,
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.zero,
      ),
      "div": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    };
  }

  Widget _buildHeroImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40.r),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildCategoryChip(String alias) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFACD2DD),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          prettify(alias),
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDebateCard(KonsultacjaDebata d) {
    final dateRange = [
      d.dateBegin.trim(),
      d.beginTime.trim(),
      '→',
      d.dateEnd.trim(),
      d.endTime.trim(),
    ].where((e) => e.isNotEmpty).join(' ');

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.title.trim().isNotEmpty ? d.title : 'Debata',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              if (dateRange.trim().isNotEmpty)
                Text(
                  dateRange,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackLight,
                  ),
                ),
              if (d.place.trim().isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  "Miejsce: ${d.place}",
                  style: GoogleFonts.poppins(fontSize: 12.sp),
                ),
              ],
              if (d.purpose.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(d.purpose, style: GoogleFonts.poppins(fontSize: 12.sp)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ========= MAPA =========

  bool _hasLocationData(KonsultacjeDetails d) {
    if (d.showMap != 1) return false;
    return d.mapPoints.trim().isNotEmpty ||
        d.mapPolylines.trim().isNotEmpty ||
        d.mapPolygons.trim().isNotEmpty;
  }

  Widget _buildLocationSection(KonsultacjeDetails d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lokalizacja",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.h),
        _buildMap(d),
      ],
    );
  }

  Widget _buildMap(KonsultacjeDetails d) {
    final markers = <fmap.Marker>[];
    final polylines = <fmap.Polyline>[];
    final polygons = <fmap.Polygon>[];
    LatLng? center;

    final pointsFromMapPoints = <LatLng>[];
    final paths = <List<LatLng>>[];
    final rings = <List<LatLng>>[];

    if (d.mapPoints.trim().isNotEmpty) {
      final pts = _parseCoordinates(d.mapPoints);
      pointsFromMapPoints.addAll(pts);

      const markerSize = 40.0;
      for (final p in pts) {
        markers.add(
          fmap.Marker(
            point: p,
            width: markerSize,
            height: markerSize,
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, -2),
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: markerSize,
              ),
            ),
          ),
        );
      }
    }

    if (d.mapPolylines.trim().isNotEmpty) {
      final parsed = _parseMultiCoordinates(d.mapPolylines);
      paths.addAll(parsed);
      for (final pts in parsed) {
        if (pts.length >= 2) {
          polylines.add(
            fmap.Polyline(points: pts, color: Colors.blue, strokeWidth: 3.0),
          );
        }
      }
    }

    if (d.mapPolygons.trim().isNotEmpty) {
      final parsed = _parseMultiCoordinates(d.mapPolygons);
      rings.addAll(parsed);
      for (final pts in parsed) {
        if (pts.length >= 3) {
          polygons.add(
            fmap.Polygon(
              points: pts,
              color: Colors.red.withAlpha(76),
              borderColor: Colors.red,
              borderStrokeWidth: 2.0,
            ),
          );
        }
      }
    }

    final all = <LatLng>[];
    all.addAll(pointsFromMapPoints);
    for (final pts in paths) all.addAll(pts);
    for (final pts in rings) all.addAll(pts);

    if (all.isNotEmpty) {
      final b = fmap.LatLngBounds.fromPoints(all);
      center = b.center;
    }

    center ??= const LatLng(52.0, 19.0);

    return Container(
      height: 350.h,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40.r)),
      clipBehavior: Clip.hardEdge,
      child: fmap.FlutterMap(
        options: fmap.MapOptions(
          initialCenter: center,
          initialZoom: 15.0,
          minZoom: 5,
          maxZoom: 20,
          interactionOptions: const fmap.InteractionOptions(
            flags:
                fmap.InteractiveFlag.drag |
                fmap.InteractiveFlag.pinchZoom |
                fmap.InteractiveFlag.pinchMove |
                fmap.InteractiveFlag.doubleTapZoom,
          ),
        ),
        children: [
          fmap.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mediapark',
          ),
          if (markers.isNotEmpty) fmap.MarkerLayer(markers: markers),
          if (polylines.isNotEmpty) fmap.PolylineLayer(polylines: polylines),
          if (polygons.isNotEmpty) fmap.PolygonLayer(polygons: polygons),
        ],
      ),
    );
  }

  List<LatLng> _parseCoordinates(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return [];

    try {
      final parsed = json.decode(text);
      if (parsed is List) {
        final out = <LatLng>[];
        for (final item in parsed) {
          if (item is Map &&
              item.containsKey('lat') &&
              item.containsKey('lng')) {
            final lat = double.tryParse(item['lat'].toString());
            final lng = double.tryParse(item['lng'].toString());
            if (lat != null && lng != null) out.add(LatLng(lat, lng));
          } else if (item is String) {
            final parts = item.split(',');
            if (parts.length == 2) {
              final lat = double.tryParse(parts[0].trim());
              final lng = double.tryParse(parts[1].trim());
              if (lat != null && lng != null) out.add(LatLng(lat, lng));
            }
          }
        }
        return out;
      }
    } catch (_) {}

    if (text.contains(';')) {
      final out = <LatLng>[];
      final chunks = text.split(';');
      for (final chunk in chunks) {
        final c = chunk.trim();
        if (c.isEmpty) continue;
        final parts = c.split(',');
        if (parts.length != 2) continue;
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) out.add(LatLng(lat, lng));
      }
      return out;
    }

    final parts = text.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) return [LatLng(lat, lng)];
    }

    return [];
  }

  List<List<LatLng>> _parseMultiCoordinates(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return [];

    LatLng? parseLatLng(dynamic v) {
      if (v is String) {
        final parts = v.split(',');
        if (parts.length != 2) return null;
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      }
      if (v is Map) {
        final lat = double.tryParse(v['lat']?.toString() ?? '');
        final lng = double.tryParse(v['lng']?.toString() ?? '');
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      }
      return null;
    }

    try {
      final parsed = json.decode(text);

      if (parsed is List && parsed.isNotEmpty && parsed.first is List) {
        final out = <List<LatLng>>[];
        for (final sub in parsed) {
          if (sub is! List) continue;
          final pts = <LatLng>[];
          for (final item in sub) {
            final p = parseLatLng(item);
            if (p != null) pts.add(p);
          }
          if (pts.isNotEmpty) out.add(pts);
        }
        return out;
      }

      if (parsed is List) {
        final pts = <LatLng>[];
        for (final item in parsed) {
          final p = parseLatLng(item);
          if (p != null) pts.add(p);
        }
        return pts.isNotEmpty ? [pts] : [];
      }
    } catch (_) {
      final p = parseLatLng(text);
      if (p != null)
        return [
          [p],
        ];
    }

    return [];
  }

  // ======= helper: porównywanie zdjęć =======
  String _imageKey(String url) {
    final u = Uri.tryParse(url);
    final name =
        (u?.pathSegments.isNotEmpty == true)
            ? u!.pathSegments.last
            : url.split('/').last;

    final clean = name.split('?').first.toLowerCase();
    return clean.replaceFirst(
      RegExp(r'(_thumb(_mobile)?|_mobile)(?=\.[a-z0-9]+$)'),
      '',
    );
  }

  bool _sameImage(String a, String b) => _imageKey(a) == _imageKey(b);

  // ======= GALERIA =======
  Widget _buildGallery(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    final fadeW = 28.w;
    final itemW = 280.w;
    final itemH = 200.h;
    final screenSidePadding = 24.w;
    final screenW = MediaQuery.of(context).size.width;

    return SizedBox(
      height: itemH,
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: 0,
        maxWidth: screenW,
        child: Transform.translate(
          offset: Offset(-screenSidePadding, 0),
          child: SizedBox(
            width: screenW,
            height: itemH,
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(
                    left: screenSidePadding,
                    right: screenSidePadding,
                  ),
                  child: Row(
                    children:
                        images.asMap().entries.map((entry) {
                          final index = entry.key;
                          final imageUrl = entry.value;

                          return Container(
                            margin: EdgeInsets.only(
                              right: index < images.length - 1 ? 12.w : 0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.network(
                                imageUrl,
                                width: itemW,
                                height: itemH,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: fadeW,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: fadeW,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
