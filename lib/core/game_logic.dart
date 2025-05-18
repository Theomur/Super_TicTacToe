import 'dart:math';

class GameLogic {
  // Проверяет победителя на мини-поле (список из 9 элементов). Возвращает "X", "O" или "-" (пока нет победы).
  static String checkWinner(List<String> cells) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // горизонтали
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // вертикали
      [0, 4, 8], [2, 4, 6] // диагонали
    ];
    for (var pattern in winPatterns) {
      String a = cells[pattern[0]];
      if (a != '-' && a == cells[pattern[1]] && a == cells[pattern[2]]) {
        return a; // найден победитель 'X' или 'O'
      }
    }
    return '-'; // победы нет
  }

  // Выбрать случайную свободную клетку (возвращает индекс или -1, если нет свободных)
  static int getRandomMove(List<String> cells) {
    List<int> emptyIndices = [];
    for (int i = 0; i < cells.length; i++) {
      if (cells[i] == '-') emptyIndices.add(i);
    }
    if (emptyIndices.isEmpty) return -1;
    return emptyIndices[Random().nextInt(emptyIndices.length)];
  }
}
