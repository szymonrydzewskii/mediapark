// import 'package:flutter/material.dart';
// import 'package:mediapark/samorzad_service.dart';

// class SelectedSamorzady extends StatelessWidget {
//   final Set<Samorzad> wybraneSamorzady;

//   const SelectedSamorzady({super.key, required this.wybraneSamorzady});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Wybrane Samorządy')),
//       body: ListView.builder(
//         itemCount: wybraneSamorzady.length,
//         itemBuilder: (context, index) {
//           final samorzad = wybraneSamorzady.elementAt(index);
//           return ListTile(title: Text(samorzad.nazwa));
//         },
//       ),
//     );
//   }
// }
