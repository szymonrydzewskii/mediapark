// lib/widgets/tiles/more_tile.dart
import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/widgets/more_links_page.dart';
import 'package:mediapark/animations/slide_fade_route.dart';

class MoreTile extends StatelessWidget {
  final Samorzad aktywnySamorzad;
  final List<SamorzadModule> zewnetrzne;

  const MoreTile({super.key, required this.aktywnySamorzad, required this.zewnetrzne});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[800]!, Colors.grey[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'WIĘCEJ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
