import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/algorithms/recursive_backtracking_algorithm.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';

class Maze {
  int width;
  int height;
  late int currentX = 0;
  late int currentY = 0;
  Enum mazeState = MazeState.start;
  late MazeAlgorithm algorithm;
  late List<List<int>> grid;
  bool changed = true;

  Maze(this.width, this.height, Enum algorithmToUse) {
    grid = List.generate(height, (i) => List.filled(width, 0), growable: false);
    switch (algorithmToUse) {
      case MazeAlgorithmEnum.recursiveBacktrackingAlgorithm:
        {
          algorithm = RecursiveBacktrackingAlgorithm(this);
        }
    }
  }

  void run() {
    algorithm.run();
  }

  void step() {
    algorithm.step();
  }

  bool isValid(int x, int y) {
    return (0 <= x && x < width) && ((0 <= y) && (y < height));
  }

  // Grid Functions
  int valAt(int x, int y) => grid[y][x];
  int markAt(int x, int y, int direction) => grid[y][x] |= direction;
  bool isBlank(int x, int y) => grid[y][x] == 0;
  bool goesDir(int x, int y, int direction) => grid[y][x] & direction != 0;
}

void main() {
  Maze maze = Maze(10, 10, MazeAlgorithmEnum.recursiveBacktrackingAlgorithm);
  print(maze.grid);
}