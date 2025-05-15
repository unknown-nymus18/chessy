import 'package:chessy/pages/watch_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class GameTile extends StatelessWidget {
  final String fen;
  final String white;
  final String black;
  final String gameId;
  const GameTile({
    super.key,
    required this.fen,
    required this.white,
    required this.black,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    ChessBoardController chessBoardController = ChessBoardController();
    chessBoardController.loadFen(fen);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    WatchPage(white: white, black: black, gameId: gameId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ChessBoard(
              controller: chessBoardController,
              size: 100,
              enableUserMoves: false,
            ),
            SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  black,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  white,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
