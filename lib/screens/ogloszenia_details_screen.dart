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

      // Pre-validate images to avoid layout jumping
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Błąd: $_error'),
                    ElevatedButton(
                      onPressed: _loadDetails,
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Column(
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
                    Divider(height: 1, color: Color(0xFF96C5D1)),
                    SizedBox(height: 12.h),

                    // Data dodania
                    Text(
                      "Dodane ${_formatDate(_details?.datetime ?? widget.ogloszenie.datetime)}",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20.h),

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
                    // SizedBox(height: 20.h),

                    // Galeria zdjęć
                    if (_details?.gallery.isNotEmpty == true) ...[
                      _buildGallery(),
                      SizedBox(height: 20.h),
                    ],

                    // Lokalizacja
                    if (_hasLocationData()) ...[
                      Divider(height: 1, color: Color(0xFF96C5D1)),
                      SizedBox(height: 40.h),
                      _buildLocationSection(),
                      SizedBox(height: 20.h),
                    ],

                    // Inne pliki jeśli dostępne
                    if (_details?.otherFiles.isNotEmpty == true) ...[
                      Text(
                        "Załączniki",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ..._details!.otherFiles
                          .map(
                            (file) => Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFACD2DD),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.description,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    file.filename,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ],
                ),
              ),
    );
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

  Widget _buildGallery() {
    // Filter out failed images
    final validImages =
        _details!.gallery
            .where((image) => !_failedImages.contains(image.filename))
            .toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.only(left: 0, right: 24.w),
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
                      width: 280.w,
                      height: 200.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // This should rarely happen now since we pre-validate
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                );
              }).toList(),
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

  Widget _buildMap() {
    List<fmap.Marker> markers = [];
    List<fmap.Polyline> polylines = [];
    List<fmap.Polygon> polygons = [];
    LatLng? center;

    // Parse map points
    if (_details!.mapPoints?.isNotEmpty == true) {
      final points = _parseCoordinates(_details!.mapPoints!);
      for (int i = 0; i < points.length; i++) {
        markers.add(
          fmap.Marker(
            point: points[i],
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        );
      }
      if (points.isNotEmpty) center = points.first;
    }

    // Parse polylines
    if (_details!.mapPolylines?.isNotEmpty == true) {
      final points = _parseCoordinates(_details!.mapPolylines!);
      if (points.isNotEmpty) {
        polylines.add(
          fmap.Polyline(points: points, color: Colors.blue, strokeWidth: 3.0),
        );
        center ??= points.first;
      }
    }

    // Parse polygons
    if (_details!.mapPolygons?.isNotEmpty == true) {
      final points = _parseCoordinates(_details!.mapPolygons!);
      if (points.isNotEmpty) {
        polygons.add(
          fmap.Polygon(
            points: points,
            color: Colors.red.withAlpha(76),
            borderColor: Colors.red,
            borderStrokeWidth: 2.0,
          ),
        );
        center ??= points.first;
      }
    }

    // Default center if no coordinates found
    center ??= const LatLng(52.0, 19.0); // Poland center

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
                fmap.InteractiveFlag.pinchZoom |
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

  List<LatLng> _parseCoordinates(String coordinatesString) {
    List<LatLng> points = [];

    try {
      // Try to parse as JSON array
      final parsed = json.decode(coordinatesString);
      if (parsed is List) {
        for (final item in parsed) {
          if (item is Map &&
              item.containsKey('lat') &&
              item.containsKey('lng')) {
            final lat = double.tryParse(item['lat'].toString());
            final lng = double.tryParse(item['lng'].toString());
            if (lat != null && lng != null) {
              points.add(LatLng(lat, lng));
            }
          }
        }
      }
    } catch (e) {
      // Try to parse as comma-separated coordinates
      final parts = coordinatesString.split(',');
      for (int i = 0; i < parts.length - 1; i += 2) {
        final lat = double.tryParse(parts[i].trim());
        final lng = double.tryParse(parts[i + 1].trim());
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
      }
    }

    return points;
  }

  String _formatDate(String datetime) {
    try {
      final dt = DateTime.parse(datetime);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 1) return "${diff.inDays} dni temu";
      if (diff.inHours >= 1) return "${diff.inHours} godzin temu";
      return "dzisiaj";
    } catch (_) {
      return datetime;
    }
  }
}
