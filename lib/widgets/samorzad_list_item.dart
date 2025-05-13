import 'package:flutter/material.dart';
import '../models/samorzad.dart';
import 'adaptive_asset_image.dart';

class SamorzadListItem extends StatelessWidget {
  final Samorzad samorzad;
  final bool isSelected;
  final VoidCallback onTap;

  const SamorzadListItem({
    super.key,
    required this.samorzad,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: onTap,
          leading: AdaptiveNetworkImage(url: samorzad.herb, width: 40, height: 40),
          title: Text(samorzad.nazwa, style: const TextStyle(fontSize: 18)),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
        ),
      ),
    );
  }
}