String prettify(String raw) {
  String sentence = raw.replaceAll('-', ' ').toLowerCase();
  return sentence.isNotEmpty
      ? sentence[0].toUpperCase() + sentence.substring(1)
      : '';
}
