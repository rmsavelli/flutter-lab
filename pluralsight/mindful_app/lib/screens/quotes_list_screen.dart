import 'package:flutter/material.dart';
import '../data/quotes.dart';
import '../data/db_helper.dart';

class QuotesListScreen extends StatelessWidget {
  const QuotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My favorite Quotes")),
      body: FutureBuilder(
        future: getQuotes(),
        builder: (context, snapshot) {
          final List<ListTile> listTiles = [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'),);
          } else { 
            for (Quote quote in snapshot.data!) {
              listTiles.add(ListTile(
                title: Text(quote.text),
                subtitle: Text(quote.author),
              ));
            }
            return ListView(children: listTiles,);
          }
        }
      ),
    );
  }

  Future<List<Quote>> getQuotes() async {
    DbHelper helper = DbHelper();
    final quotes = await helper.getQuotes();
    return quotes;
  }
}