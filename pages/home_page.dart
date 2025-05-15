import 'dart:math';

import 'package:chessy/pages/local_game.dart';
import 'package:chessy/services/audio_services.dart';
import 'package:chessy/services/auth_service.dart';
import 'package:chessy/services/database.dart';
import 'package:chessy/pages/friends_page.dart';
import 'package:chessy/pages/multiplayer_page.dart';
import 'package:chessy/pages/settings.dart';
import 'package:chessy/utils/custom_button.dart';
import 'package:chessy/utils/functions.dart';
import 'package:chessy/utils/game_tile.dart';
import 'package:chessy/utils/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:provider/provider.dart';
import 'package:chessy/utils/theme_provider.dart';
import 'package:chessy/pages/play_stockfish.dart';
import 'package:chessy/utils/blur.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioServices audioService = AudioServices();
  Database db = Database();
  PlayerColor playerColor = PlayerColor.white;
  ScrollController scrollController = ScrollController();
  double imageSize = 300; // Initial size of the image
  AuthService authService = AuthService();

  ValueNotifier<double> height = ValueNotifier(120);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    height.dispose();
    super.dispose();
  }

  void randomChoice() {
    var random = Random();
    playerColor = PlayerColor.values.elementAt(
      random.nextInt(PlayerColor.values.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person_3_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendsPage()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            );
          },
        ),
        title: Text("C H E S S Y"),
        centerTitle: true,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              controller: scrollController, // Attach the scroll controller
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: imageSize, // Dynamically adjust the image size
                    child: Image.asset('lib/assets/images/chessy.png'),
                  ),
                  Text(
                    "G A M E S",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: db.getUserGames(
                      FirebaseAuth.instance.currentUser?.uid,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingScreen(); // Show loading indicator
                      }
                      if (snapshot.hasError) {
                        // Log the error for debugging
                        print("Error loading games: ${snapshot.error}");
                        return Text(
                          "Error loading games. Please try again later.",
                        ); // User-friendly error message
                      }
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final games = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap:
                              true, // Ensure it doesn't take infinite height
                          physics: ScrollPhysics(), // Enable scrolling
                          itemCount: games.length > 5 ? 5 : games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            final gameId = game['gameId'];
                            final fen =
                                game.isNotEmpty
                                    ? game['moves'].last
                                    : "RNBQKBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbnr";
                            final white = game['white'];
                            final black = game['black'];
                            return GameTile(
                              fen: fen,
                              white: white,
                              black: black,
                              gameId: gameId,
                            );
                          },
                        );
                      }
                      if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Text("No games found"); // Handle no games
                      }
                      return Text(
                        "Unexpected error occurred.",
                      ); // Fallback for unexpected cases
                    },
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<Map<String, dynamic>?>(
                  stream: db.listenForGameRequests(
                    FirebaseAuth.instance.currentUser!.uid,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final gameRequests = snapshot.data!;
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: db.getUserInfo(gameRequests['senderId']),
                        builder: (context, userSnapshot) {
                          audioService.playSound(
                            "lib/assets/sounds/notification.mp3",
                          );
                          if (userSnapshot.connectionState ==
                                  ConnectionState.done &&
                              userSnapshot.hasData) {
                            final userInfo = userSnapshot.data!;
                            return Blur(
                              sigmaX: 10,
                              sigmaY: 10,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                height: 80,
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.black12
                                        : Colors.white12,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${userInfo['username']} wants to play",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                  Colors.green,
                                                ),
                                          ),
                                          icon: Icon(Icons.check),
                                          onPressed: () {
                                            db.acceptGameRequest(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                              gameRequests['gameId'],
                                              gameRequests['senderId'],
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => MultiplayerPage(
                                                      opponentName:
                                                          userInfo['username'],
                                                      gameId:
                                                          gameRequests['gameId'],
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                  Colors.red,
                                                ),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            db.declineGameRequest(
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                              gameRequests['gameId'],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return SizedBox();
                        },
                      );
                    }
                    return SizedBox();
                  },
                ),
                Blur(
                  sigmaX: 10,
                  sigmaY: 10,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                          width: 1,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: ListenableBuilder(
                        listenable: height,
                        builder: (context, child) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                height.value == 120
                                    ? Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        height: 50,
                                        minWidth: 300,
                                        onPressed: () {
                                          height.value =
                                              mediaQuery.size.height * 0.7;
                                        },
                                        color: Colors.purple[200],
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: const Text(
                                          "PLAY",
                                          style: TextStyle(fontSize: 25),
                                        ),
                                      ),
                                    )
                                    : Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(13),
                                          margin: EdgeInsets.all(15),
                                          color: Colors.pink,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "CHOOSE",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: randomChoice,
                                                    child: AnimatedContainer(
                                                      duration: Duration(
                                                        milliseconds: 400,
                                                      ),
                                                      height: 40,
                                                      width: 40,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            color: Colors.white,
                                                            width: 20,
                                                          ),
                                                          Container(
                                                            color: Colors.black,
                                                            width: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20),
                                                  GestureDetector(
                                                    onTap: () {
                                                      playerColor =
                                                          PlayerColor.white;
                                                      setState(() {});
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: Duration(
                                                        milliseconds: 400,
                                                      ),
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border:
                                                            playerColor ==
                                                                    PlayerColor
                                                                        .white
                                                                ? Border.all(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  width: 2,
                                                                )
                                                                : Border.all(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  width: 2,
                                                                ),
                                                        borderRadius:
                                                            playerColor ==
                                                                    PlayerColor
                                                                        .white
                                                                ? BorderRadius.all(
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                                )
                                                                : BorderRadius.all(
                                                                  Radius.circular(
                                                                    0,
                                                                  ),
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20),
                                                  GestureDetector(
                                                    onTap: () {
                                                      playerColor =
                                                          PlayerColor.black;
                                                      setState(() {});
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: Duration(
                                                        milliseconds: 400,
                                                      ),
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        border:
                                                            playerColor ==
                                                                    PlayerColor
                                                                        .black
                                                                ? Border.all(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  width: 2,
                                                                )
                                                                : Border.all(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  width: 2,
                                                                ),
                                                        borderRadius:
                                                            playerColor ==
                                                                    PlayerColor
                                                                        .black
                                                                ? BorderRadius.all(
                                                                  Radius.circular(
                                                                    12,
                                                                  ),
                                                                )
                                                                : BorderRadius.all(
                                                                  Radius.circular(
                                                                    0,
                                                                  ),
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        CustomButton(
                                          text: "P1 vs P2",
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => LocalGame(),
                                              ),
                                            );
                                          },
                                        ),
                                        CustomButton(
                                          text: "P1 vs AI",
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => PlayStockfish(
                                                      playerColor: playerColor,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                        CustomButton(
                                          text: "MULTIPLAYER",
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => FriendsPage(),
                                              ),
                                            );
                                          },
                                        ),
                                        CustomButton(
                                          text: "TRAINING",
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return customAlertDialog(
                                                  context,
                                                  "Coming Soon!",
                                                  "This feature is under development.",
                                                  () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  () {
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            child: MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              height: 50,
                                              minWidth: 300,
                                              onPressed: () {
                                                height.value = 120;
                                              },
                                              color: Colors.purple[200],
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: const Text(
                                                "C L O S E",
                                                style: TextStyle(fontSize: 25),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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
