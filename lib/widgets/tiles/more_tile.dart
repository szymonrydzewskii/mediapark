// lib/widgets/tiles/more_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/helpers/haptics.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/widgets/more_links_page.dart';
import 'package:mediapark/animations/slide_fade_route.dart';
import 'package:mediapark/style/app_style.dart';

class MoreTile extends StatelessWidget {
  final SamorzadSzczegoly aktywnySamorzad;
  final List<SamorzadModule> zewnetrzne;

  const MoreTile({
    super.key,
    required this.aktywnySamorzad,
    required this.zewnetrzne,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Haptics.tap();
        await Navigator.push(
          context,
          slideFadeRouteTo(
            MoreLinksPage(
              modules: zewnetrzne,
              aktywnySamorzad: aktywnySamorzad,
            ),
          ),
        );

        if (context.mounted) {
          (context as Element).markNeedsBuild();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Center(
          child: Text(
            'WIĘCEJ',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
