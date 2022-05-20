import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

class SidewinderAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  late int runStart;

  SidewinderAlgorithm(maze) : super(maze);

  void step() {
    maze.changed = true;
    switch (maze.mazeState) {
      case MazeState.start:
        {
          _startStep();
        }
        break;
      case MazeState.running:
        {
          _runningCellStep();
        }
        break;
      case MazeState.runningAlt:
        {
          _carveNorthStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  void _startStep() {
    runStart = 0;
    maze.currentX = 0;
    maze.currentY = 0;
    maze.mazeState = MazeState.running;
  }

  void _runningCellStep() {
    maze.markAt(maze.currentX, maze.currentY, Direction.visit);
    if ((maze.currentY > 0) &&
        (maze.currentX == maze.width - 1 || rng.nextInt(3) == 0)) {
      maze.mazeState = MazeState.runningAlt;
    } else if (maze.currentX < maze.width - 1) {
      maze.markAt(maze.currentX, maze.currentY, Direction.E);
      maze.currentX += 1;
      maze.markAt(maze.currentX, maze.currentY, Direction.W);
    } else {
      for (var x = runStart; x < maze.currentX + 1; x++) {
        maze.unmarkAt(x, maze.currentY, Direction.visit);
      }
      maze.currentY += 1;
      maze.currentX = 0;
    }
  }

  void _carveNorthStep() {
    for (var x = runStart; x <= maze.currentX; x++) {
      maze.unmarkAt(x, maze.currentY, Direction.visit);
    }
    int randomCellX = runStart + rng.nextInt(maze.currentX - runStart + 1);
    maze.markAt(randomCellX, maze.currentY, Direction.N);
    maze.markAt(randomCellX, maze.currentY - 1, Direction.S);
    if (maze.currentX >= maze.width - 1) {
      runStart = 0;
      maze.currentX = 0;
      maze.currentY += 1;
    } else {
      runStart = maze.currentX + 1;
      maze.currentX += 1;
    }

    maze.mazeState = MazeState.running;
    if (maze.currentY >= maze.height) {
      maze.mazeState = MazeState.done;
    }
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }

  void reset() {
    return;
  }
}
