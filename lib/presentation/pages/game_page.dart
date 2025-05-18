// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:super_tictactoe/presentation/widgets/mini_board_widget.dart';
import 'package:super_tictactoe/presentation/widgets/winner_popup_widget.dart';
import 'package:super_tictactoe/presentation/widgets/board_widget.dart';
import 'package:super_tictactoe/core/board_manager.dart';
import 'package:super_tictactoe/core/game_logic.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
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
      boards[i] = await BoardManager.loadBoard(i);
      winners[i] = GameLogic.checkWinner(boards[i]);
    }
    bigWinner = _checkBigWinner();
    setState(() {});
  }

  Future<void> _resetGame() async {
    await BoardManager.resetBoards();
    setState(() {
      for (int i = 0; i < 9; i++) {
        boards[i] = List.filled(9, '-');
        winners[i] = '-';
      }
      activeBoard = null;
      bigWinner = '-';
    });
  }

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
                await handlePlayerMove(boardIndex, cellIndex);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> handlePlayerMove(int boardIndex, int cellIndex) async {
    // Ход игрока
    setState(() {
      boards[boardIndex][cellIndex] = 'X';
      winners[boardIndex] = GameLogic.checkWinner(boards[boardIndex]);
    });
    await BoardManager.saveBoard(boardIndex, boards[boardIndex]);

    // Проверка победы в большой игре
    bigWinner = _checkBigWinner();
    if (bigWinner != '-') {
      showBigWinnerDialog(
          context: context, winner: bigWinner, onReset: _resetGame);
      return;
    }

    // Определение следующего активного поля для бота
    int nextActive = cellIndex;
    bool isNextBoardWon = winners[nextActive] != '-';
    bool isNextBoardFull = !boards[nextActive].contains('-');
    if (isNextBoardWon || isNextBoardFull) {
      nextActive = -1;
    }
    activeBoard = nextActive >= 0 ? nextActive : null;
    setState(() {});

    // Ход бота
    int compMove = GameLogic.robotMove(
      allBoards: boards,
      winners: winners,
      playerSymbol: 'O',
      activeBoard: activeBoard,
    );

    if (compMove != -1) {
      int boardIdx = compMove ~/ 9;
      int cellIdx = compMove % 9;

      setState(() {
        boards[boardIdx][cellIdx] = 'O';
        winners[boardIdx] = GameLogic.checkWinner(boards[boardIdx]);
      });
      await BoardManager.saveBoard(boardIdx, boards[boardIdx]);

      // Проверка победы после хода бота
      bigWinner = _checkBigWinner();
      if (bigWinner != '-') {
        showBigWinnerDialog(
            context: context, winner: bigWinner, onReset: _resetGame);
        return;
      }

      // Обновление активного поля для следующего хода игрока
      nextActive = cellIdx;
      isNextBoardWon = winners[nextActive] != '-';
      isNextBoardFull = !boards[nextActive].contains('-');
      if (isNextBoardWon || isNextBoardFull) {
        nextActive = -1;
      }
      activeBoard = nextActive >= 0 ? nextActive : null;
      setState(() {});
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
                  for (int row = 0; row < 3; row++)
                    Expanded(
                      child: Row(
                        children: [
                          for (int col = 0; col < 3; col++)
                            Expanded(
                              child: MiniBoard(
                                index: row * 3 + col,
                                cells: boards[row * 3 + col],
                                winner: winners[row * 3 + col],
                                activeBoardIndex: activeBoard,
                                onTap: () => _showBoardDialog(row * 3 + col),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
