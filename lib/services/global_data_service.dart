import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/ogloszenia.dart';
import '../models/konsultacje.dart';
import 'image_cache_service.dart';
import 'konsultacje_service.dart';
import 'ogloszenia_service.dart';

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
      await _loadOgloszeniaData(
        municipalityId,
      ); // jeśli padnie -> poleci wyjątek
      await _loadKonsultacjeData(municipalityId); // łapie błędy w środku
    } catch (e) {
      print('Error loading municipality data: $e');
      rethrow;
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
      } catch (_) {
        return 0;
      }
    });

    _cachedOgloszenia = ogloszenia;
    _cachedKategorie = kategorie;
    _cachedOgloszeniaDetails = <int, OgloszeniaDetails>{};
    _cachedImageValidity = <String, bool>{};

    final futures = <Future<void>>[];

    for (final o in ogloszenia) {
      // ✅ Load details (bez catchError -> async/try/catch)
      futures.add(() async {
        try {
          final details = await service.fetchSzczegoly(o.id);
          _cachedOgloszeniaDetails![o.id] = details;
        } catch (e) {
          print('Error loading details for ${o.id}: $e');
        }
      }());

      // ✅ Pobierz i cachuj obraz
      final photo = o.mainPhoto?.trim();
      if (photo != null && photo.isNotEmpty) {
        futures.add(() async {
          final ok = await _precacheImage(
            photo,
          ); // _precacheImage i tak łapie błędy
          _cachedImageValidity![photo] = ok;
        }());
      }
    }

    await Future.wait(futures);
  }

  Future<void> _loadKonsultacjeData(String municipalityId) async {
    try {
      final service = KonsultacjeService();
      final konsultacjeData = await service.fetchKonsultacje();

      _cachedKonsultacje = konsultacjeData;
      _cachedKonsultacjeImageValidity = <String, bool>{};

      final futures = <Future<void>>[];

      for (final categoryList in konsultacjeData.values) {
        for (final k in categoryList) {
          final url = k.photoUrl?.trim();
          if (url == null || url.isEmpty) continue;

          futures.add(() async {
            final ok = await _precacheImage(
              url,
            ); // _precacheImage i tak łapie błędy
            _cachedKonsultacjeImageValidity![url] = ok;
          }());
        }
      }

      await Future.wait(futures);
    } catch (e) {
      print('Error loading konsultacje data: $e');
      _cachedKonsultacje = {'active': [], 'planned': [], 'finished': []};
      _cachedKonsultacjeImageValidity = <String, bool>{};
    }
  }

  // ✅ Pobiera i cachuje obraz w tle
  Future<bool> _precacheImage(String imageUrl) async {
    try {
      // Sprawdź czy już jest w cache
      final cached = await ImageCacheService.getImage(imageUrl);
      if (cached != null) return true;

      // Pobierz z sieci
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 10));

      final isImg =
          response.headers['content-type']?.startsWith('image/') == true;

      if (response.statusCode == 200 && isImg) {
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

    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.datetime);
        final dateB = DateTime.parse(b.datetime);
        return dateB.compareTo(dateA); // newest first
      } catch (_) {
        return 0;
      }
    });

    return filtered;
  }

  String getOgloszenieContent(int ogloszenieId) {
    final details = _cachedOgloszeniaDetails?[ogloszenieId];
    if (details != null) {
      return details.content.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    final ogloszenie = _cachedOgloszenia?.firstWhere(
      (o) => o.id == ogloszenieId,
      orElse: () => throw StateError('Ogloszenie not found'),
    );
    return ogloszenie?.intro ?? '';
  }

  bool isImageValid(String? imageUrl) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return false;
    return _cachedImageValidity?[url] ?? false;
  }

  String getCategoryName(int categoryId) {
    final category = _cachedKategorie?.firstWhere(
      (k) => k.id == categoryId,
      orElse: () => throw StateError('Category not found'),
    );
    return category?.name ?? '';
  }

  bool isKonsultacjaImageValid(String? imageUrl) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return false;
    return _cachedKonsultacjeImageValidity?[url] ?? false;
  }

  void _clearCache() {
    _cachedOgloszenia = null;
    _cachedKategorie = null;
    _cachedOgloszeniaDetails = null;
    _cachedImageValidity = null;
    _cachedKonsultacje = null;
    _cachedKonsultacjeImageValidity = null;
  }

  // ----------------- HELPERY DO SZUKANIA PO ID -----------------

  Ogloszenia? getOgloszenieById(int id) {
    if (_cachedOgloszenia == null) return null;
    try {
      return _cachedOgloszenia!.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Konsultacje? getKonsultacjaById(int id) {
    if (_cachedKonsultacje == null) return null;
    try {
      return _cachedKonsultacje!.values
          .expand((list) => list)
          .firstWhere((k) => k.id == id);
    } catch (_) {
      return null;
    }
  }

  Konsultacje? getKonsultacjaByPollId(int idPoll) {
    if (_cachedKonsultacje == null) return null;
    try {
      return _cachedKonsultacje!.values
          .expand((list) => list)
          .firstWhere((k) => k.idPoll == idPoll);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _loadingController.close();
  }
}
