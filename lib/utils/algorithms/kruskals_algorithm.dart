import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

class Tree {
  Tree? parent;

  Tree root() {
    return (parent != null) ? parent!.root() : this;
  }

  bool isConnected(Tree tree) {
    return tree.root() == root();
  }

  void connect(Tree tree) {
    tree.root().parent = this;
  }
}

class KruskalsAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  List<Tuple3> edges = [];
  List<List<Tree>> sets = [];
  Tuple4? lastMarked;

  KruskalsAlgorithm(maze) : super(maze) {
    edges = [];
    for (var x = 0; x < maze.width; x++) {
      for (var y = 0; y < maze.height; y++) {
        if (x > 0) {
          edges.add(Tuple3(x, y, Direction.W));
        }
        if (y > 0) {
          edges.add(Tuple3(x, y, Direction.N));
        }
      }
    }
    edges.shuffle(rng);
    sets = List.generate(
        maze.height, (_) => List.generate(maze.width, (_) => Tree()));
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
    maze.mazeState = MazeState.running;
    _runningStep();
  }

  void _runningStep() {
    unmarkLast();
    while (true) {
      if (edges.isEmpty) {
        maze.changed = true;
        maze.mazeState = MazeState.done;
        return;
      }
      Tuple3 edge = edges.removeAt(edges.length - 1);
      int currentX = edge.item1, currentY = edge.item2, direction = edge.item3;
      int newX = currentX + moveXMap[direction]!;
      int newY = currentY + moveYMap[direction]!;
      Tree currentTree = sets[currentY][currentX];
      Tree newTree = sets[newY][newX];
      bool isConnected = currentTree.isConnected(newTree);
      if (!isConnected) {
        maze.changed = true;
        currentTree.connect(newTree);
        maze.markAt(currentX, currentY, direction | Direction.visit);
        maze.markAt(
            newX, newY, oppositeDirection[direction]! | Direction.visit);
        lastMarked = Tuple4(currentX, currentY, newX, newY);
        return;
      }
    }
  }

  void unmarkLast() {
    if (lastMarked != null) {
      int firstX = lastMarked!.item1, firstY = lastMarked!.item2;
      int secondX = lastMarked!.item3, secondY = lastMarked!.item4;
      maze.unmarkAt(firstX, firstY, Direction.visit);
      maze.unmarkAt(secondX, secondY, Direction.visit);
    }
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }
}
