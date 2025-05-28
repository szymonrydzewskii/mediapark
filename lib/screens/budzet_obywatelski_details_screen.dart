import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import '../models/budzet_obywatelski_details.dart';
import '../services/budzet_obywatelski_details_service.dart';

class BudzetObywatelskiDetailsScreen extends StatelessWidget {
  final int projectId;

  const BudzetObywatelskiDetailsScreen({super.key, required this.projectId});

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9F2),
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFCCE9F2),
        centerTitle: true,
      ),
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (details.mainPhotoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: AdaptiveAssetImage(
                            basePath: 'assets/icons/city',
                            height: 200,
                            width: 200,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (details.projectStatusValue != null)
                      _buildRow("Status:", details.projectStatusValue!),
                    if (details.typeValue != null)
                      _buildRow("Rodzaj:", details.typeValue!),
                    if (details.projectEstimatedCostValue != null)
                      _buildRow(
                        "Koszt:",
                        details.projectEstimatedCostValue!.replaceAll(
                          '&nbsp;',
                          '.',
                        ),
                      ),
                    if (details.projectEditionValue != null)
                      _buildRow("Edycja:", details.projectEditionValue!),
                    const SizedBox(height: 12),
                    if (details.longDescValue != null)
                      Text(
                        _stripHtml(details.longDescValue!),
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                    const SizedBox(height: 12),
                    if (details.additionalDataValue != null)
                      if (details.additionalDataValue is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              (details.additionalDataValue as List).map<Widget>((
                                item,
                              ) {
                                final label = item['label'] ?? '';
                                final value = item['value'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${_stripHtml(label.toString())}: ${_stripHtml(value.toString())}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                        )
                      else if (details.additionalDataValue is Map)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            details.additionalDataValue.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _stripHtml(details.additionalDataValue.toString()),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
