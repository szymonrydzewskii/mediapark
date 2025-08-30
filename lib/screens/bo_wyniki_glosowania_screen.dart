import 'package:flutter/material.dart';

class BoWynikiGlosowaniaScreen extends StatelessWidget {
  final int institutionId;

  const BoWynikiGlosowaniaScreen({super.key, required this.institutionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wyniki głosowania')),
      body: const Center(child: Text('Tu będą wyniki głosowania')),
    );
  }
}
