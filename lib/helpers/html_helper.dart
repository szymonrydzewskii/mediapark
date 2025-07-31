import 'package:html_unescape/html_unescape.dart';

final _unescaper = HtmlUnescape();

/// Usuwa tagi <br>, zamienia je na spację i od‐unescapuje encje HTML:
String cleanHtmlString(String raw) {
  // 1) zamień <br />, <br/> i <br> na zwykłą spację
  var noBreaks = raw.replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), ' ');
  // 2) usuń inne ewentualne tagi HTML
  var noTags = noBreaks.replaceAll(RegExp(r'<[^>]+>'), '');
  // 3) od‑unescapuj encje HTML (&nbsp;, &#39; itp)
  return _unescaper.convert(noTags);
}
