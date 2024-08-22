import 'package:flutter/material.dart';
import 'card_list_screen.dart';
import 'deck_builder_screen.dart';
import 'deck_viewer_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蟲神器カード表示',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.grey,
        ),
        fontFamily: 'San Francisco',
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'San Francisco'),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '蟲神器',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.grey,
            tabs: [
              Tab(text: 'カードリスト'),
              Tab(text: 'デッキ構築'),
              Tab(text: 'デッキ閲覧'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CardListScreen(),
            DeckBuilderScreen(),
            DeckViewerScreen(),
          ],
        ),
      ),
    );
  }
}
