import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'package:mediapark/services/image_cache_service.dart';
import 'package:mediapark/style/app_style.dart';

/// ----------------------
///  ASSET (lokalne pliki)
/// ----------------------
class AdaptiveAssetImage extends StatefulWidget {
  /// Bazowa ścieżka bez rozszerzenia:
  /// np. 'assets/icons/logo_wdialogu'
  final String basePath;
  final double width;
  final double height;

  const AdaptiveAssetImage({
    super.key,
    required this.basePath,
    this.width = 24,
    this.height = 24,
  });

  @override
  State<AdaptiveAssetImage> createState() => _AdaptiveAssetImageState();
}

class _AdaptiveAssetImageState extends State<AdaptiveAssetImage> {
  // Cache manifestu, żeby nie wczytywać go za każdym razem
  static Future<AssetManifest>? _manifest;
  late Future<Widget> _loader;

  @override
  void initState() {
    super.initState();

    // NOWE API – zamiast AssetManifest.json
    _manifest ??= AssetManifest.loadFromAssetBundle(rootBundle);

    _loader = _manifest!.then((manifest) {
      final assets = manifest.listAssets(); // lista wszystkich assetów
      final svgKey = '${widget.basePath}.svg';
      final pngKey = '${widget.basePath}.png';

      if (assets.contains(svgKey)) {
        return SvgPicture.asset(
          svgKey,
          width: widget.width.w,
          height: widget.height.h,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        );
      } else if (assets.contains(pngKey)) {
        return Image.asset(
          pngKey,
          width: widget.width.w,
          height: widget.height.h,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        );
      } else {
        // Jeśli nic nie znaleziono – pokaż ikonkę błędu
        return Icon(
          Icons.error,
          size: min(widget.width.w, widget.height.h),
          color: Colors.red,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loader,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.width.w,
            height: widget.height.h,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
          );
        }

        if (snapshot.hasError) {
          // debugPrint('AdaptiveAssetImage error: ${snapshot.error}');
          return Icon(
            Icons.error,
            size: min(widget.width.w, widget.height.h),
            color: Colors.red,
          );
        }

        if (!snapshot.hasData) {
          // Bezpieczny fallback – pusty box zamiast crasha
          return SizedBox(width: widget.width.w, height: widget.height.h);
        }

        return snapshot.data!;
      },
    );
  }
}

/// ----------------------
///  NETWORK (z URL)
/// ----------------------
class AdaptiveNetworkImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const AdaptiveNetworkImage({
    super.key,
    required this.url,
    this.width = 40,
    this.height = 40,
  });

  @override
  State<AdaptiveNetworkImage> createState() => _AdaptiveNetworkImageState();
}

class _AdaptiveNetworkImageState extends State<AdaptiveNetworkImage> {
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _imageBytes;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _loadImage();
  }

  @override
  void didUpdateWidget(AdaptiveNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {
        _currentUrl = widget.url;
        _isLoading = true;
        _hasError = false;
        _imageBytes = null;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final urlToLoad = widget.url;

    if (urlToLoad.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final cached = await ImageCacheService.getImage(urlToLoad);

      if (!mounted || _currentUrl != urlToLoad) return;

      if (cached != null) {
        setState(() {
          _imageBytes = cached;
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(Uri.parse(urlToLoad))
          .timeout(const Duration(seconds: 10));

      if (!mounted || _currentUrl != urlToLoad) return;

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        ImageCacheService.cacheImage(urlToLoad, bytes).catchError((_) {});

        if (mounted && _currentUrl == urlToLoad) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted && _currentUrl == urlToLoad) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && _currentUrl == urlToLoad) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width.w,
        height: widget.height.h,
        child: Center(
          child: SizedBox(
            width: min(widget.width.w, widget.height.h) * 0.6,
            height: min(widget.width.w, widget.height.h) * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_hasError || _imageBytes == null) {
      return Container(
        width: widget.width.w,
        height: widget.height.h,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          Icons.broken_image_outlined,
          size: min(widget.width.w, widget.height.h) * 0.6,
          color: AppColors.blackLight,
        ),
      );
    }

    // SVG
    if (widget.url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.memory(
        _imageBytes!,
        width: widget.width.w,
        height: widget.height.h,
        fit: BoxFit.contain,
      );
    }

    // PNG/JPG
    return Image.memory(
      _imageBytes!,
      width: widget.width.w,
      height: widget.height.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image_outlined,
          size: min(widget.width.w, widget.height.h),
          color: AppColors.blackLight,
        );
      },
    );
  }
}
