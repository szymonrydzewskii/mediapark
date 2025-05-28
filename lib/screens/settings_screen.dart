import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCE9F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Color(0xFFCCE9F2),
                title: Text('Ustawienia', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              ),
              const SizedBox(height: 24),
              _buildTile("Regulamin", onTap: () {}),
              _buildTile("Polityka prywatności", onTap: () {}),
              _buildTile("Deklaracja dostępności", onTap: () {}),
              const SizedBox(height: 32),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: AdaptiveAssetImage(
                      basePath: 'assets/icons/notifications',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Powiadomienia PUSH",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Czy chcesz otrzymywać powiadomienia na swoim telefonie?",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: pushEnabled,
                    onChanged: (value) {
                      setState(() {
                        pushEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFB5D7E4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
