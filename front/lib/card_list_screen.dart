import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              cards[index]['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(cards[index]['type']),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(card: cards[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CardDetailScreen extends StatelessWidget {
  final dynamic card;

  CardDetailScreen({required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card['name']),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カード名: ${card['name']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'タイプ: ${card['type']}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
