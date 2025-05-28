import 'package:flutter/material.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
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

  String selectedCategory = 'active';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchKonsultacje();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9F2),
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFCCE9F2),
        centerTitle: true
        // TODO: Nazwa kategorii w której się znajduje (trwajace, zaplanowane, zakonczone)
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<Map<String, List<Konsultacje>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Błąd: ${snapshot.error}'));
                    }

                    final konsultacje = snapshot.data!;
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      children: [
                        _buildSection(
                          _categoryLabel(selectedCategory),
                          konsultacje[selectedCategory] ?? [],
                        ),
                        const SizedBox(height: 100), // dla przestrzeni pod bar
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          _buildFloatingCategoryBar(), 
        ],
      ),
    );
  }

  Widget _buildFloatingCategoryBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryButton('active', 'Trwające'),
              const SizedBox(width: 8),
              _buildCategoryButton('planned', 'Zaplanowane'),
              const SizedBox(width: 8),
              _buildCategoryButton('finished', 'Zakończone'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String categoryKey, String label) {
    final isSelected = selectedCategory == categoryKey;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = categoryKey;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white38 : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _categoryLabel(String key) {
    switch (key) {
      case 'active':
        return 'Trwające';
      case 'planned':
        return 'Zaplanowane';
      case 'finished':
        return 'Zakończone';
      default:
        return '';
    }
  }

  Widget _buildSection(String title, List<Konsultacje> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text('Brak konsultacji dla wybranej kategorii')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((konsultacja) => _buildKonsultacjaCard(konsultacja)),
      ],
    );
  }

  Widget _buildKonsultacjaCard(Konsultacje konsultacja) {
    String shorterDescription(String desc) =>
        desc.length > 300 ? '${desc.substring(0, 200)}...' : desc;

    return Card(
      color: const Color(0xFFD6F4FE),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KonsultacjeDetailsPage(konsultacja: konsultacja),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      konsultacja.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (konsultacja.shortDescription.trim().isNotEmpty)
                      Text(
                        shorterDescription(konsultacja.shortDescription),
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 14),
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
