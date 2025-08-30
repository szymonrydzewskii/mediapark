// lib/widgets/tiles/modul_tile.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/screens/bo_harmonogram_screen.dart';
import 'package:mediapark/screens/budzet_obywatelski_screen.dart';
import 'package:mediapark/screens/kalendarz_wydarzen_screen.dart';
import 'package:mediapark/screens/konsultacje_screen.dart';
import 'package:mediapark/screens/ogloszenia_screen.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/widgets/webview_page.dart';

class ModulTile extends StatelessWidget {
  final SamorzadModule modul;
  final SamorzadSzczegoly samorzad;

  const ModulTile({super.key, required this.modul, required this.samorzad});

  // ===== Helpers =====

  // Spróbuj wyciągnąć ID instytucji z adresu zawierającego segment /i/{id}/
  int? _instIdFromUrlOrNull(String? url) {
    if (url == null || url.isEmpty) return null;
    final parts = url.split('/');
    final i = parts.indexOf('i');
    if (i != -1 && i + 1 < parts.length) {
      return int.tryParse(parts[i + 1]);
    }
    return null;
  }

  // Jedno źródło prawdy: najpierw URL, potem ewentualnie pole z modelu (jeśli masz),
  // na końcu bezpieczny fallback.
  int _resolveInstitutionId({int fallback = 10}) {
    final fromUrl = _instIdFromUrlOrNull(modul.url);
    if (fromUrl != null) return fromUrl;

    // Jeśli masz w SamorzadSzczegoly pole z ID instytucji (np. samorzad.id),
    // to odkomentuj / dopasuj poniżej:
    /*
    try {
      final dynamic s = samorzad;
      final dynId = s.id ?? s.institutionId ?? s.idInstitution ?? s.id_instytucji;
      if (dynId is int) return dynId;
      if (dynId is String) return int.tryParse(dynId) ?? fallback;
    } catch (_) {}
    */
    return fallback;
  }

  void _open(BuildContext context, String title) {
    final alias = modul.alias.toLowerCase();
    final instId = _resolveInstitutionId();
    
    final routes = <String, Widget Function()>{
      'budzet-obywatelski': () => BOHarmonogramScreen(idInstytucji: samorzad.idBoInstitution),
      'konsultacje-spoleczne': () => const KonsultacjeScreen(),
      'ogloszenia': () => OgloszeniaScreen(idInstytucji: '$instId'),
      'kalendarz-wydarzen': () => KalendarzWydarzenScreen(idInstytucji: instId),
    };

    Widget page;
    if (routes.containsKey(alias)) {
      page = routes[alias]!.call();
    } else if (modul.type == 'link' && (modul.url.isNotEmpty)) {
      page = WebViewPage(url: modul.url, title: title);
    } else {
      // Fallback – gdyby przyszło coś nieobsłużonego
      page = WebViewPage(url: modul.url, title: title);
    }

    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
    final alias = modul.alias.toLowerCase();
    final iconPath = 'assets/icons/$alias';
    final words =
        alias
            .replaceAll('-', ' ')
            .split(' ')
            .where((w) => w.trim().isNotEmpty)
            .toList();

    String cap(String w) =>
        w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase();

    String buildTitle(List<String> ws) {
      if (ws.isEmpty) return '';
      if (ws.length == 1) return cap(ws[0]);

      // łam wiersz przed 2. słowem, jeśli ma >= 3 litery
      int breakAt = ws.length > 1 && ws[1].length >= 3 ? 1 : -1;

      final left = ws
          .take(breakAt == -1 ? ws.length : breakAt)
          .map(cap)
          .join(' ');
      final right = breakAt == -1 ? '' : ws.skip(breakAt).map(cap).join(' ');
      return breakAt == -1 ? left : '$left\n$right';
    }

    final title = buildTitle(words);

    return GestureDetector(
      onTap: () => _open(context, title),
      child: SizedBox(
        width: 175.w,
        height: 205.h,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCAECF4),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              SizedBox(
                width: 60.w,
                height: 60.h,
                child: AdaptiveAssetImage(basePath: iconPath),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
