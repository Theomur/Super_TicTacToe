import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'file_manager.dart';
import 'game_logic.dart';
import 'board_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });
  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Состояние 9 мини-полей, каждая — список из 9 символов
  List<List<String>> boards = List.generate(9, (_) => List.filled(9, '-'));
  List<String> winners =
      List.filled(9, '-'); // Победитель каждого мини-поля ("X","O" или "-")
  int? activeBoard; // Индекс активного мини-поля (0..8) или null если свободно

  @override
  void initState() {
    super.initState();
    _loadAllBoards();
  }

  // Загрузка всех мини-полей из файлов
  Future<void> _loadAllBoards() async {
    for (int i = 0; i < 9; i++) {
      boards[i] = await FileManager.loadBoard(i);
      winners[i] = GameLogic.checkWinner(boards[i]);
    }
    setState(() {});
  }

  // Сброс игры: очистить все файлы и локальное состояние
  Future<void> _resetGame() async {
    await FileManager.resetBoards();
    setState(() {
      for (int i = 0; i < 9; i++) {
        boards[i] = List.filled(9, '-');
        winners[i] = '-';
      }
      activeBoard = null;
    });
  }

  // Обработка нажатия на мини-поле (пользователь хочет ходить в [boardIndex])
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
                // Если клетка занята, игнорируем
                if (boards[boardIndex][cellIndex] != '-') return;
                Navigator.of(ctx).pop(); // закрываем диалог сразу после хода
                await _handlePlayerMove(boardIndex, cellIndex);
              },
            ),
          ),
        );
      },
    );
  }

  // Ход игрока X в мини-поле [boardIndex], клетка [cellIndex]
  Future<void> _handlePlayerMove(int boardIndex, int cellIndex) async {
    // 1. Сделать ход игрока (X)
    setState(() {
      boards[boardIndex][cellIndex] = 'X';
      winners[boardIndex] = GameLogic.checkWinner(boards[boardIndex]);
    });
    await FileManager.saveBoard(boardIndex, boards[boardIndex]);

    // Определяем следующее активное мини-поле
    int nextActive = cellIndex;
    if (winners[nextActive] != '-') nextActive = -1; // если цель занята победой
    activeBoard = nextActive >= 0 ? nextActive : null;
    setState(() {}); // обновить активное поле

    // 2. Ход компьютера (O)
    // Определяем, где компьютер может ходить
    int compBoard = -1;
    if (activeBoard != null && winners[activeBoard!] == '-') {
      compBoard = activeBoard!;
    } else {
      // выбираем любой доступный мини-board с пустыми клетками
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

        // Новый активный мини-board – по позиции, куда походил компьютер
        nextActive = compCell;
        if (winners[nextActive] != '-') nextActive = -1;
        activeBoard = nextActive >= 0 ? nextActive : null;
        setState(() {});
      }
    }
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
                  // Строим 3 строки, каждая содержит 3 мини-поля
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

  // Построить виджет для одного мини-поля с индексом [index]
  Widget _buildMiniBoard(int index) {
    bool isWon = (winners[index] != '-');
    bool isActive = (activeBoard == index) && !isWon;
    Color borderColor = isActive ? Colors.blue : Colors.black;
    double borderWidth = isActive ? 3.0 : 1.0;

    Widget content;
    if (isWon) {
      // Если мини-поле выиграно, показываем большую букву победителя
      content = Center(
        child: Text(
          winners[index],
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // Иначе – превью текущего состояния мини-поля (без обработки тапов)
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
