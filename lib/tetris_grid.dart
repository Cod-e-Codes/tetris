import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class TetrisGrid extends StatelessWidget {
  const TetrisGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = gameState.columns;
        int rows = gameState.rows;

        double cellSizeWidth = constraints.maxWidth / columns;
        double cellSizeHeight = constraints.maxHeight / rows;
        double cellSize = min(cellSizeWidth, cellSizeHeight);

        return SizedBox(
          width: cellSize * columns,
          height: cellSize * rows,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                gameState.movePieceRight();
              } else if (details.delta.dx < 0) {
                gameState.movePieceLeft();
              }
            },
            onTap: () {
              gameState.rotatePiece();
            },
            onVerticalDragEnd: (details) {
              gameState.dropPiece();
            },
            child: Column(
              children: List.generate(rows, (y) {
                return Row(
                  children: List.generate(columns, (x) {
                    Color color = gameState.grid[y][x];

                    // Overlay the shadow position
                    List<Point<int>> shadowBlocks = gameState.getShadowPosition();
                    if (shadowBlocks.any((point) => point.x == x && point.y == y)) {
                      color = gameState.currentPiece!.color.withOpacity(0.3);
                    }

                    // Overlay the current moving piece
                    if (gameState.currentPiece != null) {
                      for (int py = 0; py < gameState.currentPiece!.shape.length; py++) {
                        for (int px = 0; px < gameState.currentPiece!.shape[py].length; px++) {
                          if (gameState.currentPiece!.shape[py][px] == 1) {
                            int pieceX = gameState.currentX + px;
                            int pieceY = gameState.currentY + py;
                            if (pieceX == x && pieceY == y) {
                              color = gameState.currentPiece!.color;
                            }
                          }
                        }
                      }
                    }

                    // Subtle grid borders with a light color
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2), // Subtle border
                          width: 0.5, // Thin border for grid lines
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          if (color != Colors.transparent)
                            const BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 2,
                            ),
                        ],
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
