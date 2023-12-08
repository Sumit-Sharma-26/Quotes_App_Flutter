import 'package:flutter/material.dart';
import 'package:qoutes_app/quotespage.dart';
import 'package:qoutes_app/utils.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> categories = ["love", "inspirational", "life", "books"];
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
      final url = "https://quotes.toscrape.com/";
      final response = await http.get(Uri.parse(url));
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
      appBar: AppBar(
        title: Text("Quotes App"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isDataLoading = true;
          });
          await fetchData();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CategoryTiles(categories: categories),
              SizedBox(height: 20),
              isDataLoading
                  ? CircularProgressIndicator()
                  : QuoteList(quotes: quotes, authors: authors),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTiles extends StatelessWidget {
  final List<String> categories;

  const CategoryTiles({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuotesPage(categories[index]),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                categories[index].toUpperCase(),
                style: textStyle(20, Colors.white, FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuoteList extends StatelessWidget {
  final List<String> quotes;
  final List<String> authors;

  const QuoteList({Key? key, required this.quotes, required this.authors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Card(
            elevation: 10,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    bottom: 20,
                  ),
                  child: Text(
                    quotes[index],
                    style: textStyle(
                      20,
                      Colors.black,
                      FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    authors[index],
                    style: textStyle(
                      15,
                      Colors.black,
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
