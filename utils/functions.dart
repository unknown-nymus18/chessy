import 'package:chessy/utils/blur.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessy/utils/theme_provider.dart';

SnackBar customSnackBar(String message, BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return SnackBar(
    content: Blur(
      sigmaX: 10,
      sigmaY: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
              themeProvider.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
        ),
        child: Text(message, style: TextStyle(fontSize: 16)),
      ),
    ),
    elevation: 0,
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

Map<String, List<String>> getCapturedPieces(String fen) {
  final startingCount = {
    'P': 8,
    'N': 2,
    'B': 2,
    'R': 2,
    'Q': 1,
    'K': 1,
    'p': 8,
    'n': 2,
    'b': 2,
    'r': 2,
    'q': 1,
    'k': 1,
  };
  final currentCount = {
    'P': 0,
    'N': 0,
    'B': 0,
    'R': 0,
    'Q': 0,
    'K': 0,
    'p': 0,
    'n': 0,
    'b': 0,
    'r': 0,
    'q': 0,
    'k': 0,
  };

  final piecePlacement = fen.split(' ')[0];

  for (var char in piecePlacement.split('')) {
    if (RegExp(r'[PNBRQKpnbrqk]').hasMatch(char)) {
      currentCount[char] = currentCount[char]! + 1;
    }
  }

  final captured = {'white': <String>[], 'black': <String>[]};

  for (var piece in startingCount.keys) {
    int missing = startingCount[piece]! - currentCount[piece]!;
    if (missing > 0) {
      if (piece == piece.toUpperCase()) {
        captured['black']!.addAll(List.filled(missing, piece));
      } else {
        captured['white']!.addAll(List.filled(missing, piece));
      }
    }
  }

  return captured;
}

String generateGameId(String player1Id, String player2Id) {
  List<String> sortedIds = [player1Id, player2Id]..sort();
  return '${sortedIds[0]}_${sortedIds[1]}_${DateTime.now().millisecondsSinceEpoch}';
}

AlertDialog customAlertDialog(
  BuildContext context,
  String title,
  String content,
  Function()? yes,
  Function()? no,
) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      MaterialButton(
        onPressed: yes,
        color: Colors.transparent,
        elevation: 10,
        child: Text("Ok"),
      ),
      MaterialButton(
        onPressed: no,
        color: Colors.transparent,
        elevation: 10,
        child: Text("Cancel"),
      ),
    ],
  );
}
