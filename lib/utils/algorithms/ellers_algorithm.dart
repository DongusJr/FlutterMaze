import 'dart:math';

import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';


class RowState {
  Random rng;
  int nextId = 1;
  Map<int, int> setMap = <int, int>{};
  Set<int> oldRowIds = <int>{};
  int width;

  RowState(this.width, this.rng);

  void fillRow() {
    for (var x = 0; x < width; x++) {
      if (!setMap.containsKey(x)) {
        setMap[x] = nextId;
        nextId++;
      }
    }
  }

  void randomMergeRow() {
    for (var x = 0; x < width - 1; x++) {
      if (setMap[x] != setMap[x + 1] && (rng.nextInt(2) == 0)) {
        setMap[x + 1] = setMap[x]!;
      }
    }
  }

  void forceMergeRow() {
    for (var x = 0; x < width - 1; x++) {
      if (setMap[x] != setMap[x + 1]) {
        setMap[x + 1] = setMap[x]!;
      }
    }
  }

  bool goesEast(int x) {
    if (setMap.containsKey(x) && setMap.containsKey(x + 1)) {
      return setMap[x] == setMap[x + 1];
    }
    return false;
  }

  void nextRow() {
    Map<int, int> newSetMap = <int, int>{};
    Map<int, List<int>> setCells = <int, List<int>>{};
    oldRowIds = {};
    // See what cells are adjecent
    setMap.forEach((cell, setId) {
      if (setCells.containsKey(setId)) {
        setCells[setId]!.add(cell);
      } else {
        setCells[setId] = [cell];
      }
    });
    // Randomly select one adjecent cell to go vertical. Remember the old row ids
    setCells.forEach((setId, cellList) {
      int randomCell = cellList[rng.nextInt(cellList.length)];
      newSetMap[setId] = randomCell;
      oldRowIds.add(randomCell);
    });
    setMap = newSetMap;
  }

  bool goesNorth(int x) {
    return oldRowIds.contains(x);
  }
}

class EllersAlgorithm extends MazeAlgorithm {
  Random rng = Random();
  late RowState rowState;

  EllersAlgorithm(maze) : super(maze) {}

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
          _fillRowStep();
        }
        break;
      case MazeState.runningAlt:
        {
          _nextRowStep();
        }
        break;
      case MazeState.last:
        {
          _lastStep();
        }
        break;
      default:
        {}
        break;
    }
  }

  void _startStep() {
    maze.mazeState = MazeState.running;
    rowState = RowState(maze.width, rng);
    maze.mazeState = MazeState.running;
    maze.currentY = 0;
    _markHorizontal();
  }

  void _markHorizontal() {
    print("current Y in horizontal: ${maze.currentY}");
    for (var x = 0; x < maze.width - 1; x++) {
      if (rowState.goesEast(x)) {
        maze.markAt(x, maze.currentY, Direction.E);
        maze.markAt(x + 1, maze.currentY, Direction.W);
      } else {
        maze.markAt(x, maze.currentY, Direction.done);
        maze.markAt(x + 1, maze.currentY, Direction.done);
      }
    }
  }

  void _markVertical() {
    print("current Y in vertical: ${maze.currentY}");
    for (var x = 0; x < maze.width; x++) {
      if (rowState.goesNorth(x)) {
        maze.markAt(x, maze.currentY, Direction.N);
        maze.markAt(x, maze.currentY - 1, Direction.S);
      }
    }
  }

  void _fillRowStep() {
    rowState.fillRow();
    rowState.randomMergeRow();
    _markHorizontal();
    maze.mazeState = MazeState.runningAlt; // Go to next row Step
  }

  void _nextRowStep() {
    rowState.nextRow();
    maze.currentY++;
    _markVertical();
    if (maze.currentY < maze.height - 1) {
      maze.mazeState = MazeState.running; // FillRow Step
    } else {
      maze.mazeState = MazeState.last; // Final Step
    }
  }

  void _lastStep() {
    rowState.fillRow();
    rowState.forceMergeRow();
    _markHorizontal();
    maze.mazeState = MazeState.done; // Finish
  }

  void watch() {}

  void run() {
    while (maze.mazeState != MazeState.done) {
      step();
    }
  }

  void reset() {
    ;
  }
}
