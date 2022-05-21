import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';

enum Orientation { vertical, horizontal }

class StackBoxState {
  int xStart;
  int xEnd;
  int yStart;
  int yEnd;

  StackBoxState(this.xStart, this.xEnd, this.yStart, this.yEnd);

  @override
  String toString() {
    return "x:(${this.xStart}, ${this.xEnd}), y:(${this.yStart}, ${this.yEnd})";
  }
}

class RecursiveDivisionAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  Stack boxStack = Stack();
  late StackBoxState nowBoxState;
  late int drawCoord;
  late Orientation orientation;

  RecursiveDivisionAlgorithm(maze) : super(maze);

  void _emptyCanvas() {
    for (var y = 0; y < maze.height; y++) {
      for (var x = 0; x < maze.width; x++) {
        if (y != 0) {
          maze.markAt(x, y, Direction.N);
        }
        if (y != maze.height - 1) {
          maze.markAt(x, y, Direction.S);
        }
        if (x != 0) {
          maze.markAt(x, y, Direction.W);
        }
        if (x != maze.width - 1) {
          maze.markAt(x, y, Direction.E);
        }
      }
    }
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
          _drawLineStep();
        }
        break;
      case MazeState.runningAlt:
        {
          _openPassageStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  void _drawVertLine(int x, int start, int stop) {
    if (x >= maze.width - 1 || x < 0) {
      return;
    }
    for (var y = start; y < stop; y++) {
      maze.unmarkAt(x, y, Direction.E);
      maze.unmarkAt(x + 1, y, Direction.W);
    }
  }

  void _drawHorzLine(int y, int start, int stop) {
    if (y >= maze.height - 1 || y < 0) {
      return;
    }
    for (var x = start; x < stop; x++) {
      maze.unmarkAt(x, y, Direction.S);
      maze.unmarkAt(x, y + 1, Direction.N);
    }
  }

  void _startStep() {
    boxStack.push(StackBoxState(0, maze.width - 1, 0, maze.height - 1));
    maze.mazeState = MazeState.running;
  }

  Orientation _getOrientation(width, height) {
    if (width > height) {
      return Orientation.vertical;
    } else if (height > width) {
      return Orientation.horizontal;
    } else {
      return rng.nextInt(2) == 0
          ? Orientation.horizontal
          : Orientation.vertical;
    }
  }

  int _randomInRange(int start, int stop) {
    return rng.nextInt(stop - start) + start;
  }

  void _drawLineStep() {
    maze.changed = true;
    if (boxStack.isEmpty) {
      maze.mazeState = MazeState.done;
    } else {
      nowBoxState = boxStack.pop();
      orientation = _getOrientation(nowBoxState.xEnd - nowBoxState.xStart,
          nowBoxState.yEnd - nowBoxState.yStart);
      drawCoord = orientation == Orientation.horizontal
          ? _randomInRange(nowBoxState.yStart, nowBoxState.yEnd)
          : _randomInRange(nowBoxState.xStart, nowBoxState.xEnd);

      if (orientation == Orientation.horizontal) {
        _drawHorzLine(drawCoord, nowBoxState.xStart, nowBoxState.xEnd + 1);
      } else {
        _drawVertLine(drawCoord, nowBoxState.yStart, nowBoxState.yEnd + 1);
      }

      if (orientation == Orientation.horizontal) {
        int topBoxSize = drawCoord - nowBoxState.yStart;
        int botBoxSize = nowBoxState.yEnd - drawCoord - 1;
        if (topBoxSize > 0) {
          boxStack.push(StackBoxState(
            nowBoxState.xStart,
            nowBoxState.xEnd,
            nowBoxState.yStart,
            nowBoxState.yStart + topBoxSize,
          ));
        }
        if (botBoxSize > 0) {
          boxStack.push(StackBoxState(
            nowBoxState.xStart,
            nowBoxState.xEnd,
            nowBoxState.yStart + topBoxSize + 1,
            nowBoxState.yEnd,
          ));
        }
      } else {
        int leftBoxSize = drawCoord - nowBoxState.xStart;
        int rightBoxSize = nowBoxState.xEnd - drawCoord - 1;
        if (leftBoxSize > 0) {
          boxStack.push(StackBoxState(
              nowBoxState.xStart,
              nowBoxState.xStart + leftBoxSize,
              nowBoxState.yStart,
              nowBoxState.yEnd));
        }
        if (rightBoxSize > 0) {
          boxStack.push(StackBoxState(
            nowBoxState.xStart + leftBoxSize + 1,
            nowBoxState.xEnd,
            nowBoxState.yStart,
            nowBoxState.yEnd,
          ));
        }
      }
      maze.mazeState = MazeState.runningAlt;
    }
  }

  void _openPassageStep() {
    maze.changed = true;
    if (orientation == Orientation.horizontal) {
      int pathX = rng.nextInt(nowBoxState.xEnd - nowBoxState.xStart + 1) +
          nowBoxState.xStart;
      maze.markAt(pathX, drawCoord, Direction.S);
      maze.markAt(pathX, drawCoord + 1, Direction.N);
    } else {
      int pathY = rng.nextInt(nowBoxState.yEnd - nowBoxState.yStart + 1) +
          nowBoxState.yStart;
      maze.markAt(drawCoord, pathY, Direction.E);
      maze.markAt(drawCoord + 1, pathY, Direction.W);
    }
    maze.mazeState = MazeState.running;
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }

  void reset() {
    _emptyCanvas();
  }
}
