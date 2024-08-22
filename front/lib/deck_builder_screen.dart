import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeckBuilderScreen extends StatefulWidget {
  @override
  _DeckBuilderScreenState createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  List<dynamic> cards = [];
  Map<String, int> selectedCards = {};
  final TextEditingController deckNameController = TextEditingController();

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

  addCardToDeck(String cardName) {
    if (selectedCards.containsKey(cardName)) {
      if (selectedCards[cardName]! < 2 &&
          selectedCards.values.fold(0, (sum, count) => sum + count) < 20) {
        setState(() {
          selectedCards[cardName] = selectedCards[cardName]! + 1;
        });
      }
    } else {
      if (selectedCards.values.fold(0, (sum, count) => sum + count) < 20) {
        setState(() {
          selectedCards[cardName] = 1;
        });
      }
    }
  }

  removeCardFromDeck(String cardName) {
    if (selectedCards.containsKey(cardName)) {
      if (selectedCards[cardName]! > 1) {
        setState(() {
          selectedCards[cardName] = selectedCards[cardName]! - 1;
        });
      } else {
        setState(() {
          selectedCards.remove(cardName);
        });
      }
    }
  }

  saveDeck() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/save_deck'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deck_name': deckNameController.text,
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
    } else {
      throw Exception('デッキの保存に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('デッキ構築'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: deckNameController,
              decoration: InputDecoration(
                labelText: 'デッキ名',
                labelStyle: TextStyle(color: Colors.grey[600]),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
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
                          onPressed: () => removeCardFromDeck(card['name']),
                          color: Colors.grey,
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () => addCardToDeck(card['name']),
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
              child: Text('デッキを保存'),
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
