import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediapark/models/wydarzenia_models.dart';

class WydarzeniaService {
  final int institutionId;
  final http.Client _client;
  final String base; // pozwala łatwo podmienić na produkcję

  WydarzeniaService({
    required this.institutionId,
    http.Client? client,
    this.base = 'https://test.wdialogu.pl',
  }) : _client = client ?? http.Client();

  Uri _listaUri({int page = 1}) =>
      Uri.parse('$base/v1/i/$institutionId/wydarzenia/lista/$page');

  Uri _szczegolyUri(int id) =>
      Uri.parse('$base/v1/i/$institutionId/wydarzenia/szczegoly/$id');

  Future<List<WydarzenieListItem>> fetchLista({int page = 1}) async {
    final res = await _client.get(_listaUri(page: page));
    if (res.statusCode != 200) {
      throw Exception('Błąd pobierania listy wydarzeń: ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['list'] as List<dynamic>? ?? []);
    return list.map((e) => WydarzenieListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Jeżeli chcesz zassać wszystkie strony:
  Future<List<WydarzenieListItem>> fetchWszystkieStrony({int startPage = 1}) async {
    int page = startPage;
    final acc = <WydarzenieListItem>[];
    while (true) {
      final res = await _client.get(_listaUri(page: page));
      if (res.statusCode != 200) {
        if (acc.isNotEmpty) return acc;
        throw Exception('Błąd pobierania listy wydarzeń: ${res.statusCode}');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (json['list'] as List<dynamic>? ?? []);
      acc.addAll(list.map((e) => WydarzenieListItem.fromJson(e as Map<String, dynamic>)));

      final pagination = (json['pagination'] as Map<String, dynamic>?);
      final hasNext = pagination?['has_next'] == true ||
          (pagination?['current_page'] ?? 1) < (pagination?['total_pages'] ?? 1);
      if (!hasNext) break;
      page++;
    }
    return acc;
  }

  Future<WydarzenieDetails> fetchSzczegoly(int id) async {
    final res = await _client.get(_szczegolyUri(id));
    if (res.statusCode != 200) {
      throw Exception('Błąd pobierania szczegółów: ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return WydarzenieDetails.fromJson(json);
  }
}
