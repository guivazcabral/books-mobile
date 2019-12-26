import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:dio/dio.dart';
import 'package:booksmobile/constants.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String _barcode = '';
  bool _isLoading = false;
  Response _book;
  String isbn = '';

  void _setBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode('#ff0000', 'Cancelar', true, ScanMode.BARCODE);
      if (barcode != "-1") {
        setState(() {
          _barcode = barcode;
        });

        postBook(barcode);
      }
    } catch (e) {
      print(e);
    }
  }

  void postBook(String barcode) async {
    setState(() {
      _isLoading = true;
      _book = null;
    });

    try {
      Response book = await Dio().post("$API_URL/books/$barcode");
      setState(() {
        _book = book;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget bookCard = Card();

  @override
  Widget build(BuildContext context) {
    if (_book != null) {
      var thisBook = _book.data;

      bookCard = Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(thisBook['image']),
              ),
              Text(
                thisBook['title'],
                style: TextStyle(fontSize: 22.0),
              ),
              Text(
                thisBook['author'],
                style: TextStyle(fontSize: 16.0),
              )
            ],
          ),
        ),
      );
    }

    Widget loading = Center();

    if (_isLoading) {
      loading = CircularProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'ISBN',
                ),
                onChanged: (text) {
                  setState(() {
                    isbn = text;
                  });
                },
              ),
            ),
            RaisedButton(child: Text('Submit'), onPressed: () => postBook(isbn),),
            Text('Or'),
            RaisedButton(
              child: Text('Scan'),
              onPressed: () => _setBarcode(),
            ),
            loading,
            Center(
              child: bookCard,
            )
          ],
        ),
      ),
    );
  }
}
