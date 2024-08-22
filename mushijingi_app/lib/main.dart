import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蟲神器カード表示',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardListScreen(),
    );
  }
}

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<dynamic> cards = [];

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  fetchCards() async {
    // PythonバックエンドのURLを指定してください
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/cards'));
    if (response.statusCode == 200) {
      setState(() {
        cards = json.decode(response.body);
      });
    } else {
      throw Exception('カードデータの取得に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カードリスト'),
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cards[index]['name']),
            subtitle: Text(cards[index]['type']),
          );
        },
      ),
    );
  }
}
