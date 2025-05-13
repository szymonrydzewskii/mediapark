import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/services/samorzad_details_service.dart';
import '../models/samorzad.dart';
import 'adaptive_asset_image.dart';

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);


  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: backgroundColor,
      // automaticallyImplyLeading: true,
      title: Row(
        children: [
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: AdaptiveNetworkImage(
                  url: active.herb,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              active.nazwa,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Ink(
          height: 40,
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
        height: MediaQuery.of(ctx).size.height - 150,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Ustawienia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'O APLIKACJI',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
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
                child: const Text(
                  'Zamknij',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
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
    title: Text(title, style: const TextStyle(fontSize: 16)),
    subtitle: subtitle.isNotEmpty
        ? Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          )
        : null,
    trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    onTap: onTap,
  );
}