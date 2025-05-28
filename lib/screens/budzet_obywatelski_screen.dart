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
      backgroundColor: Color(0xFFCCE9F2),
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: Color(0xFFCCE9F2),
        centerTitle: true,
      ),
      // AppBar(title: Text(modul.alias.toUpperCase())),
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
    String shorterDescription(String desc) =>
        desc.length > 300 ? '${desc.substring(0, 200)}...' : desc;

    return Card(
      color: const Color(0xFFD6F4FE),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18), // dopasowany do Card
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BudzetObywatelskiDetailsScreen(
                    projectId: projekt.idProject,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        projekt.statusName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      projekt.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    if (projekt.quartersVisible &&
                        projekt.quartersValue.isNotEmpty)
                      Row(
                        children: [
                          const Text(
                            "Osiedle: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(projekt.quartersValue),
                        ],
                      ),
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
                    Text(
                      shorterDescription(
                        projekt.shortDescription.replaceAll('\r\n', '\n'),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
