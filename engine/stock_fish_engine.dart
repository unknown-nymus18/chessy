import 'package:stockfish/stockfish.dart';

class StockFishEngine {
  static final Stockfish _instance = Stockfish();

  static Stockfish get instance => _instance;
}
