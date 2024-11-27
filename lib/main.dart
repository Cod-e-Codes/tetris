// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'game_controller.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Tetris',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'PressStart2P', // Custom font
        ),
        home: const TetrisGame(),
      ),
    );
  }
}
