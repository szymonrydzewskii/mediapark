import 'package:flutter/material.dart';
import '../models/konsultacje.dart';

class KonsultacjeDetailsPage extends StatelessWidget {
  final Konsultacje konsultacja;

  const KonsultacjeDetailsPage({super.key, required this.konsultacja});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(konsultacja.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (konsultacja.photoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(konsultacja.photoUrl),
              ),
            const SizedBox(height: 16),
            Text(konsultacja.category, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: ${konsultacja.status}'),
            const SizedBox(height: 8),
            Text('Od: ${konsultacja.startDate}  Do: ${konsultacja.endDate}'),
            const SizedBox(height: 16),
            Text(konsultacja.shortDescription, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(konsultacja.description.replaceAll(RegExp(r'<[^>]*>'), ''), style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            if (konsultacja.pollUrl.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  // nawigacja do WebView lub launch URL
                  // TODO: użyj np. WebViewPage lub url_launcher
                },
                icon: const Icon(Icons.poll),
                label: const Text('Przejdź do ankiety'),
              ),
          ],
        ),
      ),
    );
  }
}
