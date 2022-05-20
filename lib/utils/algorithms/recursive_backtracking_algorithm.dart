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
    maze.currentX = rng.nextInt(maze.width);
    maze.currentY = rng.nextInt(maze.height);
    maze.mazeState = MazeState.running;
    stack.push(StackState(maze.currentX, maze.currentY, _randomDirections()));
  }

  void _runningStep() {
    while (maze.mazeState != MazeState.done) {
      if (stack.isEmpty) {
        maze.changed = true;
        maze.mazeState = MazeState.done;
        return;
      }

      StackState currentState = stack.top();
      maze.currentX = currentState.x;
      maze.currentY = currentState.y;

      if (currentState.directions.isEmpty) {
        maze.changed = true;
        StackState lastState = stack.pop();
        maze.unmarkAt(lastState.x, lastState.y, Direction.visit);
        return;
      }

      int direction = currentState.popDirection();
      int newX = currentState.x + moveXMap[direction]!;
      int newY = currentState.y + moveYMap[direction]!;

      if (maze.isValid(newX, newY)) {
        if (maze.isBlank(newX, newY)) {
          stack.push(StackState(newX, newY, _randomDirections()));
          maze.markAt(
              maze.currentX, maze.currentY, direction | Direction.visit);

          int oppDir = oppositeDirection[direction]!;
          maze.markAt(newX, newY, oppDir);
          maze.currentX = newX;
          maze.currentY = newY;
          maze.changed = true;
          return;
        }
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

  void reset() {
    return;
  }
}
