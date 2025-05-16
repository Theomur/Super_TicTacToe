class FileManager {
  // В памяти храним 9 мини-полей, каждое — список из 9 символов ('X','O','-')
  static final List<List<String>> _boards =
      List.generate(9, (_) => List.filled(9, '-'));

  // Загрузить состояние мини-поля из памяти
  static Future<List<String>> loadBoard(int index) async {
    return List<String>.from(_boards[index]);
  }

  // Сохранить состояние мини-поля в память
  static Future<void> saveBoard(int index, List<String> cells) async {
    _boards[index] = List<String>.from(cells);
  }

  // Сброс всех мини-полей
  static Future<void> resetBoards() async {
    for (int i = 0; i < 9; i++) {
      _boards[i] = List.filled(9, '-');
    }
  }
}
