import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediapark/screens/kalendarz_wydarzen_details_screen.dart';
import 'package:mediapark/screens/kalendarz_wydarzen_screen.dart';
import 'package:mediapark/screens/ogloszenia_details_screen.dart';
import 'package:mediapark/screens/konsultacje_details_screen.dart';
import 'package:mediapark/widgets/webview_page.dart';
import 'package:mediapark/services/global_data_service.dart';
// TODO: import do kalendarza
// import 'package:mediapark/screens/kalendarz_wydarzen_screen.dart';

class NotificationService {
  final FirebaseMessaging msgService = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalDataService _globalService = GlobalDataService();

  NotificationService({required this.navigatorKey});

  Future<void> initFCM() async {
    final settings = await msgService.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');

    final token = await msgService.getToken();
    print("📱 FCM TOKEN: $token");

    await msgService.subscribeToTopic("jst_10");
    print("✅ Subskrybowano topic jst_10");

    FirebaseMessaging.onMessage.listen((m) {
      print('📩 ON_MESSAGE (foreground)');
      print('notification: ${m.notification?.title} / ${m.notification?.body}');
      print('data: ${m.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      print('📲 ON_MESSAGE_OPENED_APP');
      print('data: ${m.data}');
      _handleMessage(m);
    });
  }

  String _pickEventTitle(RemoteMessage message) {
    // 1) jeśli backend wysyła w data np. { "title": "..." }
    final dataTitle = message.data['title']?.toString().trim();
    if (dataTitle != null && dataTitle.isNotEmpty) return dataTitle;

    // 2) jeśli to notification message z title
    final notifTitle = message.notification?.title?.trim();
    if (notifTitle != null && notifTitle.isNotEmpty) return notifTitle;

    // 3) fallback
    return 'Wydarzenie';
  }

  // 👇 METODA KLASY – widoczna z MyApp
  Future<void> handleRemoteMessage(RemoteMessage message) async {
    await _handleMessage(message);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final data = message.data;
    print('🔍 Handle message data: $data');

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // 1️⃣ Ogłoszenie / wydarzenie
    if (data['id_announcement'] != null) {
      final idAnnouncement = int.tryParse(data['id_announcement'].toString());
      if (idAnnouncement == null) return;

      if (data['is_event'] == '1') {
        // final idInstytucji =
        //     data['id_instytucji'] ?? _globalService.currentMunicipalityId ?? 0;
        final tytul = _pickEventTitle(message);
        nav.push(
          MaterialPageRoute(
            builder:
                (_) => KalendarzWydarzenDetailsScreen(
                  idInstytucji: 10, // TODO: zmienic na zmienne idInstytucji
                  idWydarzenia: idAnnouncement,
                  tytul: tytul,
                ),
          ),
        );
      } else {
        final ogloszenie = _globalService.getOgloszenieById(idAnnouncement);

        if (ogloszenie == null) {
          if (kDebugMode) {
            print('⚠️ Nie znaleziono ogłoszenia o id $idAnnouncement');
          }
          return;
        }

        final idInstytucji =
            data['id_instytucji']?.toString() ??
            _globalService.currentMunicipalityId ??
            '';

        nav.push(
          MaterialPageRoute(
            builder:
                (_) => OgloszeniaDetailsScreen(
                  ogloszenie: ogloszenie,
                  idInstytucji: idInstytucji,
                ),
          ),
        );
      }

      return;
    }

    // 2️⃣ Ankieta: id_poll
    if (data['id_poll'] != null) {
      final idPoll = int.tryParse(data['id_poll'].toString());
      if (idPoll == null) return;

      final konsultacja = _globalService.getKonsultacjaByPollId(idPoll);

      if (konsultacja == null || konsultacja.pollUrl == null) {
        if (kDebugMode) {
          print('⚠️ Nie znaleziono konsultacji dla id_poll $idPoll');
        }
        return;
      }

      nav.push(
        MaterialPageRoute(
          builder:
              (_) => WebViewPage(
                url: konsultacja.pollUrl!,
                title: konsultacja.title,
              ),
        ),
      );

      return;
    }

    // 3️⃣ Konsultacja: id_consultation
    if (data['id_consultation'] != null) {
      final idConsultation = int.tryParse(data['id_consultation'].toString());
      if (idConsultation == null) return;

      final konsultacja = _globalService.getKonsultacjaById(idConsultation);

      if (konsultacja == null) {
        if (kDebugMode) {
          print('⚠️ Nie znaleziono konsultacji o id $idConsultation');
        }
        return;
      }

      final idInstytucji =
          data['id_instytucji']?.toString() ??
          _globalService.currentMunicipalityId ??
          '';

      nav.push(
        MaterialPageRoute(
          builder:
              (_) => KonsultacjeDetailsPage(
                konsultacja: konsultacja,
                idInstytucji: idInstytucji,
              ),
        ),
      );

      return;
    }
  }
}
