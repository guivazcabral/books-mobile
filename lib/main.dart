import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:booksmobile/constants.dart';
import 'package:booksmobile/screens/scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookshelf',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{'/scan': (_) => new Scanner()},
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Index(title: 'Bookshelf'),
    );
  }
}

class Index extends StatefulWidget {
  Index({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  ScrollController _scrollController;

  List bookData;
  int page;

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        bookData.length > 0) {
      _fetchData(page);
    }
  }

  @override
  void initState() {
    bookData = [];
    page = 1;

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _fetchData(p) async {
    try {
      Response response = await Dio().get("$API_URL/books?page=$p");
      setState(() {
        bookData = bookData + response.data;
        page = p + 1;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookData.length == 0) {
      _fetchData(page);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Books'),
        ),
        body: Container(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: bookData.length,
            itemBuilder: (BuildContext ctx, i) {
              return ListTile(
                trailing: Image.network(bookData[i]['image']),
                title: Text(bookData[i]['title']),
                subtitle: Text(bookData[i]['author']),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed('/scan'),
          tooltip: 'Add book',
          child: Icon(Icons.add),
        ));
  }
}
