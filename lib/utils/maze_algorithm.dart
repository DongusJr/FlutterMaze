import 'package:flutter_maze/utils/maze.dart';

abstract class MazeAlgorithm {
  late Maze maze;

  MazeAlgorithm(this.maze);

  void step();
  void watch();
  void run();
}
