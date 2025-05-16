import 'package:flutter/material.dart';

/// Виджет для отображения поля 3x3.
/// [cells] – список из 9 символов ("X","O","-"). Если [onCellTap] задан, то клетки по нему кликабельны.
class BoardGridWidget extends StatelessWidget {
  final List<String> cells;
  final Function(int)? onCellTap;

  const BoardGridWidget({required this.cells, this.onCellTap, super.key});

  @override
  Widget build(BuildContext context) {
    // Используем Table для сетки с видимыми границами
    return Table(
      border: TableBorder.all(color: Colors.black),
      children: [
        TableRow(children: [
          _buildCell(0),
          _buildCell(1),
          _buildCell(2),
        ]),
        TableRow(children: [
          _buildCell(3),
          _buildCell(4),
          _buildCell(5),
        ]),
        TableRow(children: [
          _buildCell(6),
          _buildCell(7),
          _buildCell(8),
        ]),
      ],
    );
  }

  Widget _buildCell(int index) {
    String value = cells[index];
    bool isEmpty = (value == '-');
    // Контейнер для содержимого клетки
    Widget cellContent = Center(
      child: Text(
        isEmpty ? '' : value,
        style: const TextStyle(fontSize: 24),
      ),
    );

    // Если передан обработчик и клетка пустая, делаем её интерактивной
    if (onCellTap != null) {
      return InkWell(
        onTap: isEmpty ? () => onCellTap!(index) : null,
        child: SizedBox(
          width: 40,
          height: 40,
          child: cellContent,
        ),
      );
    } else {
      // Неинтерактивная клетка (превью мини-поля)
      return SizedBox(
        width: 40,
        height: 40,
        child: cellContent,
      );
    }
  }
}
