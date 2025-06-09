class Quote {
  final String text;
  final String author;
  int? id;

  Quote({required this.text, required this.author});

  Quote.fromJSON(Map<String, dynamic> map)
    : text = map['q'] ?? '',
      author = map['a'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'q': text,
      'a': author
    };
  }
}