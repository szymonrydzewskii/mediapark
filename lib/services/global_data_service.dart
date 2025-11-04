import 'dart:async';
import '../models/ogloszenia.dart';
import '../models/konsultacje.dart';
import 'ogloszenia_service.dart';
import 'konsultacje_service.dart';
import 'image_cache_service.dart';
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

  // Cache for konsultacje
  Map<String, List<Konsultacje>>? _cachedKonsultacje;
  Map<String, bool>? _cachedKonsultacjeImageValidity;

  // Loading states
  bool _isLoading = false;
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  // Getters
  String? get currentMunicipalityId => _currentMunicipalityId;
  bool get isLoading => _isLoading;
  Stream<bool> get loadingStream => _loadingController.stream;

  List<Ogloszenia> get ogloszenia => _cachedOgloszenia ?? [];
  List<KategoriaOgloszen> get kategorie => _cachedKategorie ?? [];
  Map<int, OgloszeniaDetails> get ogloszeniaDetails =>
      _cachedOgloszeniaDetails ?? {};
  Map<String, bool> get imageValidity => _cachedImageValidity ?? {};
  Map<String, List<Konsultacje>> get konsultacje => _cachedKonsultacje ?? {};
  Map<String, bool> get konsultacjeImageValidity =>
      _cachedKonsultacjeImageValidity ?? {};

  Future<void> loadMunicipalityData(String municipalityId) async {
    // If same municipality and data already loaded, return
    if (_currentMunicipalityId == municipalityId &&
        _cachedOgloszenia != null &&
        _cachedKategorie != null &&
        _cachedKonsultacje != null) {
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
        _loadKonsultacjeData(municipalityId),
        // TODO: Add other modules here
        // _loadBudzetObywatelskiData(municipalityId),
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

    final ogloszenia = await service.fetchWszystkie();
    final kategorie = await service.fetchKategorie();

    ogloszenia.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datetime);
        final dateB = DateTime.parse(b.datetime);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    _cachedOgloszenia = ogloszenia;
    _cachedKategorie = kategorie;
    _cachedOgloszeniaDetails = {};
    _cachedImageValidity = {};

    final futures = <Future>[];

    for (final o in ogloszenia) {
      // Load details
      futures.add(
        service
            .fetchSzczegoly(o.id)
            .then((details) {
              _cachedOgloszeniaDetails![o.id] = details;
            })
            .catchError((e) {
              print('Error loading details for ${o.id}: $e');
            }),
      );

      // ✅ ZMIANA: Pobierz i cachuj obraz zamiast tylko walidować
      if (o.mainPhoto != null && o.mainPhoto!.isNotEmpty) {
        futures.add(
          _precacheImage(o.mainPhoto!)
              .then((isValid) {
                _cachedImageValidity![o.mainPhoto!] = isValid;
              })
              .catchError((e) {
                _cachedImageValidity![o.mainPhoto!] = false;
              }),
        );
      }
    }

    await Future.wait(futures);
  }

  Future<void> _loadKonsultacjeData(String municipalityId) async {
    try {
      final service = KonsultacjeService();
      final konsultacjeData = await service.fetchKonsultacje();
      _cachedKonsultacje = konsultacjeData;
      _cachedKonsultacjeImageValidity = {};

      final futures = <Future>[];
      for (final categoryList in konsultacjeData.values) {
        for (final k in categoryList) {
          if (k.photoUrl != null && k.photoUrl!.isNotEmpty) {
            // ✅ ZMIANA: Użyj _precacheImage zamiast _checkImageValidity
            futures.add(
              _precacheImage(k.photoUrl!)
                  .then((isValid) {
                    _cachedKonsultacjeImageValidity![k.photoUrl!] = isValid;
                  })
                  .catchError((e) {
                    _cachedKonsultacjeImageValidity![k.photoUrl!] = false;
                  }),
            );
          }
        }
      }

      await Future.wait(futures);
    } catch (e) {
      print('Error loading konsultacje data: $e');
      _cachedKonsultacje = {'active': [], 'planned': [], 'finished': []};
      _cachedKonsultacjeImageValidity = {};
    }
  }

  // ✅ NOWA METODA: Pobiera i cachuje obraz w tle
  Future<bool> _precacheImage(String imageUrl) async {
    try {
      // Sprawdź czy już jest w cache
      final cached = await ImageCacheService.getImage(imageUrl);
      if (cached != null) {
        return true; // Już w cache, wszystko OK
      }

      // Pobierz z sieci
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 &&
          response.headers['content-type']?.startsWith('image/') == true) {
        // Zapisz w cache
        await ImageCacheService.cacheImage(imageUrl, response.bodyBytes);
        return true;
      }

      return false;
    } catch (e) {
      print('Error precaching image $imageUrl: $e');
      return false;
    }
  }

  List<Ogloszenia> getOgloszeniaByCategory(int? categoryId) {
    if (_cachedOgloszenia == null) return [];

    List<Ogloszenia> filtered;
    if (categoryId == null) {
      filtered = _cachedOgloszenia!;
    } else {
      filtered =
          _cachedOgloszenia!.where((o) => o.idCategory == categoryId).toList();
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

  bool isKonsultacjaImageValid(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    return _cachedKonsultacjeImageValidity?[imageUrl] ?? false;
  }

  void _clearCache() {
    _cachedOgloszenia = null;
    _cachedKategorie = null;
    _cachedOgloszeniaDetails = null;
    _cachedImageValidity = null;
    _cachedKonsultacje = null;
    _cachedKonsultacjeImageValidity = null;
  }

  void dispose() {
    _loadingController.close();
  }
}
