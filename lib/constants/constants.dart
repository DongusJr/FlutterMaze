import 'package:flutter/cupertino.dart';
import 'package:validators/validators.dart';

enum MazeState { start, running, runningAlt, last, done }

enum MazeAlgorithmEnum {
  recursiveBacktrackingAlgorithm,
  kruskalsAlgorithm,
  primsAlgorithm,
  aldousBroderAlgorithm,
  wilsonsAlgorithm,
  huntAndKillAlgorithm,
  binaryTreeAlgorithm,
  sidewinderAlgorithm,
  ellersAlgorithm
}

String getEnumTitle(MazeAlgorithmEnum algorithmEnum) {
  String titleString = "";
  bool first = true;
  algorithmEnum.name.runes.forEach((int rune) {
    var char = String.fromCharCode(rune);
    if (first) {
      titleString += char.toUpperCase();
      first = false;
    } else {
      if (isUppercase(char)) {
        titleString += " " + char;
      } else {
        titleString += char;
      }
    }
  });
  return titleString;
}

class Direction {
  static const N = 1;
  static const S = 2;
  static const W = 4;
  static const E = 8;
  static const visit = 16;
  static const done = 32;
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
