import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../services/image_cache_service.dart';
import 'dart:typed_data';
import 'dart:math';

class CachedNetworkImageWidget extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const CachedNetworkImageWidget({
    super.key,
    required this.url,
    this.width = 40,
    this.height = 40,
  });

  @override
  State<CachedNetworkImageWidget> createState() =>
      _CachedNetworkImageWidgetState();
}

class _CachedNetworkImageWidgetState extends State<CachedNetworkImageWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // Zmień tę metodę żeby cache działał w tle:
  Future<void> _loadImage() async {
    if (widget.url.isEmpty) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    try {
      // Sprawdź cache
      final cached = await ImageCacheService.getImage(widget.url);
      if (cached != null) {
        if (mounted) {
          setState(() {
            _imageBytes = cached;
            _isLoading = false;
          });
        }
        return;
      }

      // Pobierz z sieci - to może trwać długo
      final response = await http
          .get(Uri.parse(widget.url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Zapisz w cache w tle (bez await)
        ImageCacheService.cacheImage(widget.url, bytes).catchError((e) {
          // Zignoruj błędy cache
        });

        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
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
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
      );
    }

    if (_hasError || _imageBytes == null) {
      return Icon(
        Icons.error,
        size: min(widget.width.w, widget.height.h),
        color: Colors.grey,
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
    );
  }
}
