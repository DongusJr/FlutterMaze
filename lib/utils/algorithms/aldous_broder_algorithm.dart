import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

class AldousBroderAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  late int remaining;

  AldousBroderAlgorithm(maze) : super(maze) {
    remaining = maze.width * maze.height;
  }

  void step() {
    switch (maze.mazeState) {
      case MazeState.start:
        {
          _startStep();
        }
        break;
      case MazeState.running:
        {
          _runningStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  void _startStep() {
    maze.changed = true;
    maze.currentX = rng.nextInt(maze.width);
    maze.currentY = rng.nextInt(maze.height);
    maze.mazeState = MazeState.running;
    remaining -= 1;
  }

  int _getRandomDirection(int x, int y) {
    List<int> directions = [];
    if (maze.isValid(x + 1, y)) {
      directions.add(Direction.E);
    }
    if (maze.isValid(x - 1, y)) {
      directions.add(Direction.W);
    }
    if (maze.isValid(x, y + 1)) {
      directions.add(Direction.S);
    }
    if (maze.isValid(x, y - 1)) {
      directions.add(Direction.N);
    }
    return directions[
        (directions.length > 1) ? rng.nextInt(directions.length) : 0];
  }

  void _runningStep() {
    maze.changed = true;
    if (remaining <= 0) {
      maze.mazeState = MazeState.done;
    } else {
      int randomDirection = _getRandomDirection(maze.currentX, maze.currentY);
      int newX = maze.currentX + moveXMap[randomDirection]!;
      int newY = maze.currentY + moveYMap[randomDirection]!;
      if (maze.isBlank(newX, newY)) {
        maze.markAt(maze.currentX, maze.currentY, randomDirection);
        maze.markAt(newX, newY, oppositeDirection[randomDirection]!);
        remaining -= 1;
      }
      maze.currentX = newX;
      maze.currentY = newY;
    }
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }

  void reset() {
    remaining = maze.width * maze.height;
  }
}
