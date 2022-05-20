import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

enum MazeOrientation { northWest, northEast, southWest, southEast }

class BinaryTreeAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  MazeOrientation orientation = MazeOrientation.northWest;
  late Function vertPredicate;
  late Function horzPredicate;
  late int vertDirection;
  late int horzDirection;
  late int vertStart;
  late int horzStart;
  late int vertIncrement;
  late int horzIncrement;

  BinaryTreeAlgorithm(maze) : super(maze);

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
          _runningStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  void _startStep() {
    if (orientation == MazeOrientation.northWest ||
        orientation == MazeOrientation.northEast) {
      vertStart = 0;
      vertIncrement = 1;
      vertPredicate = (y) => y > 0;
      vertDirection = Direction.N;
    } else {
      vertStart = maze.height - 1;
      vertIncrement = -1;
      vertPredicate = (y) => y < maze.height - 1;

      vertDirection = Direction.S;
    }
    if (orientation == MazeOrientation.northWest ||
        orientation == MazeOrientation.southWest) {
      horzStart = 0;
      horzIncrement = 1;
      horzPredicate = (x) => x > 0;
      horzDirection = Direction.W;
    } else {
      horzStart = maze.width - 1;
      horzIncrement = -1;
      horzPredicate = (x) => x < maze.width - 1;
      horzDirection = Direction.E;
    }

    maze.currentX = horzStart;
    maze.currentY = vertStart;
    maze.mazeState = MazeState.running;
  }

  void _runningStep() {
    List<int> directions = [];
    if (vertPredicate(maze.currentY)) {
      directions.add(vertDirection);
    }
    if (horzPredicate(maze.currentX)) {
      directions.add(horzDirection);
    }

    if (directions.isNotEmpty) {
      int randomDirection = directions[rng.nextInt(directions.length)];
      int newX = maze.currentX + moveXMap[randomDirection]!;
      int newY = maze.currentY + moveYMap[randomDirection]!;
      maze.markAt(maze.currentX, maze.currentY, randomDirection);
      maze.markAt(newX, newY, oppositeDirection[randomDirection]!);
    } else {
      maze.markAt(maze.currentX, maze.currentY, Direction.done);
    }

    maze.currentX += horzIncrement;
    if (!maze.isValid(maze.currentX, maze.currentY)) {
      maze.currentX = horzStart;
      maze.currentY += vertIncrement;
      if (!maze.isValid(maze.currentX, maze.currentY)) {
        maze.mazeState = MazeState.done;
        maze.currentX = -1;
        maze.currentY = -1;
      }
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
