import 'package:flutter/material.dart';
import 'package:super_tictactoe/presentation/pages/game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Super Tic-Tac-Toe',
      home: GamePage(),
    );
  }
}
