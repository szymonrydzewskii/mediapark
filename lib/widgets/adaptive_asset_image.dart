import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'cached_network_image_widget.dart';

class AdaptiveAssetImage extends StatefulWidget {
  final String basePath; // e.g. 'assets/icons/my_icon'
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
  static Future<Map<String, dynamic>>? _manifest;
  late Future<Widget> _loader;

  @override
  void initState() {
    super.initState();
    _manifest ??= rootBundle
        .loadString('AssetManifest.json')
        .then((s) => json.decode(s) as Map<String, dynamic>);

    _loader = _manifest!.then((map) {
      final svgKey = '${widget.basePath}.svg';
      final pngKey = '${widget.basePath}.png';

      if (map.containsKey(svgKey)) {
        return SvgPicture.asset(
          svgKey,
          width: widget.width.w,
          height: widget.height.h,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        );
      } else if (map.containsKey(pngKey)) {
        return Image.asset(
          pngKey,
          width: widget.width.w,
          height: widget.height.h,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        );
      } else {
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
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: widget.width.w,
            height: widget.height.h,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

class AdaptiveNetworkImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return CachedNetworkImageWidget(url: url, width: width, height: height);
  }
}
