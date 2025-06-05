class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  Quote.fromJSON(Map<String, dynamic> map)
    : text = map['q'] ?? '',
      author = map['a'] ?? '';

}