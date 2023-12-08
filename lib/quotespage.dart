import 'package:flutter/material.dart';
import 'package:qoutes_app/utils.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class QuotesPage extends StatefulWidget {
  final String categoryname;

  QuotesPage(this.categoryname);

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  List<String> quotes = [];
  List<String> authors = [];
  bool isDataLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = "https://quotes.toscrape.com/tag/${widget.categoryname}/";
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final document = parser.parse(response.body);
      final quotesClass = document.getElementsByClassName("quote");

      quotes = quotesClass
          .map((element) => element.getElementsByClassName('text')[0].innerHtml)
          .toList();

      authors = quotesClass
          .map(
              (element) => element.getElementsByClassName('author')[0].innerHtml)
          .toList();
    } catch (e) {
      // Handle errors or log them
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isDataLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 50),
            child: Text(
              "${widget.categoryname} quotes".toUpperCase(),
              style: textStyle(30, Colors.black, FontWeight.w700),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                return QuoteCard(
                  quote: quotes[index],
                  author: authors[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final String quote;
  final String author;

  const QuoteCard({Key? key, required this.quote, required this.author})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 10,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
              child: Text(
                quote,
                style: textStyle(20, Colors.black, FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                author,
                style: textStyle(15, Colors.black, FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
