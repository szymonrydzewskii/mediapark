import 'dart:async';
import '../models/ogloszenia.dart';
import 'ogloszenia_service.dart';
import 'package:http/http.dart' as http;

class GlobalDataService {
  static final GlobalDataService _instance = GlobalDataService._internal();
  factory GlobalDataService() => _instance;
  GlobalDataService._internal();

  String? _currentMunicipalityId;

  // Cache for announcements
  List<Ogloszenia>? _cachedOgloszenia;
  List<KategoriaOgloszen>? _cachedKategorie;
  Map<int, OgloszeniaDetails>? _cachedOgloszeniaDetails;
  Map<String, bool>? _cachedImageValidity;

  // Loading states
  bool _isLoading = false;
  final StreamController<bool> _loadingController = StreamController<bool>.broadcast();

  // Getters
  String? get currentMunicipalityId => _currentMunicipalityId;
  bool get isLoading => _isLoading;
  Stream<bool> get loadingStream => _loadingController.stream;

  List<Ogloszenia> get ogloszenia => _cachedOgloszenia ?? [];
  List<KategoriaOgloszen> get kategorie => _cachedKategorie ?? [];
  Map<int, OgloszeniaDetails> get ogloszeniaDetails => _cachedOgloszeniaDetails ?? {};
  Map<String, bool> get imageValidity => _cachedImageValidity ?? {};

  Future<void> loadMunicipalityData(String municipalityId) async {
    // If same municipality and data already loaded, return
    if (_currentMunicipalityId == municipalityId &&
        _cachedOgloszenia != null &&
        _cachedKategorie != null) {
      return;
    }

    // Clear old data if municipality changed
    if (_currentMunicipalityId != municipalityId) {
      _clearCache();
    }

    _currentMunicipalityId = municipalityId;
    _isLoading = true;
    _loadingController.add(true);

    try {
      await Future.wait([
        _loadOgloszeniaData(municipalityId),
        // TODO: Add other modules here
        // _loadBudzetObywatelskiData(municipalityId),
        // _loadKonsultacjeData(municipalityId),
      ]);
    } catch (e) {
      print('Error loading municipality data: $e');
    } finally {
      _isLoading = false;
      _loadingController.add(false);
    }
  }

  Future<void> _loadOgloszeniaData(String municipalityId) async {
    final service = OgloszeniaService(idInstytucji: municipalityId);

    // Load basic data
    final ogloszenia = await service.fetchWszystkie();
    final kategorie = await service.fetchKategorie();

    // Sort announcements from newest to oldest
    ogloszenia.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datetime);
        final dateB = DateTime.parse(b.datetime);
        return dateB.compareTo(dateA); // newest first
      } catch (e) {
        return 0; // keep original order if parsing fails
      }
    });

    _cachedOgloszenia = ogloszenia;
    _cachedKategorie = kategorie;
    _cachedOgloszeniaDetails = {};
    _cachedImageValidity = {};

    // Load details and validate images in parallel
    final futures = <Future>[];

    for (final o in ogloszenia) {
      // Load details
      futures.add(
        service.fetchSzczegoly(o.id).then((details) {
          _cachedOgloszeniaDetails![o.id] = details;
        }).catchError((e) {
          print('Error loading details for ${o.id}: $e');
        })
      );

      // Validate image
      if (o.mainPhoto != null && o.mainPhoto!.isNotEmpty) {
        futures.add(
          _checkImageValidity(o.mainPhoto!).then((isValid) {
            _cachedImageValidity![o.mainPhoto!] = isValid;
          }).catchError((e) {
            _cachedImageValidity![o.mainPhoto!] = false;
          })
        );
      }
    }

    await Future.wait(futures);
  }

  Future<bool> _checkImageValidity(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == 200 &&
             response.headers['content-type']?.startsWith('image/') == true;
    } catch (e) {
      return false;
    }
  }

  List<Ogloszenia> getOgloszeniaByCategory(int? categoryId) {
    if (_cachedOgloszenia == null) return [];

    List<Ogloszenia> filtered;
    if (categoryId == null) {
      filtered = _cachedOgloszenia!;
    } else {
      filtered = _cachedOgloszenia!
          .where((o) => o.idCategory == categoryId)
          .toList();
    }

    // Sort filtered results from newest to oldest
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datetime);
        final dateB = DateTime.parse(b.datetime);
        return dateB.compareTo(dateA); // newest first
      } catch (e) {
        return 0; // keep original order if parsing fails
      }
    });

    return filtered;
  }

  String getOgloszenieContent(int ogloszenieId) {
    final details = _cachedOgloszeniaDetails?[ogloszenieId];
    if (details != null) {
      return details.content.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    // Fallback to intro
    final ogloszenie = _cachedOgloszenia?.firstWhere(
      (o) => o.id == ogloszenieId,
      orElse: () => throw StateError('Ogloszenie not found'),
    );
    return ogloszenie?.intro ?? '';
  }

  bool isImageValid(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    return _cachedImageValidity?[imageUrl] ?? false;
  }

  String getCategoryName(int categoryId) {
    final category = _cachedKategorie?.firstWhere(
      (k) => k.id == categoryId,
      orElse: () => throw StateError('Category not found'),
    );
    return category?.name ?? '';
  }

  void _clearCache() {
    _cachedOgloszenia = null;
    _cachedKategorie = null;
    _cachedOgloszeniaDetails = null;
    _cachedImageValidity = null;
  }

  void dispose() {
    _loadingController.close();
  }
}