import 'dart:math';

class GameLogic {
  static String checkWinner(List<String> cells) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    for (var pattern in winPatterns) {
      String a = cells[pattern[0]];
      if (a != '-' && a == cells[pattern[1]] && a == cells[pattern[2]]) {
        return a;
      }
    }
    return '-';
  }

  static int robotMove({
    required List<List<String>> allBoards,
    required List<String> winners,
    required String playerSymbol,
    required int? activeBoard,
  }) {
    int bestScore = -1000000;
    List<int> bestMoves = [];
    String opponentSymbol = playerSymbol == 'X' ? 'O' : 'X';

    // Определяем доступные доски
    List<int> allowedBoards = _getAllowedBoards(winners, activeBoard);

    // Перебираем только разрешённые доски
    for (int boardIdx in allowedBoards) {
      for (int cellIdx = 0; cellIdx < 9; cellIdx++) {
        if (allBoards[boardIdx][cellIdx] == '-') {
          int score = _evaluateMove(
            allBoards: allBoards,
            winners: winners,
            boardIdx: boardIdx,
            cellIdx: cellIdx,
            playerSymbol: playerSymbol,
            opponentSymbol: opponentSymbol,
          );

          if (score > bestScore) {
            bestScore = score;
            bestMoves = [boardIdx * 9 + cellIdx];
          } else if (score == bestScore) {
            bestMoves.add(boardIdx * 9 + cellIdx);
          }
        }
      }
    }

    return bestMoves.isEmpty
        ? -1
        : bestMoves[Random().nextInt(bestMoves.length)];
  }

  static List<int> _getAllowedBoards(List<String> winners, int? activeBoard) {
    if (activeBoard != null &&
        activeBoard >= 0 &&
        activeBoard < 9 &&
        winners[activeBoard] == '-') {
      return [activeBoard]; // Только активная доска
    } else {
      // Все доски без победителя
      return List.generate(9, (i) => i)
          .where((i) => winners[i] == '-')
          .toList();
    }
  }

  static int _evaluateMove({
    required List<List<String>> allBoards,
    required List<String> winners,
    required int boardIdx,
    required int cellIdx,
    required String playerSymbol,
    required String opponentSymbol,
  }) {
    int score = 0;
    List<String> tempBoard = List.from(allBoards[boardIdx]);
    tempBoard[cellIdx] = playerSymbol;

    // 1. Выигрыш всей игры
    List<String> newWinners = List.from(winners);
    newWinners[boardIdx] = checkWinner(tempBoard);
    if (checkWinner(newWinners) == playerSymbol) return 1000000;

    // 2. Блокировка противника
    tempBoard[cellIdx] = opponentSymbol;
    if (checkWinner(tempBoard) == opponentSymbol) score += 800;

    // 3. Центральные позиции
    if (boardIdx == 4) score += 50;
    if (cellIdx == 4) score += 30;

    return score;
  }
}
