// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class DiagnosticWidget extends StatefulWidget {
//   const DiagnosticWidget({super.key});

//   @override
//   State<DiagnosticWidget> createState() => _DiagnosticWidgetState();
// }

// class _DiagnosticWidgetState extends State<DiagnosticWidget> {
//   bool? canLaunchExternal;
//   bool? internetAvailable;
//   bool? webViewWorks;

//   Future<void> runDiagnostics() async {
//     bool external = false;
//     bool webview = false;
//     bool internet = false;

//     try {
//       external = await launchUrlString(
//         'https://google.com',
//         mode: LaunchMode.externalApplication,
//       );
//     } catch (_) {
//       external = false;
//     }

//     try {
//       final response = await http.get(Uri.parse('https://www.google.com'));
//       internet = response.statusCode == 200;
//     } catch (_) {
//       internet = false;
//     }

//     try {
//       final controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..loadRequest(Uri.parse("https://flutter.dev"));
//       webview = true;
//     } catch (_) {
//       webview = false;
//     }

//     setState(() {
//       canLaunchExternal = external;
//       internetAvailable = internet;
//       webViewWorks = webview;
//     });
//   }

//   Widget statusTile(String title, bool? result) {
//     return ListTile(
//       title: Text(title),
//       trailing: result == null
//           ? const CircularProgressIndicator()
//           : Icon(
//               result ? Icons.check_circle : Icons.cancel,
//               color: result ? Colors.green : Colors.red,
//             ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     runDiagnostics();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Diagnostyka środowiska')),
//       body: ListView(
//         children: [
//           const SizedBox(height: 20),
//           statusTile('1. Otwieranie linku zewnętrznie', canLaunchExternal),
//           statusTile('2. Połączenie z internetem (Google)', internetAvailable),
//           statusTile('3. Inicjalizacja WebView', webViewWorks),
//         ],
//       ),
//     );
//   }
// }
