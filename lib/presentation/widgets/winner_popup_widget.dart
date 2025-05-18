import 'package:flutter/material.dart';

Future<void> showBigWinnerDialog({
  required BuildContext context,
  required String winner,
  required VoidCallback onReset,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text('Победитель: $winner'),
      content: const Text('Поздравляем! Игра окончена.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onReset();
          },
          child: const Text('Играть ещё'),
        ),
      ],
    ),
  );
}
