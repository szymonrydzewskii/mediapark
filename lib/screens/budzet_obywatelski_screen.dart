import 'package:flutter/material.dart';
import 'package:mediapark/models/samorzad_details.dart';
import '../services/budzet_obywatelski_service.dart';
import '../models/budzet_obywatelski.dart';
import 'budzet_obywatelski_details_screen.dart';

class BudzetObywatelskiScreen extends StatelessWidget {
  final SamorzadModule modul;

  const BudzetObywatelskiScreen({super.key, required this.modul});

  @override
  Widget build(BuildContext context) {
    const String idInstytucji = '201';

    return Scaffold(
      appBar: AppBar(title: Text(modul.alias.toUpperCase())),
      body: FutureBuilder<List<BudzetObywatelski>>(
        future: fetchProjekty(idInstytucji),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak projektów'));
          } else {
            final projekty = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: projekty.length,
              itemBuilder: (context, index) {
                final projekt = projekty[index];
                return _buildProjektCard(context, projekt);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildProjektCard(BuildContext context, BudzetObywatelski projekt) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // zielony label
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                projekt.statusName.toUpperCase(),
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // tytuł
            Text(
              projekt.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // rodzaj
            if (projekt.typeVisible)
              Row(
                children: [
                  const Text(
                    "Rodzaj: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(projekt.typeValue),
                ],
              ),
            // osiedle
            if (projekt.quartersVisible && projekt.quartersValue.isNotEmpty)
              Row(
                children: [
                  const Text(
                    "Osiedle: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(projekt.quartersValue),
                ],
              ),
            // koszt
            if (projekt.costVisible)
              Row(
                children: [
                  const Text(
                    "Koszt: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(projekt.costValue.replaceAll('&nbsp;', ' ')),
                ],
              ),
            const SizedBox(height: 8),
            // opis
            Text(
              projekt.shortDescription.replaceAll('\r\n', '\n'),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            // przycisk
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BudzetObywatelskiDetailsScreen(
                            projectId: projekt.idProject,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text("Zobacz szczegóły"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
