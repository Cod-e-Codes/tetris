// game_state.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'tetromino.dart';

class GameState extends ChangeNotifier {
  final int rows = 20;
  final int columns = 10;
  late List<List<Color>> grid;
  Tetromino? currentPiece;
  Tetromino? nextPiece;
  int currentX = 4;
  int currentY = 0;
  bool isGameOver = false;
  Timer? gameTimer;
  int score = 0;
  int level = 1;
  int rowsCleared = 0;
  Duration fallSpeed = const Duration(milliseconds: 500);

  GameState() {
    resetGame(); // Initialize grid
  }

  void startGame() {
    resetGame();
    startGameLoop();
  }

  void resetGame() {
    grid = List.generate(
        rows, (_) => List.generate(columns, (_) => Colors.transparent));
    currentPiece = Tetromino.random();
    nextPiece = Tetromino.random();
    currentX = 4;
    currentY = 0;
    isGameOver = false;
    score = 0;
    level = 1;
    rowsCleared = 0;
    fallSpeed = const Duration(milliseconds: 500);
    notifyListeners(); // Notify that game state has changed
  }

  void startGameLoop() {
    gameTimer?.cancel(); // Cancel any previous timer
    gameTimer = Timer.periodic(fallSpeed, (timer) {
      if (isGameOver) {
        timer.cancel(); // Stop the loop on game over
        gameTimer = null;
      } else {
        movePieceDown(); // Move the piece down each tick
      }
    });
  }

  void movePieceDown() {
    if (canMove(0, 1)) {
      currentY++;
    } else {
      mergePieceToGrid(); // Lock the current piece into the grid
      clearFullRows();
      spawnNewPiece(); // Generate a new tetromino
    }
    notifyListeners(); // This makes sure the UI updates with each move
  }

  void movePieceLeft() {
    if (canMove(-1, 0)) {
      currentX--;
      notifyListeners();
    }
  }

  void movePieceRight() {
    if (canMove(1, 0)) {
      currentX++;
      notifyListeners();
    }
  }

  void rotatePiece() {
    currentPiece?.rotate();
    if (!canMove(0, 0)) {
      currentPiece?.rotateBack();
    }
    notifyListeners();
  }

  void dropPiece() {
    while (canMove(0, 1)) {
      currentY++;
    }
    mergePieceToGrid();
    clearFullRows();
    spawnNewPiece();
    notifyListeners();
  }

  bool canMove(int dx, int dy) {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] == 1) {
          int newX = currentX + x + dx;
          int newY = currentY + y + dy;

          if (newX < 0 || newX >= columns || newY >= rows) {
            return false;
          }
          if (newY >= 0 && grid[newY][newX] != Colors.transparent) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void mergePieceToGrid() {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] == 1) {
          grid[currentY + y][currentX + x] = currentPiece!.color;
        }
      }
    }
  }

  void clearFullRows() {
    int cleared = 0;
    grid.removeWhere((row) {
      if (row.every((color) => color != Colors.transparent)) {
        cleared++;
        return true;
      }
      return false;
    });

    rowsCleared += cleared;
    score += cleared * 100;

    // Increase level every 10 rows cleared
    if (rowsCleared >= level * 10) {
      level++;
      fallSpeed = Duration(milliseconds: (500 / level).clamp(100, 500).toInt());
      // Restart game loop with new speed if game is not paused
      if (gameTimer != null) {
        startGameLoop();
      }
    }

    while (grid.length < rows) {
      grid.insert(0, List.generate(columns, (_) => Colors.transparent));
    }
  }

  void spawnNewPiece() {
    currentPiece = nextPiece;
    nextPiece = Tetromino.random();
    currentX = 4;
    currentY = 0;

    if (!canMove(0, 0)) {
      isGameOver = true;
      gameTimer?.cancel(); // Stop the game loop on game over
      gameTimer = null;
      notifyListeners();
    }
  }

  List<Point<int>> getShadowPosition() {
    int distance = 0;
    while (canMove(0, distance + 1)) {
      distance++;
    }
    List<Point<int>> shadowBlocks = [];
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] == 1) {
          shadowBlocks.add(Point(currentX + x, currentY + y + distance));
        }
      }
    }
    return shadowBlocks;
  }

  void pauseGame() {
    gameTimer?.cancel();
    gameTimer = null;
    notifyListeners();
  }

  void resumeGame() {
    startGameLoop();
    notifyListeners();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}
