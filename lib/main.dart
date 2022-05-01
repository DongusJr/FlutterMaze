import 'package:flutter/material.dart';
import 'package:flutter_maze/constants/constants.dart';
import 'package:flutter_maze/utils/maze.dart';
import 'package:flutter_maze/utils/maze_algorithm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maze',
      theme: ThemeData(canvasColor: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Maze maze = Maze(20, 20, MazeAlgorithmEnum.recursiveBacktrackingAlgorithm);
  MazeAlgorithmEnum algorithmEnum =
      MazeAlgorithmEnum.recursiveBacktrackingAlgorithm;

  @override
  void initState() {}

  void runMaze() async {
    while (maze.mazeState != MazeState.done) {
      setState(() {
        maze.step();
      });
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(getEnumTitle(algorithmEnum),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 48)),
            Container(
              width: MediaQuery.of(context).size.height * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              color: Colors.white,
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: CustomPaint(
                    painter: MazePainter(maze),
                    willChange: true,
                  )),
            ),
            functionButton("Run", runMaze),
            Wrap(
              children: [
                algorithmButton(
                    MazeAlgorithmEnum.recursiveBacktrackingAlgorithm)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget functionButton(String buttonText, Function onPressedFunction) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.white),
      onPressed: () => onPressedFunction(),
      child: Text(buttonText, style: const TextStyle(color: Colors.blue)),
    );
  }

  ElevatedButton algorithmButton(MazeAlgorithmEnum newAlgorithmEnum) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.white),
      onPressed: () => {
        setState(() {
          algorithmEnum = newAlgorithmEnum;
        })
      },
      child: Text(getEnumTitle(newAlgorithmEnum),
          style: const TextStyle(color: Colors.blue)),
    );
  }
}

class MazePainter extends CustomPainter {
  final Maze maze;
  final double strokeWidth = 4.0;

  MazePainter(this.maze);

  @override
  void paint(Canvas canvas, Size size) {
    int mazeWidth = maze.width;
    int mazeHeight = maze.height;
    double boxWidth = (size.width / mazeWidth) + strokeWidth;
    double boxHeight = (size.height / mazeHeight) + strokeWidth;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;

    for (var x = 0; x < mazeWidth; x++) {
      for (var y = 0; y < mazeHeight; y++) {
        paint.color = maze.isAt(x, y) && maze.mazeState == MazeState.running
            ? Colors.green
            : (maze.goesDir(x, y, Direction.visit))
                ? Colors.red.shade200
                : Colors.white;
        BorderSide borderSide = const BorderSide(width: 4, color: Colors.black);
        Rect rect = Rect.fromLTWH((boxWidth - strokeWidth) * x,
            (boxHeight - strokeWidth) * y, boxWidth, boxHeight);
        canvas.drawRect(rect, paint);
        paintBorder(canvas, rect,
            top: maze.goesDir(x, y, Direction.N) ? BorderSide.none : borderSide,
            bottom:
                maze.goesDir(x, y, Direction.S) ? BorderSide.none : borderSide,
            left:
                maze.goesDir(x, y, Direction.W) ? BorderSide.none : borderSide,
            right:
                maze.goesDir(x, y, Direction.E) ? BorderSide.none : borderSide);
      }
    }
  }

  @override
  shouldRepaint(MazePainter oldDelegate) => maze.changed;
}
