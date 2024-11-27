// game_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'tetris_grid.dart';
import 'tetromino.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  TetrisGameState createState() => TetrisGameState();
}

class TetrisGameState extends State<TetrisGame> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartButtonOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameState.isGameOver && _overlayEntry == null) {
        _showGameOverOverlay();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Tetris'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF303F9F), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Text(
                        'Score: ${gameState.score}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Level: ${gameState.level}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    buildNextPiece(),
                    IconButton(
                      icon: Icon(
                        gameState.gameTimer == null ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (gameState.gameTimer == null) {
                          gameState.resumeGame();
                        } else {
                          gameState.pauseGame();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Expanded(child: TetrisGrid()),
                buildControls(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildControls(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => gameState.movePieceLeft(),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_left, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => gameState.rotatePiece(),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rotate_right, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => gameState.movePieceRight(),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextPiece() {
    final gameState = Provider.of<GameState>(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Next',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          if (gameState.nextPiece != null)
            SizedBox(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: TetrominoPainter(gameState.nextPiece!),
              ),
            ),
        ],
      ),
    );
  }

  void _showStartButtonOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Provider.of<GameState>(context, listen: false).startGame();
                _removeOverlay();
              },
              child: const Text('Start Game'),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showGameOverOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(fontSize: 36, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<GameState>(context, listen: false).startGame();
                    _removeOverlay();
                  },
                  child: const Text('Restart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class TetrominoPainter extends CustomPainter {
  final Tetromino tetromino;

  TetrominoPainter(this.tetromino);

  @override
  void paint(Canvas canvas, Size size) {
    double blockSize = size.width / tetromino.shape[0].length;
    final paint = Paint()..color = tetromino.color;

    for (int y = 0; y < tetromino.shape.length; y++) {
      for (int x = 0; x < tetromino.shape[y].length; x++) {
        if (tetromino.shape[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * blockSize, y * blockSize, blockSize, blockSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(TetrominoPainter oldDelegate) => false;
}
