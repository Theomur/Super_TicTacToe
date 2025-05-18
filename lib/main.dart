import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'file_manager.dart';
import 'game_logic.dart';
import 'board_widget.dart';

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

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<List<String>> boards = List.generate(9, (_) => List.filled(9, '-'));
  List<String> winners = List.filled(9, '-');
  int? activeBoard;
  String bigWinner = '-';

  @override
  void initState() {
    super.initState();
    _loadAllBoards();
  }

  Future<void> _loadAllBoards() async {
    for (int i = 0; i < 9; i++) {
      boards[i] = await FileManager.loadBoard(i);
      winners[i] = GameLogic.checkWinner(boards[i]);
    }
    bigWinner = _checkBigWinner();
    setState(() {});
  }

  Future<void> _resetGame() async {
    await FileManager.resetBoards();
    setState(() {
      for (int i = 0; i < 9; i++) {
        boards[i] = List.filled(9, '-');
        winners[i] = '-';
      }
      activeBoard = null;
      bigWinner = '-';
    });
  }

  // Проверка победителя в большой игре по winners (9 элементов)
  String _checkBigWinner() {
    return GameLogic.checkWinner(winners);
  }

  void _showBoardDialog(int boardIndex) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Мини-игра'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: BoardGridWidget(
              cells: boards[boardIndex],
              onCellTap: (cellIndex) async {
                if (boards[boardIndex][cellIndex] != '-') return;
                Navigator.of(ctx).pop();
                await _handlePlayerMove(boardIndex, cellIndex);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePlayerMove(int boardIndex, int cellIndex) async {
    // Игрок ходит
    setState(() {
      boards[boardIndex][cellIndex] = 'X';
      winners[boardIndex] = GameLogic.checkWinner(boards[boardIndex]);
    });
    await FileManager.saveBoard(boardIndex, boards[boardIndex]);

    // Проверяем победу в большой игре
    bigWinner = _checkBigWinner();
    if (bigWinner != '-') {
      _showBigWinnerDialog(bigWinner);
      return; // Останавливаем дальнейшие ходы
    }

    // Определяем следующее активное мини-поле
    int nextActive = cellIndex;
    bool isNextBoardWon = winners[nextActive] != '-';
    bool isNextBoardFull = !boards[nextActive].contains('-');
    if (isNextBoardWon || isNextBoardFull) {
      nextActive = -1;
    }
    activeBoard = nextActive >= 0 ? nextActive : null;
    setState(() {});

    // Ход компьютера
    int compBoard = -1;
    if (activeBoard != null &&
        winners[activeBoard!] == '-' &&
        boards[activeBoard!].contains('-')) {
      compBoard = activeBoard!;
    } else {
      List<int> possibleBoards = [];
      for (int i = 0; i < 9; i++) {
        if (winners[i] == '-' && boards[i].contains('-')) {
          possibleBoards.add(i);
        }
      }
      if (possibleBoards.isNotEmpty) {
        compBoard = possibleBoards[Random().nextInt(possibleBoards.length)];
      }
    }
    if (compBoard >= 0) {
      int compCell = GameLogic.getRandomMove(boards[compBoard]);
      if (compCell >= 0) {
        setState(() {
          boards[compBoard][compCell] = 'O';
          winners[compBoard] = GameLogic.checkWinner(boards[compBoard]);
        });
        await FileManager.saveBoard(compBoard, boards[compBoard]);

        // Проверяем победу в большой игре после хода компьютера
        bigWinner = _checkBigWinner();
        if (bigWinner != '-') {
          _showBigWinnerDialog(bigWinner);
          return;
        }

        // Обновляем активное поле
        nextActive = compCell;
        isNextBoardWon = winners[nextActive] != '-';
        isNextBoardFull = !boards[nextActive].contains('-');
        if (isNextBoardWon || isNextBoardFull) {
          nextActive = -1;
        }
        activeBoard = nextActive >= 0 ? nextActive : null;
        setState(() {});
      }
    }
  }

  void _showBigWinnerDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false, // нельзя закрыть тапом вне диалога
      builder: (ctx) => AlertDialog(
        title: Text('Победитель: $winner'),
        content: const Text('Поздравляем! Игра окончена.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: const Text('Играть ещё'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Супер крестики-нолики'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Сбросить игру',
          ),
        ],
      ),
      body: boards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  for (int row = 0; row < 3; row++)
                    Expanded(
                      child: Row(
                        children: [
                          for (int col = 0; col < 3; col++)
                            Expanded(child: _buildMiniBoard(row * 3 + col)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniBoard(int index) {
    bool isWon = (winners[index] != '-');
    bool isActive = (activeBoard == index) && !isWon;
    Color borderColor = isActive ? Colors.blue : Colors.black;
    double borderWidth = isActive ? 3.0 : 1.0;

    Widget content;
    if (isWon) {
      content = Center(
        child: Text(
          winners[index],
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      content = BoardGridWidget(cells: boards[index]);
    }

    return GestureDetector(
      onTap: (!isWon && (activeBoard == null || isActive))
          ? () => _showBoardDialog(index)
          : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: content,
        ),
      ),
    );
  }
}
