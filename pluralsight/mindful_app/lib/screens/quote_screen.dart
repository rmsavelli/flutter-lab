import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  static const address = 'https://zenquotes.io/api/random';

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future _fetchQuote() async {
    final Uri url = Uri.parse(address);
    final response = await http.get(url);
    print(response.body);
  }
}