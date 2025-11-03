import 'package:flutter/material.dart';

class AktualizacjaScreen extends StatelessWidget {
  const AktualizacjaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dostępna jest nowa wersja aplikacji',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Proszę zaktualizuj aplikację, aby kontynuować.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // tutaj możesz otworzyć sklep lub link do aktualizacji
                },
                child: Text('Zaktualizuj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
