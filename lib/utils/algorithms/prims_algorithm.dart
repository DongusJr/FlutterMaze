import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

class PrimsAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  List<Tuple2> undoneCells = [];

  PrimsAlgorithm(maze) : super(maze);

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

  void _tryToAddUndone(int x, int y) {
    if (maze.isValid(x, y) && maze.isBlank(x, y)) {
      maze.markAt(x, y, Direction.visit);
      undoneCells.add(Tuple2(x, y));
    }
  }

  void _addUndoneCells() {
    int x = maze.currentX, y = maze.currentY;
    _tryToAddUndone(x + 1, y);
    _tryToAddUndone(x - 1, y);
    _tryToAddUndone(x, y + 1);
    _tryToAddUndone(x, y - 1);
  }

  Tuple2 getRandomNeighbourgh(int x, int y) {
    List<Tuple2> neighbours = [];
    if (x > 0 && maze.goesDir(x - 1, y, Direction.done)) {
      neighbours.add(Tuple2(x - 1, y));
    }
    if (x < maze.width - 1 && maze.goesDir(x + 1, y, Direction.done)) {
      neighbours.add(Tuple2(x + 1, y));
    }
    if (y > 0 && maze.goesDir(x, y - 1, Direction.done)) {
      neighbours.add(Tuple2(x, y - 1));
    }
    if (y < maze.height - 1 && maze.goesDir(x, y + 1, Direction.done)) {
      neighbours.add(Tuple2(x, y + 1));
    }
    return neighbours[
        (neighbours.length > 1) ? rng.nextInt(neighbours.length) : 0];
  }

  Tuple2 popRandomCell() {
    return undoneCells
        .removeAt(undoneCells.length > 1 ? rng.nextInt(undoneCells.length) : 0);
  }

  void _startStep() {
    maze.changed = true;
    maze.currentX = rng.nextInt(maze.width);
    maze.currentY = rng.nextInt(maze.height);
    _addUndoneCells();
    maze.markAt(maze.currentX, maze.currentY, Direction.done);
    maze.mazeState = MazeState.running;
  }

  void _runningStep() {
    maze.changed = true;
    if (undoneCells.isEmpty) {
      maze.unmarkAt(maze.currentX, maze.currentY, Direction.visit);
      maze.mazeState = MazeState.done;
    } else {
      Tuple2 randomCell = popRandomCell();
      int x = randomCell.item1, y = randomCell.item2;
      Tuple2 neighbour = getRandomNeighbourgh(x, y);
      int nx = neighbour.item1, ny = neighbour.item2;
      int direction = maze.getDirection(x, y, nx, ny);
      maze.markAt(x, y, direction | Direction.done);
      maze.markAt(nx, ny, oppositeDirection[direction]!);
      maze.unmarkAt(x, y, Direction.visit);
      maze.currentX = x;
      maze.currentY = y;
      _addUndoneCells();
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
