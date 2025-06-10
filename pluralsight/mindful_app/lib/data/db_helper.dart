import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';
import 'quotes.dart';

class DbHelper {
  DatabaseFactory dbFactory = databaseFactoryIo;
  Database? db;
  final store = intMapStoreFactory.store('quotes');

  Future<Database> _openDb() async {
    final docsPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docsPath.path, 'quotes.db');
    final db = await dbFactory.openDatabase(dbPath);
    return db;
  }

  Future<int> insertQuote(Quote quote) async {
    try {
      Database db = await _openDb();
      int id = await store.add(db, quote.toMap());
      return id;
    } on Exception catch (_) {
      return 0;
    }
  }

  Future<List<Quote>> getQuotes() async {
    Database db = await _openDb();
    final finder = Finder(sortOrders: [SortOrder('q')]);
    final quotesSnapshot = await store.find(db, finder: finder);
    return quotesSnapshot.map((item) {
      final quote = Quote.fromJSON(item.value);
      quote.id = item.key;
      return quote;
    }).toList();
  }

  Future<bool> deleteQuote(int id) async {
    try {
      final db = await _openDb();
      await store.record(id).delete(db);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
