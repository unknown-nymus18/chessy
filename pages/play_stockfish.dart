import 'package:chessy/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chessy/engine/stock_fish_engine.dart';
import 'package:chessy/utils/profile_card.dart';

class PlayStockfish extends StatefulWidget {
  PlayerColor playerColor;
  PlayStockfish({super.key, required this.playerColor});

  @override
  State<PlayStockfish> createState() => _PlayStockfishState();
}

class _PlayStockfishState extends State<PlayStockfish> {
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
        getBestPosition();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void checkMate(BuildContext context) {
    print("checkmate");
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

  String _updateFenForPromotion(
    String fen,
    String from,
    String to,
    String promotionPiece,
  ) {
    List<String> fenParts = fen.split(' ');
    String board = fenParts[0];

    List<List<String>> boardArray =
        board.split('/').map((row) {
          return row.split('').expand((char) {
            if (RegExp(r'\d').hasMatch(char)) {
              return List.filled(int.parse(char), '1');
            } else {
              return [char];
            }
          }).toList();
        }).toList();

    int fromRow = 8 - int.parse(from[1]);
    int fromCol = from.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int toRow = 8 - int.parse(to[1]);
    int toCol = to.codeUnitAt(0) - 'a'.codeUnitAt(0);

    boardArray[fromRow][fromCol] = '1';
    boardArray[toRow][toCol] = promotionPiece;

    String newBoard = boardArray
        .map((row) {
          int emptyCount = 0;
          String newRow = '';
          for (String square in row) {
            if (square == '1') {
              emptyCount++;
            } else {
              if (emptyCount > 0) {
                newRow += emptyCount.toString();
                emptyCount = 0;
              }
              newRow += square;
            }
          }
          if (emptyCount > 0) {
            newRow += emptyCount.toString();
          }
          return newRow;
        })
        .join('/');

    fenParts[0] = newBoard;
    return fenParts.join(' ');
  }

  void getBestPosition() async {
    if (playerTurn()) {
      return;
    }

    arrows.clear();
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

          String? promotionPiece;
          if (bestMove.length == 5) {
            promotionPiece = bestMove[4];
          }

          if (promotionPiece != null) {
            String newFen = _updateFenForPromotion(
              controller.getFen(),
              from,
              to,
              promotionPiece,
            );
            if (mounted) {
              setState(() {
                controller.loadFen(newFen);
                addMove();
                controller.game.turn =
                    controller.game.turn == Color.WHITE
                        ? Color.BLACK
                        : Color.WHITE;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                controller.makeMove(from: from, to: to);
                addMove();
              });
            }
          }
        }
      }
    });
  }

  bool compTurn() {
    if (controller.game.turn == Color.WHITE &&
        widget.playerColor != PlayerColor.white) {
      Future.delayed(Duration(milliseconds: 900), () {
        getBestPosition();
      });
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
              image: "lib/assets/images/stockfish.jfif",
              capturedPieces:
                  getCapturedPieces(recordedMoves[_selectedIndex])['black'] ??
                  [],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.all(9),
              height: 40,
              child: ListView.builder(
                controller: scrollController,
                itemCount: listView.length, // Use listView length
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
                        getBestPosition();
                      }
                    });
                  }
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
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
