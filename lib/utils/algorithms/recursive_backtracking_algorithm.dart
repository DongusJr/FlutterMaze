import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';

class StackState {
  int x;
  int y;
  List<int> directions;

  int popDirection() {
    int lastIndex = directions.length - 1;
    int returnValue = directions[lastIndex];
    directions.removeAt(lastIndex);
    return returnValue;
  }

  StackState(this.x, this.y, this.directions);
}

class RecursiveBacktrackingAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  Stack stack = Stack();

  RecursiveBacktrackingAlgorithm(maze) : super(maze);

  void step() {
    maze.changed = false;
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
    maze.currentX = rng.nextInt(maze.width - 1);
    maze.currentY = rng.nextInt(maze.height - 1);
    maze.mazeState = MazeState.running;
    stack.push(StackState(maze.currentX, maze.currentY, _randomDirections()));
  }

  void _runningStep() {
    while (maze.mazeState != MazeState.done) {
      StackState currentState = stack.top();
      if (currentState.directions.isEmpty) {
        stack.pop();
        if (stack.isEmpty) {
          maze.mazeState = MazeState.done;
          return;
        }
        continue;
      }
      int direction = currentState.popDirection();
      int newX = currentState.x + moveXMap[direction]!;
      int newY = currentState.y + moveYMap[direction]!;

      if (maze.isValid(newX, newY)) {
        if (maze.isBlank(newX, newY)) {
          stack.push(StackState(newX, newY, _randomDirections()));
          maze.markAt(currentState.x, currentState.y, direction);

          int oppDir = oppositeDirection[direction]!;
          maze.markAt(newX, newY, oppDir);
          maze.changed = true;
          return;
        }
      }
      if (currentState.directions.isEmpty) {
        maze.changed = true;
        stack.pop();
      }

      if (stack.isEmpty) {
        maze.mazeState = MazeState.done;
      }
    }
  }

  List<int> _randomDirections() {
    List<int> directions = [Direction.N, Direction.S, Direction.W, Direction.E];
    directions.shuffle(rng);
    return directions;
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }
}
