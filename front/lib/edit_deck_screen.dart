import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDeckScreen extends StatefulWidget {
  final dynamic deck;

  EditDeckScreen({required this.deck});

  @override
  _EditDeckScreenState createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  List<dynamic> cards = [];
  Map<String, int> selectedCards = {};

  @override
  void initState() {
    super.initState();
    selectedCards =
        Map.fromIterable(widget.deck['cards'], key: (e) => e, value: (e) => 1);
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

  saveDeck() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/edit_deck/${widget.deck['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cards': selectedCards.entries
            .map((e) => List.generate(e.value, (index) => e.key))
            .expand((i) => i)
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
      Navigator.pop(context);
    } else {
      throw Exception('デッキの保存に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('デッキ編集: ${widget.deck['name']}'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final count = selectedCards[card['name']] ?? 0;
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('${card['name']} (x$count)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(card['type']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (count > 0) {
                                selectedCards[card['name']] = count - 1;
                                if (selectedCards[card['name']] == 0) {
                                  selectedCards.remove(card['name']);
                                }
                              }
                            });
                          },
                          color: Colors.grey,
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (count < 2) {
                                selectedCards[card['name']] = count + 1;
                              }
                            });
                          },
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: saveDeck,
              child: Text('デッキを更新'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
