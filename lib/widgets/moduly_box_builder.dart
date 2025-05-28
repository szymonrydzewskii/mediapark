import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad.dart';
import 'package:mediapark/models/samorzad_details.dart';
import 'package:mediapark/widgets/tiles/modul_tile.dart';
import 'package:mediapark/widgets/tiles/more_tile.dart';
import 'package:mediapark/animations/fade_in_up.dart';

const externalAliases = ['facebook', 'youtube', 'instagram', 'portal-x'];

List<Widget> buildModulyBoxy(
  BuildContext context,
  Samorzad aktywnySamorzad,
  List<SamorzadModule> modules,
) {
  final zwykle = modules.where((m) => !externalAliases.contains(m.alias)).toList();
  final zewnetrzne = modules.where((m) => externalAliases.contains(m.alias)).toList();

  final List<Widget> boxy = zwykle.asMap().entries.map((entry) {
    final index = entry.key;
    final modul = entry.value;
    return FadeInUpWidget(
      delay: Duration(milliseconds: index * 100),
      child: ModulTile(key: ValueKey(modul.alias), modul: modul),
    );
  }).toList();

  if (zewnetrzne.isNotEmpty) {
    boxy.add(
      FadeInUpWidget(
        delay: Duration(milliseconds: zwykle.length * 100),
        child: MoreTile(
          key: ValueKey('wiecej'),
          aktywnySamorzad: aktywnySamorzad,
          zewnetrzne: zewnetrzne,
        ),
      ),
    );
  }

  return boxy;
}
