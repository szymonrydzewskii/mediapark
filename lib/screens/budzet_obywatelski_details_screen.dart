import 'package:flutter/material.dart';
import '../models/budzet_obywatelski_details.dart';
import '../services/budzet_obywatelski_details_service.dart';
import 'package:flutter_html/flutter_html.dart';

class BudzetObywatelskiDetailsScreen extends StatelessWidget {
  final int projectId;

  const BudzetObywatelskiDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły projektu')),
      body: FutureBuilder<BudzetObywatelskiDetails>(
        future: fetchProjektDetails(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Brak danych'));
          } else {
            final details = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (details.mainPhotoUrl != null)
                    Image.network(details.mainPhotoUrl!),
                  const SizedBox(height: 12),
                  Text(
                    details.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (details.projectStatusValue != null)
                    Text("Status: ${details.projectStatusValue}"),
                  if (details.typeValue != null)
                    Text("Rodzaj: ${details.typeValue}"),
                  if (details.projectEstimatedCostValue != null)
                    Text("Koszt: ${details.projectEstimatedCostValue}"),
                  if (details.projectEditionValue != null)
                    Text("Edycja: ${details.projectEditionValue}"),
                  const SizedBox(height: 12),
                  if (details.longDescValue != null)
                    Html(
                      data: details.longDescValue!
                          .replaceAll('&nbsp;', ' ')
                          .replaceAll('\r\n', '\n'),
                    ),
                  const SizedBox(height: 12),
                  if (details.additionalDataValue != null)
                    Html(
                      data: details.additionalDataValue!.replaceAll(
                        '&nbsp;',
                        ' ',
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
