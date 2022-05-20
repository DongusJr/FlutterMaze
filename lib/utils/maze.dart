import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/algorithms/Kruskals_algorithm.dart';
import 'package:flutter_maze/utils/algorithms/aldous_broder_algorithm.dart';
import 'package:flutter_maze/utils/algorithms/binary_tree_algorithm.dart';
import 'package:flutter_maze/utils/algorithms/hunt_and_kill_algorithm.dart';
import 'package:flutter_maze/utils/algorithms/prims_algorithm.dart';
import 'package:flutter_maze/utils/algorithms/recursive_backtracking_algorithm.dart';
import 'package:flutter_maze/utils/algorithms/wilsons_algorithm.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';

class Maze {
  int width;
  int height;
  int currentX = -1;
  int currentY = -1;
  Enum mazeState = MazeState.start;
  late MazeAlgorithm algorithm;
  late List<List<int>> grid;
  bool changed = true;

  Maze(this.width, this.height, Enum algorithmEnum) {
    grid = List.generate(height, (i) => List.filled(width, 0), growable: false);
    algorithmToUse = algorithmEnum;
  }

  set algorithmToUse(Enum algorithmToUse) {
    switch (algorithmToUse) {
      case MazeAlgorithmEnum.recursiveBacktrackingAlgorithm:
        algorithm = RecursiveBacktrackingAlgorithm(this);
        break;
      case MazeAlgorithmEnum.kruskalsAlgorithm:
        algorithm = KruskalsAlgorithm(this);
        break;
      case MazeAlgorithmEnum.primsAlgorithm:
        algorithm = PrimsAlgorithm(this);
        break;
      case MazeAlgorithmEnum.aldousBroderAlgorithm:
        algorithm = AldousBroderAlgorithm(this);
        break;
      case MazeAlgorithmEnum.wilsonsAlgorithm:
        algorithm = WilsonsAlgorithm(this);
        break;
      case MazeAlgorithmEnum.huntAndKillAlgorithm:
        algorithm = HuntAndKillAlgorithm(this);
        break;
      case MazeAlgorithmEnum.binaryTreeAlgorithm:
        algorithm = BinaryTreeAlgorithm(this);
        break;
    }
  }

  void run() {
    algorithm.run();
  }

  void step() {
    changed = false;
    algorithm.step();
  }

  void reset() {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < width; y++) {
        grid[y][x] = 0;
      }
    }
    mazeState = MazeState.start;
    changed = true;
    currentX = -1;
    currentY = -1;
    algorithm.reset();
  }

  bool isValid(int x, int y) {
    return (0 <= x && x < width) && ((0 <= y) && (y < height));
  }

  bool isAt(int x, int y) {
    return x == currentX && y == currentY;
  }

  int getDirection(int fromX, int fromY, int toX, int toY) {
    if (fromX > toX) {
      return Direction.W;
    } else if (fromX < toX) {
      return Direction.E;
    } else if (fromY > toY) {
      return Direction.N;
    } else if (fromY < toY) {
      return Direction.S;
    } else {
      return -1;
    }
  }

  // Grid Functions
  int valAt(int x, int y) => grid[y][x];
  int markAt(int x, int y, int direction) => grid[y][x] |= direction;
  int unmarkAt(int x, int y, int direction) => grid[y][x] &= ~direction;
  bool hasDir(int x, int y) => grid[y][x] & 15 != 0;
  bool isBlank(int x, int y) => grid[y][x] == 0;
  bool goesDir(int x, int y, int direction) => grid[y][x] & direction != 0;
}

void main() {
  Maze maze = Maze(10, 10, MazeAlgorithmEnum.recursiveBacktrackingAlgorithm);
  print(maze.grid);
}
