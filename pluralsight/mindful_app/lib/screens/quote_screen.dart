import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mindful_app/data/quotes.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  static const address = 'https://zenquotes.io/api/random';
  Quote quote = Quote(text: '', author: '');

  @override
  void initState() {
    super.initState();
    _fetchQuote().then((value) {
      quote = value;
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mindful Quote')),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(quote.text,
              style: const TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(quote.author,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )),
    );
  }

  Future _fetchQuote() async {
    final Uri url = Uri.parse(address);
    final response = await http.get(url);
    final List quoteJson = json.decode(response.body);
    Quote quote = Quote.fromJSON(quoteJson[0]);
    return quote;
  }
}