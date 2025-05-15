import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final bool player;
  List<String> capturedPieces = [];
  String? name;
  String? image;
  ProfileCard({
    super.key,
    required this.player,
    required this.capturedPieces,
    this.image,
    this.name,
  });

  Container noImage(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).canvasColor,
      ),
      child: Icon(
        Icons.person_2_rounded,
        color: Theme.of(context).highlightColor,
        size: 70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color imageColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;

    Color imageBackgroundColor =
        Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).canvasColor
            : Theme.of(context).highlightColor;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).highlightColor),
      width: double.infinity,
      padding: EdgeInsets.all(12),
      height: 100,
      child:
          player
              ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name ?? "Player",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Row(
                          spacing: 0,
                          children: [
                            for (int i = 0; i < capturedPieces.length; i++)
                              Container(
                                decoration: BoxDecoration(),
                                padding: EdgeInsets.all(4),
                                child: Image.asset(
                                  'lib/assets/images/${_getPieceImage(capturedPieces[i])}',
                                  width: 20,
                                  height: 20,
                                  color: imageColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  image == null ? noImage(context) : Image.asset(image!),
                ],
              )
              : Row(
                spacing: 0,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  image == null ? noImage(context) : Image.asset(image!),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? "StockFish",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Row(
                          spacing: 0,
                          children: [
                            for (int i = 0; i < capturedPieces.length; i++)
                              Container(
                                decoration: BoxDecoration(),
                                padding: EdgeInsets.all(4),
                                child: Image.asset(
                                  'lib/assets/images/${_getPieceImage(capturedPieces[i])}',
                                  width: 20,
                                  height: 20,
                                  color: imageColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  String _getPieceImage(String piece) {
    switch (piece.toLowerCase()) {
      case 'p':
        return 'pawn.png';
      case 'r':
        return 'rook.png';
      case 'n':
        return 'knight.png';
      case 'b':
        return 'bishop.png';
      case 'q':
        return 'queen.png';
      case 'k':
        return 'king.png';
      default:
        return '';
    }
  }
}
