import 'package:flutter/material.dart';
import 'package:mediapark/helpers/version_checker.dart';
import 'package:mediapark/widgets/update_required_overlay.dart';

class VersionCheckWrapper extends StatefulWidget {
  final Widget child;
  const VersionCheckWrapper({super.key, required this.child});

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  bool _showUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final needUpdate = await VersionChecker(
        apiUrl: 'https://test.wdialogu.pl/app-version',
      ).checkForUpdate(context: context, showDialog: false);
      if (mounted && needUpdate) {
        setState(() => _showUpdate = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showUpdate)
          Positioned.fill(
            child: UpdateRequiredOverlay(
              onLater: () => setState(() => _showUpdate = false),
            ),
          ),
      ],
    );
  }
}
