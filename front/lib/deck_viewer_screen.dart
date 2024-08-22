import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_deck_screen.dart';

class DeckViewerScreen extends StatefulWidget {
  @override
  _DeckViewerScreenState createState() => _DeckViewerScreenState();
}

class _DeckViewerScreenState extends State<DeckViewerScreen> {
  List<dynamic> decks = [];

  @override
  void initState() {
    super.initState();
    fetchDecks();
  }

  fetchDecks() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/decks'));
    if (response.statusCode == 200) {
      setState(() {
        decks = json.decode(response.body);
      });
    } else {
      throw Exception('デッキデータの取得に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(decks[index]['name'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.edit, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeckDetailScreen(deck: decks[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class DeckDetailScreen extends StatelessWidget {
  final dynamic deck;

  DeckDetailScreen({required this.deck});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deck['name']),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: deck['cards'].length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(deck['cards'][index],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // 編集のための機能を追加予定
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDeckScreen(deck: deck),
            ),
          );
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.black,
      ),
    );
  }
}
