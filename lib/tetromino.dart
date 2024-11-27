import 'dart:math';
import 'package:flutter/material.dart';

class Tetromino {
  List<List<int>> shape;
  Color color;

  Tetromino(this.shape, this.color);

  void rotate() {
    shape = List.generate(
      shape[0].length,
          (x) => List.generate(
        shape.length,
            (y) => shape[shape.length - 1 - y][x],
      ),
    );
  }

  void rotateBack() {
    for (int i = 0; i < 3; i++) {
      rotate();
    }
  }

  static Tetromino random() {
    final tetrominoes = [
      Tetromino([[1, 1, 1, 1]], const Color(0xFF00BCD4)), // I - Cyan
      Tetromino([[1, 1], [1, 1]], const Color(0xFFFFEB3B)), // O - Yellow
      Tetromino([[1, 1, 1], [0, 1, 0]], const Color(0xFF9C27B0)), // T - Purple
      Tetromino([[0, 1, 1], [1, 1, 0]], const Color(0xFFF44336)), // Z - Red
      Tetromino([[1, 1, 0], [0, 1, 1]], const Color(0xFF4CAF50)), // S - Green
      Tetromino([[1, 1, 1], [1, 0, 0]], const Color(0xFF2196F3)), // J - Blue
      Tetromino([[1, 1, 1], [0, 0, 1]], const Color(0xFFFF9800)), // L - Orange
    ];
    return tetrominoes[Random().nextInt(tetrominoes.length)];
  }
}
