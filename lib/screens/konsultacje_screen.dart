import 'package:flutter/material.dart';
import '../models/konsultacje.dart';
import '../services/konsultacje_service.dart';
import '../screens/konsultacje_details_screen.dart';

class KonsultacjeScreen extends StatefulWidget {
  const KonsultacjeScreen({super.key});

  @override
  State<KonsultacjeScreen> createState() => _KonsultacjeScreenState();
}

class _KonsultacjeScreenState extends State<KonsultacjeScreen> {
  final _service = KonsultacjeService();
  late Future<Map<String, List<Konsultacje>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchKonsultacje();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konsultacje społeczne')),
      body: FutureBuilder<Map<String, List<Konsultacje>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }

          final konsultacje = snapshot.data!;
          return ListView(
            children: [
              _buildSection('Trwające', konsultacje['active']!),
              _buildSection('Zaplanowane', konsultacje['planned']!),
              _buildSection('Zakończone', konsultacje['finished']!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Konsultacje> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...items.map((konsultacja) => ListTile(
              leading: konsultacja.photoUrl.isNotEmpty
                  ? Image.network(konsultacja.photoUrl, width: 60, fit: BoxFit.cover)
                  : const Icon(Icons.insert_drive_file),
              title: Text(konsultacja.title),
              subtitle: Text(konsultacja.shortDescription),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KonsultacjeDetailsPage(konsultacja: konsultacja),
                  ),
                );
              },
            )),
        const Divider(),
      ],
    );
  }
}
