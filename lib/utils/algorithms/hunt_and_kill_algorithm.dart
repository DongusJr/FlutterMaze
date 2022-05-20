import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

class HuntAndKillAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  int lastHuntRow = 0;
  int currentRow = 0;
  MazeState lastState = MazeState.start;

  HuntAndKillAlgorithm(maze) : super(maze);

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
          _huntStep();
        }
        break;
      case MazeState.runningAlt:
        {
          _killStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  List<int> _randomDirections() {
    List<int> directions = [Direction.N, Direction.S, Direction.W, Direction.E];
    directions.shuffle(rng);
    return directions;
  }

  void _startStep() {
    maze.currentX = rng.nextInt(maze.width);
    maze.currentY = rng.nextInt(maze.height);
    maze.mazeState = MazeState.running;
    lastState = MazeState.start;
    maze.changed = true;
  }

  void _huntStep() {
    if (lastState == MazeState.runningAlt) {
      for (var x = 0; x < maze.width; x++) {
        maze.unmarkAt(x, currentRow, Direction.visit);
      }
    }
    lastState = MazeState.running;
    maze.changed = true;
    List<int> randomDirections = _randomDirections();
    for (var direction in randomDirections) {
      int newX = maze.currentX + moveXMap[direction]!;
      int newY = maze.currentY + moveYMap[direction]!;
      if (maze.isValid(newX, newY) && maze.isBlank(newX, newY)) {
        maze.markAt(maze.currentX, maze.currentY, direction);
        maze.markAt(newX, newY, oppositeDirection[direction]!);
        maze.currentX = newX;
        maze.currentY = newY;
        return;
      }
    }
    maze.mazeState = MazeState.runningAlt;
    maze.currentX = -1;
    maze.currentY = -1;
  }

  bool _rowIsFinished() {
    for (var x = 0; x < maze.width; x++) {
      if (!maze.hasDir(x, lastHuntRow)) {
        return false;
      }
    }
    return true;
  }

  Tuple3? _kill(int x, int y) {
    if (!maze.isBlank(x, y)) {
      return null;
    }
    if (maze.isValid(x + 1, y)) {
      if (maze.hasDir(x + 1, y)) {
        return Tuple3(x, y, Direction.E);
      }
    }
    if (maze.isValid(x - 1, y)) {
      if (maze.hasDir(x - 1, y)) {
        return Tuple3(x, y, Direction.W);
      }
    }
    if (maze.isValid(x, y + 1)) {
      if (maze.hasDir(x, y + 1)) {
        return Tuple3(x, y, Direction.S);
      }
    }
    if (maze.isValid(x, y - 1)) {
      if (maze.hasDir(x, y - 1)) {
        return Tuple3(x, y, Direction.N);
      }
    }
    return null;
  }

  void _killStep() {
    maze.changed = true;
    if (lastState == MazeState.runningAlt) {
      for (var x = 0; x < maze.width; x++) {
        maze.unmarkAt(x, currentRow, Direction.visit);
      }
      currentRow += 1;
    } else {
      currentRow = lastHuntRow;
    }
    if (lastHuntRow < maze.height) {
      Tuple3? newTarget;

      for (var x = 0; x < maze.width; x++) {
        newTarget ??= _kill(x, currentRow);
        maze.markAt(x, currentRow, Direction.visit);
      }
      if (newTarget != null) {
        maze.currentX = newTarget.item1!;
        maze.currentY = newTarget.item2!;
        int direction = newTarget.item3!;
        int newX = maze.currentX + moveXMap[direction]!;
        int newY = maze.currentY + moveYMap[direction]!;
        maze.markAt(maze.currentX, maze.currentY, direction);
        maze.markAt(newX, newY, oppositeDirection[direction]!);
        maze.mazeState = MazeState.running;
      } else {
        if (_rowIsFinished()) {
          lastHuntRow += 1;
        }
      }
    } else {
      maze.currentX = -1;
      maze.currentY = -1;
      maze.mazeState = MazeState.done;
    }
    lastState = MazeState.runningAlt;
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }
}
