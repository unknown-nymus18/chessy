import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chessy/engine/stock_fish_engine.dart';
import 'package:chessy/utils/profile_card.dart';

class TrainingPage extends StatefulWidget {
  PlayerColor playerColor;
  TrainingPage({super.key, required this.playerColor});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  ChessBoardController controller = ChessBoardController();
  ScrollController scrollController = ScrollController();
  final stockFish = StockFishEngine.instance;
  int _selectedIndex = 0;

  List<String> recordedMoves = [];
  List<BoardArrow> arrows = [];
  List<String> listView = [];

  @override
  void initState() {
    super.initState();
    recordedMoves.add(controller.getFen());
    if (compTurn()) {
      Future.delayed(Duration(milliseconds: 1000), () {
        getBestMoveForStockfish();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void getBestMoveForPlayer() async {
    if (!playerTurn()) {
      return;
    }

    stockFish.stdin = 'isready\n';
    stockFish.stdin = 'position fen ${controller.getFen()}\n';
    stockFish.stdin = 'go depth 8\n';
    stockFish.stdout.listen((data) {
      if (data.contains("bestmove")) {
        final match = RegExp(
          r'bestmove\s([a-h][1-8][a-h][1-8][qrbn]?)',
        ).firstMatch(data);
        if (match != null) {
          String bestMove = match.group(1)!;
          String from = bestMove.substring(0, 2);
          String to = bestMove.substring(2, 4);

          setState(() {
            arrows = [BoardArrow(from: from, to: to, color: Colors.blue)];
          });
        }
      }
    });
  }

  void getBestMoveForStockfish() async {
    if (playerTurn()) {
      return;
    }

    stockFish.stdin = 'isready\n';
    stockFish.stdin = 'position fen ${controller.getFen()}\n';
    stockFish.stdin = 'go depth 8\n';
    stockFish.stdout.listen((data) {
      if (data.contains("bestmove")) {
        final match = RegExp(
          r'bestmove\s([a-h][1-8][a-h][1-8][qrbn]?)',
        ).firstMatch(data);
        if (match != null) {
          String bestMove = match.group(1)!;
          String from = bestMove.substring(0, 2);
          String to = bestMove.substring(2, 4);

          setState(() {
            controller.makeMove(from: from, to: to);
            addMove();
          });

          if (playerTurn()) {
            getBestMoveForPlayer();
          }
        }
      }
    });
  }

  bool compTurn() {
    if (controller.game.turn == Color.WHITE &&
        widget.playerColor != PlayerColor.white) {
      return true;
    } else if (controller.game.turn == Color.BLACK &&
        widget.playerColor != PlayerColor.black) {
      return true;
    }
    return false;
  }

  bool playerTurn() {
    if (controller.game.turn == Color.WHITE &&
        widget.playerColor == PlayerColor.white) {
      return true;
    }
    if (controller.game.turn == Color.BLACK &&
        widget.playerColor == PlayerColor.black) {
      return true;
    }
    return false;
  }

  void animateToEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  void addMove() {
    if (_selectedIndex == recordedMoves.length - 1 &&
        !recordedMoves.contains(controller.getFen())) {
      recordedMoves.add(controller.getFen());
      _selectedIndex = recordedMoves.length - 1;

      if (controller.game.history.isNotEmpty) {
        final lastMove = controller.game.history.last.move;
        if (lastMove != null) {
          listView.add("${lastMove.fromAlgebraic}->${lastMove.toAlgebraic}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("T R A I N I N G"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ProfileCard(player: false, image: "assets/images/stockfish.jfif"),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.all(9),
              height: 40,
              child: ListView.builder(
                controller: scrollController,
                itemCount: listView.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  return Text(listView[i]);
                },
              ),
            ),
            ChessBoard(
              controller: controller,
              boardColor: BoardColor.green,
              boardOrientation: widget.playerColor,
              arrows: arrows,
              enableUserMoves: _selectedIndex == recordedMoves.length - 1,
              onMove: () {
                if (_selectedIndex == recordedMoves.length - 1) {
                  setState(() {
                    if (scrollController.hasClients) {
                      animateToEnd();
                    }
                  });
                  addMove();
                  if (compTurn()) {
                    Future.delayed(Duration(milliseconds: 900), () {
                      if (mounted) {
                        getBestMoveForStockfish();
                      }
                    });
                  }
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    if (_selectedIndex > 0) {
                      setState(() {
                        _selectedIndex--;
                        controller.loadFen(recordedMoves[_selectedIndex]);
                      });
                    }
                  },
                  color: Colors.green,
                  child: Icon(Icons.arrow_back_ios_new),
                ),
                SizedBox(width: 20),
                MaterialButton(
                  onPressed: () {
                    if (_selectedIndex < recordedMoves.length - 1) {
                      setState(() {
                        _selectedIndex++;
                        controller.loadFen(recordedMoves[_selectedIndex]);
                      });
                    }
                  },
                  color: Colors.green,
                  child: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            // ProfileCard(player: true),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
