import 'package:chessy/services/database.dart';
import 'package:chessy/pages/multiplayer_page.dart';
import 'package:chessy/utils/custom_text_field.dart';
import 'package:chessy/utils/functions.dart';
import 'package:chessy/utils/user_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  TextEditingController _searchController = TextEditingController();

  Database db = Database();
  List<Map<String, dynamic>> allFriends = [];
  List<Map<String, dynamic>> displayedUsers = [];
  bool isSearching = false;
  late StreamSubscription<List<Map<String, dynamic>>> _friendsSubscription;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_handleSearch);
  }

  void _loadFriends() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return; // Exit the method if no user is signed in
    }

    _friendsSubscription = db
        .getFriends(currentUser.uid)
        .listen(
          (friends) {
            print("Friends loaded: $friends"); // Debugging log
            setState(() {
              allFriends = friends;
              displayedUsers = friends; // Initially show all friends
            });
          },
          onError: (error) {
            throw Exception("Error loading friends: $error");
          },
        );
  }

  void _handleSearch() async {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        displayedUsers = allFriends; // Reset to show only friends
      });
    } else {
      setState(() {
        isSearching = true;
      });
      try {
        final users = await db.searchUsersByName(query);
        setState(() {
          displayedUsers = users; // Show search results
        });
      } catch (e) {
        throw Exception("Error searching users: $e");
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Properly dispose of the controller
    _friendsSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            false,
            controller: _searchController,
            labelText: "Search by username",
            padding: EdgeInsets.only(
              left: 25,
              right: _searchController.text.isNotEmpty ? 10 : 25,
            ),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          IconButton(
            iconSize: 30,
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _handleSearch();
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("F R I E N D S"), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 20),
          _searchBar(),
          SizedBox(height: 20),
          Expanded(
            child:
                displayedUsers.isEmpty
                    ? Center(
                      child: Text(
                        isSearching ? "No users found" : "No friends found",
                      ),
                    )
                    : ListView.builder(
                      itemCount: displayedUsers.length,
                      itemBuilder: (context, index) {
                        final user = displayedUsers[index];
                        final username = user['username'] ?? 'Unknown';
                        final uid = user['uid'];
                        if (uid == null) {
                          return SizedBox.shrink(); // Skip rendering this user
                        }
                        return UserTile(
                          username: username,
                          trailing: [
                            IconButton(
                              icon: Icon(Icons.message, color: Colors.blue),
                              tooltip: "Message",
                              onPressed: () {
                                // Add logic to send a message
                                // TODO: Implement messaging functionality
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.sports_esports,
                                color: Colors.orange,
                              ),
                              tooltip: "Challenge",
                              onPressed: () {
                                String gameId = generateGameId(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  uid,
                                );

                                db.sendGameRequest(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  uid,
                                  gameId,
                                );
                                db.listenForGameAcceptance(gameId).listen((
                                  isAccepted,
                                ) {
                                  if (isAccepted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MultiplayerPage(
                                              opponentName: username,
                                              gameId: gameId,
                                            ),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
