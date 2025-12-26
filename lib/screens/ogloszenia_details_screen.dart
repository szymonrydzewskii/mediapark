import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mediapark/models/ogloszenia.dart';
import 'package:mediapark/services/ogloszenia_service.dart';
import 'package:mediapark/services/global_data_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:flutter_html/flutter_html.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/illustration_empty_state.dart';
import 'package:url_launcher/url_launcher.dart';

class OgloszeniaDetailsScreen extends StatefulWidget {
  final Ogloszenia ogloszenie;
  final String idInstytucji;

  const OgloszeniaDetailsScreen({
    super.key,
    required this.ogloszenie,
    required this.idInstytucji,
  });

  @override
  State<OgloszeniaDetailsScreen> createState() =>
      _OgloszeniaDetailsScreenState();
}

class _OgloszeniaDetailsScreenState extends State<OgloszeniaDetailsScreen> {
  late OgloszeniaService _service;
  final GlobalDataService _globalService = GlobalDataService();
  OgloszeniaDetails? _details;
  bool _isLoading = true;
  String? _error;
  final Set<String> _failedImages = {};

  @override
  void initState() {
    super.initState();
    _service = OgloszeniaService(idInstytucji: widget.idInstytucji);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _service.fetchSzczegoly(widget.ogloszenie.id);

      if (details.gallery.isNotEmpty) {
        await _validateImages(details.gallery);
      }

      setState(() {
        _details = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _validateImages(List<GalleryFile> images) async {
    final futures = images.map((image) async {
      try {
        final response = await http.head(Uri.parse(image.filename));
        if (response.statusCode != 200 ||
            response.headers['content-type']?.startsWith('image/') != true) {
          _failedImages.add(image.filename);
        }
      } catch (e) {
        _failedImages.add(image.filename);
      }
    });

    await Future.wait(futures);
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? IllustrationEmptyState(mainText: "Przepraszamy, wystąpił chwilowy problem.", secondaryText: "Już nad nim pracujemy.", assetPath: "assets/icons/network-error.svg" ,type: 2,)
              : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Builder(
                  builder: (context) {
                    // ======= LOGIKA: photoUrl vs gallery =======
                    final mainPhoto = _details?.photoUrl;

                    final galleryAll =
                        (_details?.gallery ?? [])
                            .where(
                              (img) => !_failedImages.contains(img.filename),
                            )
                            .toList();

                    // usuń z galerii to, co jest tym samym co photoUrl
                    final galleryFiltered =
                        (mainPhoto != null && mainPhoto.isNotEmpty)
                            ? galleryAll
                                .where(
                                  (g) => !_sameImage(g.filename, mainPhoto),
                                )
                                .toList()
                            : galleryAll;

                    // decyzja: pojedyncze zdjęcie czy galeria
                    final String? singleGalleryImage =
                        (galleryFiltered.length == 1)
                            ? galleryFiltered.first.filename
                            : null;

                    final List<GalleryFile> galleryToShow =
                        (galleryFiltered.length >= 2)
                            ? galleryFiltered
                            : const <GalleryFile>[];

                    // heroPhoto:
                    // - jak jest photoUrl -> pokazujemy photoUrl
                    // - jak nie ma photoUrl, ale jest 1 zdjęcie w galerii -> pokazujemy je jako “normalne”
                    final String? heroPhoto =
                        (mainPhoto != null && mainPhoto.isNotEmpty)
                            ? mainPhoto
                            : singleGalleryImage;

                    final bool hasMainPhoto =
                        (mainPhoto != null && mainPhoto.isNotEmpty);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // Chip kategorii
                        if (widget.ogloszenie.idCategory != null) ...[
                          _buildCategoryChip(),
                          SizedBox(height: 16.h),
                        ],

                        // Tytuł ogłoszenia
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            _details?.title ?? widget.ogloszenie.title,
                            style: GoogleFonts.poppins(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Divider(height: 1, color: AppColors.divider),
                        SizedBox(height: 12.h),

                        // Data dodania
                        Text(
                          _formatDate(
                            _details?.datetime ?? widget.ogloszenie.datetime,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.blackLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ======= HERO PHOTO (photoUrl albo singleGalleryImage gdy brak photoUrl) =======
                        if (heroPhoto != null && heroPhoto.isNotEmpty) ...[
                          _buildHeroImage(heroPhoto),
                          SizedBox(height: 20.h),
                        ],

                        // Treść ogłoszenia
                        SizedBox(
                          width: double.infinity,
                          child:
                              _details?.content != null
                                  ? Html(
                                    data: _details!.content,
                                    style: {
                                      "body": Style(
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                      ),
                                      "p": Style(
                                        fontSize: FontSize(16.sp),
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                        margin: Margins.only(bottom: 12),
                                        padding: HtmlPaddings.zero,
                                      ),
                                      "div": Style(
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                      ),
                                    },
                                  )
                                  : Text(
                                    widget.ogloszenie.intro,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                        ),

                        // ======= ZDJĘCIE "NORMALNIE" zamiast galerii (tylko gdy photoUrl istnieje) =======
                        // Jeśli photoUrl jest, a po odfiltrowaniu zostaje 1 zdjęcie -> pokaż je pełną szerokością
                        if (hasMainPhoto &&
                            singleGalleryImage != null &&
                            singleGalleryImage.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          _buildHeroImage(singleGalleryImage),
                          SizedBox(height: 20.h),
                        ],

                        // ======= GALERIA (tylko gdy 2+ po odfiltrowaniu) =======
                        if (galleryToShow.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          _buildGallery(galleryToShow),
                          SizedBox(height: 20.h),
                        ],

                        // Lokalizacja
                        if (_hasLocationData()) ...[
                          SizedBox(height: 20.h),
                          Divider(height: 1, color: AppColors.divider),
                          SizedBox(height: 20.h),
                          _buildLocationSection(),
                          SizedBox(height: 20.h),
                        ],

                        // Inne pliki jeśli dostępne
                        if (_details?.otherFiles.isNotEmpty == true) ...[
                          SizedBox(height: 20.h),
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
                          ..._details!.otherFiles.map((file) {
                            final label =
                                (file.description.trim().isNotEmpty)
                                    ? file.description.trim()
                                    : Uri.parse(
                                      file.filename,
                                    ).pathSegments.isNotEmpty
                                    ? Uri.parse(file.filename).pathSegments.last
                                    : 'Załącznik';

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Material(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(18.r),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18.r),
                                  onTap: () => _openAttachment(file.filename),
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
                      ],
                    );
                  },
                ),
              ),
    );
  }

  // ======= helper: full-width image =======
  Widget _buildHeroImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40.r),
      child: Image.network(url, width: double.infinity, fit: BoxFit.cover),
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

  Widget _buildCategoryChip() {
    final categoryName = _globalService.getCategoryName(
      widget.ogloszenie.idCategory!,
    );
    if (categoryName.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFACD2DD),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          categoryName,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ======= helper: porównywanie zdjęć (thumb vs full) =======
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
  Widget _buildGallery(List<GalleryFile> images) {
    final validImages =
        images.where((img) => !_failedImages.contains(img.filename)).toList();

    if (validImages.isEmpty) return const SizedBox.shrink();

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
                        validImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;

                          return Container(
                            margin: EdgeInsets.only(
                              right: index < validImages.length - 1 ? 12.w : 0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.network(
                                image.filename,
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

  bool _hasLocationData() {
    if (_details == null) return false;
    return (_details!.mapPoints?.isNotEmpty == true) ||
        (_details!.mapPolylines?.isNotEmpty == true) ||
        (_details!.mapPolygons?.isNotEmpty == true);
  }

  Widget _buildLocationSection() {
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
        SizedBox(height: 40.h),
        _buildMap(),
      ],
    );
  }

  // ======= MAPA (zostawiam jak u Ciebie) =======
  Widget _buildMap() {
    final markers = <fmap.Marker>[];
    final polylines = <fmap.Polyline>[];
    final polygons = <fmap.Polygon>[];
    LatLng? center;

    final pointsFromMapPoints = <LatLng>[];
    final paths = <List<LatLng>>[];
    final rings = <List<LatLng>>[];

    if (_details!.mapPoints?.isNotEmpty == true) {
      final pts = _parseCoordinates(_details!.mapPoints!);
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

    if (_details!.mapPolylines?.isNotEmpty == true) {
      final parsed = _parseMultiCoordinates(_details!.mapPolylines!);
      paths.addAll(parsed);
      for (final pts in parsed) {
        if (pts.length >= 2) {
          polylines.add(
            fmap.Polyline(points: pts, color: Colors.blue, strokeWidth: 3.0),
          );
        }
      }
    }

    if (_details!.mapPolygons?.isNotEmpty == true) {
      final parsed = _parseMultiCoordinates(_details!.mapPolygons!);
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

  // ======= parsowanie coords (jak masz) =======
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
    final out = <LatLng>[];
    for (int i = 0; i < parts.length - 1; i += 2) {
      final lat = double.tryParse(parts[i].trim());
      final lng = double.tryParse(parts[i + 1].trim());
      if (lat != null && lng != null) out.add(LatLng(lat, lng));
    }
    return out;
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

  String _formatDate(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays < 1) {
        if (diff.inHours >= 1) {
          return "Dodane ${diff.inHours} ${diff.inHours == 1 ? 'godzinę' : 'godziny'} temu";
        } else {
          return "Dodane dzisiaj";
        }
      }

      if (diff.inDays <= 14) {
        return "Dodane ${diff.inDays} ${_pluralizeDays(diff.inDays)} temu";
      }

      final formatted =
          "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
      return "Dodane $formatted";
    } catch (_) {
      return "Dodane $datetime";
    }
  }

  String _pluralizeDays(int days) {
    if (days == 1) return "dzień";
    if (days >= 2 && days <= 4) return "dni";
    return "dni";
  }
}
