import 'package:flutter/cupertino.dart';

enum MazeState { start, running, done }

enum MazeAlgorithmEnum { recursiveBacktrackingAlgorithm }

class Direction {
  static const N = 1;
  static const S = 2;
  static const W = 4;
  static const E = 8;
}

const oppositeDirection = {
  Direction.N: Direction.S,
  Direction.S: Direction.N,
  Direction.W: Direction.E,
  Direction.E: Direction.W
};

const moveXMap = {
  Direction.N: 0,
  Direction.S: 0,
  Direction.W: -1,
  Direction.E: 1
};

const moveYMap = {
  Direction.N: -1,
  Direction.S: 1,
  Direction.W: 0,
  Direction.E: 0
};
