import 'package:flutter/material.dart';
import 'package:super_tictactoe/presentation/widgets/board_widget.dart';

class MiniBoard extends StatelessWidget {
  final int index;
  final List<String> cells;
  final String winner; // 'X', 'O' или '-'
  final int? activeBoardIndex;
  final VoidCallback onTap;

  const MiniBoard({
    super.key,
    required this.index,
    required this.cells,
    required this.winner,
    required this.activeBoardIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWon = winner != '-';

    // Подсвечиваем, если:
    // 1. Это активное поле
    // 2. Либо активное поле не задано (null или -1) и текущее поле не выиграно
    final bool isActive = (activeBoardIndex == null ||
            activeBoardIndex == -1 ||
            activeBoardIndex == index) &&
        !isWon;

    final Color borderColor = isActive ? Colors.blue : Colors.black;
    final double borderWidth = isActive ? 3.0 : 1.0;

    final Widget content = isWon
        ? Center(
            child: Text(
              winner,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          )
        : BoardGridWidget(cells: cells);

    final bool isTapEnabled = !isWon &&
        (activeBoardIndex == null ||
            activeBoardIndex == -1 ||
            activeBoardIndex == index);

    return GestureDetector(
      onTap: isTapEnabled ? onTap : null,
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
