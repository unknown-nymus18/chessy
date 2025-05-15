import 'package:chessy/engine/stock_fish_engine.dart';
import 'package:chessy/utils/functions.dart';
import 'package:chessy/utils/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class LocalGame extends StatefulWidget {
  const LocalGame({super.key});

  @override
  State<LocalGame> createState() => _LocalGameState();
}

class _LocalGameState extends State<LocalGame> {
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
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void checkMate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Checkmate"),
          content: Text("Game Over"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void staleMate(BuildContext context) {
    print("stalemate");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Stalemate"),
          content: Text("Game Over"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
        title: Text("C H E S S Y"),
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
            ProfileCard(
              player: false,
              capturedPieces:
                  getCapturedPieces(recordedMoves[_selectedIndex])['black'] ??
                  [],
              name: "Player 2",
            ),
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
                }
                if (controller.isCheckMate()) {
                  checkMate(context);
                }
                if (controller.isStaleMate()) {
                  staleMate(context);
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    print(listView);
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
            ProfileCard(
              player: true,
              capturedPieces:
                  getCapturedPieces(recordedMoves[_selectedIndex])['white'] ??
                  [],
              name: "PLAYER 1",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
