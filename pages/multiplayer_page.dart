import 'package:chessy/services/database.dart';
import 'package:chessy/utils/functions.dart';
import 'package:chessy/utils/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chessy/services/audio_services.dart';

class MultiplayerPage extends StatefulWidget {
  String gameId;
  final String opponentName;
  MultiplayerPage({
    super.key,
    required this.opponentName,
    required this.gameId,
  });

  @override
  State<MultiplayerPage> createState() => _MultiplayerState();
}

class _MultiplayerState extends State<MultiplayerPage> {
  ChessBoardController controller = ChessBoardController();
  ScrollController scrollController = ScrollController();
  AudioServices audioServices = AudioServices(); // Initialize AudioServices
  int _selectedIndex = 0;
  Database db = Database();
  bool _gameOverDialogShown = false;
  PlayerColor? playerColor; // Nullable until fetched
  List<String> recordedMoves = [
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  ]; // Starting FEN
  List<BoardArrow> arrows = [];
  List<String> listView = [];

  @override
  void initState() {
    super.initState();
    fetchPlayerColor();
    db.getMovesStream(widget.gameId).listen((moves) {
      setState(() {
        recordedMoves = moves.isEmpty ? recordedMoves : moves;
        _selectedIndex = recordedMoves.length - 1;
        controller.loadFen(recordedMoves[_selectedIndex]);
        audioServices.playSound('lib/assets/sounds/move-piece.mp3');

        if (controller.game.game_over) {
          showGameOverDialog();
        }
      });
    });
  }

  void fetchPlayerColor() async {
    final color = await db.getPlayerColor(widget.gameId);
    setState(() {
      playerColor = color == 'white' ? PlayerColor.white : PlayerColor.black;
    });
  }

  void showGameOverDialog() {
    if (_gameOverDialogShown) return;
    _gameOverDialogShown = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("The game has ended."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  bool playerTurn() {
    if (playerColor == null) return false;
    if (controller.game.turn == Color.WHITE &&
        playerColor == PlayerColor.white) {
      return true;
    }
    if (controller.game.turn == Color.BLACK &&
        playerColor == PlayerColor.black) {
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

  @override
  Widget build(BuildContext context) {
    if (playerColor == null) {
      return Scaffold(
        appBar: AppBar(title: Text("C H E S S Y"), centerTitle: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
              name: widget.opponentName,
              player: false,
              capturedPieces:
                  getCapturedPieces(
                    recordedMoves[_selectedIndex],
                  )[playerColor == PlayerColor.black ? 'white' : 'black'] ??
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
                  return Text(
                    "${listView[i]} ",
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          i % 2 == 0
                              ? Colors.green
                              : Colors.blue, // Alternate colors for moves
                    ),
                  );
                },
              ),
            ),
            ChessBoard(
              controller: controller,
              boardColor: BoardColor.green,
              boardOrientation: playerColor!,
              arrows: arrows,
              enableUserMoves:
                  _selectedIndex == recordedMoves.length - 1 &&
                  playerTurn(), // Enable moves only on the latest FEN
              onMove: () {
                db.makeMove(controller.getFen(), widget.gameId);
                setState(() {
                  recordedMoves.add(controller.getFen());
                  _selectedIndex =
                      recordedMoves.length -
                      1; // Always update to the latest index
                  listView.add(controller.game.history.last.move.toAlgebraic);
                  controller.loadFen(recordedMoves[_selectedIndex]);
                  audioServices.playSound('lib/assets/sounds/move-piece.mp3');

                  if (controller.game.game_over) {
                    showGameOverDialog();
                  }
                });
                animateToEnd();
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
            FutureBuilder<String>(
              future: db.getCurrentUserName(),
              builder: (context, snapshot) {
                final username = snapshot.data ?? "Loading...";
                return ProfileCard(
                  name: username,
                  player: true,
                  capturedPieces:
                      getCapturedPieces(
                        recordedMoves[_selectedIndex],
                      )[playerColor == PlayerColor.black ? 'black' : 'white'] ??
                      [],
                );
              },
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
