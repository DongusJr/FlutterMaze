import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

class WilsonsAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  late Map<Tuple2, int> walkingPath;
  late Set<Tuple2> remainingSet;
  Tuple2? walkingCell;

  WilsonsAlgorithm(maze) : super(maze) {
    walkingPath = <Tuple2, int>{};
    remainingSet = <Tuple2>{};
    for (var x = 0; x < maze.width; x++) {
      for (var y = 0; y < maze.height; y++) {
        remainingSet.add(Tuple2(x, y));
      }
    }
  }

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
          _walkingStep();
        }
        break;
      case MazeState.runningAlt:
        {
          _sweepingStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  Tuple2 _getRandomFromSet() {
    return remainingSet.elementAt(rng.nextInt(remainingSet.length));
  }

  int _getRandomDirection(int x, int y) {
    List<int> directions = [];
    if (maze.isValid(x, y - 1)) {
      directions.add(Direction.N);
    }
    if (maze.isValid(x, y + 1)) {
      directions.add(Direction.S);
    }
    if (maze.isValid(x - 1, y)) {
      directions.add(Direction.W);
    }
    if (maze.isValid(x + 1, y)) {
      directions.add(Direction.E);
    }
    return directions[rng.nextInt(directions.length)];
  }

  void _startStep() {
    maze.currentX = rng.nextInt(maze.width);
    maze.currentY = rng.nextInt(maze.height);
    maze.markAt(maze.currentX, maze.currentY, Direction.done);
    maze.mazeState = MazeState.running;
    remainingSet.remove(Tuple2(maze.currentX, maze.currentY));
  }

  void _walkingStep() {
    if (remainingSet.isEmpty) {
      maze.mazeState = MazeState.done;
    } else if (walkingCell == null) {
      Tuple2 randomCoords = _getRandomFromSet();
      maze.currentX = randomCoords.item1;
      maze.currentY = randomCoords.item2;
      walkingCell = randomCoords;
    } else {
      int randomDirection = _getRandomDirection(maze.currentX, maze.currentY);
      int newX = maze.currentX + moveXMap[randomDirection]!;
      int newY = maze.currentY + moveYMap[randomDirection]!;
      maze.markAt(maze.currentX, maze.currentY, Direction.visit);
      walkingPath[Tuple2(maze.currentX, maze.currentY)] = randomDirection;
      maze.currentX = newX;
      maze.currentY = newY;
      if (maze.goesDir(newX, newY, Direction.done)) {
        maze.mazeState = MazeState.runningAlt;
      }
    }
  }

  void _sweepingStep() {
    // print(walkingPath);
    int direction = walkingPath[walkingCell]!;
    maze.currentX = walkingCell!.item1;
    maze.currentY = walkingCell!.item2;
    maze.markAt(maze.currentX, maze.currentY, direction | Direction.done);
    maze.unmarkAt(maze.currentX, maze.currentY, Direction.visit);
    walkingPath.remove(walkingCell!);
    remainingSet.remove(walkingCell);

    int newX = maze.currentX + moveXMap[direction]!;
    int newY = maze.currentY + moveYMap[direction]!;
    maze.markAt(newX, newY, oppositeDirection[direction]!);
    Tuple2 newWalkingCell = Tuple2(newX, newY);

    if (walkingPath.containsKey(newWalkingCell)) {
      walkingCell = newWalkingCell;
    } else {
      maze.mazeState = MazeState.running;
      for (var k in walkingPath.keys) {
        maze.unmarkAt(k.item1, k.item2, Direction.visit);
      }
      walkingPath = Map<Tuple2, int>();
      walkingCell = null;
    }
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }
}
