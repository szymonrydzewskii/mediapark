import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/services/samorzad_details_service.dart';
import 'adaptive_asset_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Samorzad active;
  final VoidCallback onLogoTap;
  final VoidCallback onSettings;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.active,
    required this.onLogoTap,
    required this.onSettings,
    this.backgroundColor = const Color.fromARGB(255, 45, 45, 45),
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: backgroundColor,
      title: Row(
        children: [
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: AdaptiveNetworkImage(
                  url: active.herb,
                  width: 40.w,
                  height: 40.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              active.nazwa,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Ink(
          height: 40.h,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(),
          ),
          child: IconButton(
            onPressed: onSettings,
            icon: Icon(Icons.settings, color: backgroundColor),
          ),
        ),
      ],
    );
  }
}

Future<void> obsluzKlikniecieHerbu({
  required Samorzad samorzad,
  required void Function(bool loading) onLoadingChange,
  required void Function(SamorzadSzczegoly szczegoly) onSzczegolyFetched,
}) async {
  onLoadingChange(true);
  try {
    final szczegoly = await fetchSzczegolyInstytucji(samorzad.id);
    onSzczegolyFetched(szczegoly);
  } catch (e) {
    // TODO
  } finally {
    onLoadingChange(false);
  }
}

void pokazUstawienia(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        height: MediaQuery.of(ctx).size.height - 150.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
        child: Stack(
          children: [
            ListView(
              children: [
                SizedBox(height: 40.h),
                Text(
                  'Ustawienia',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  'O APLIKACJI',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 16.h),
                buildOptionTile('Wersja', '1.0.0'),
                buildOptionTile('Regulamin', '', onTap: () {
                  // TODO: Dodaj nawigację
                }),
                buildOptionTile('Polityka prywatności', '', onTap: () {
                  // TODO: Dodaj nawigację
                }),
                buildOptionTile('Użytkownik', 'Jan Kowalski'),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Zamknij',
                  style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget buildOptionTile(String title, String subtitle, {VoidCallback? onTap}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: TextStyle(fontSize: 16.sp)),
    subtitle: subtitle.isNotEmpty
        ? Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          )
        : null,
    trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    onTap: onTap,
  );
}
