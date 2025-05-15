import 'package:chessy/utils/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String username,
    required String uid,
    required String email,
    required Timestamp timestamp,
    firstName,
  }) async {
    firestore.collection('Users').doc(uid).set({
      'username': username,
      'uid': uid,
      'email': email,
      'timestamp': timestamp,
      'firstName': firstName,
    });
  }

  Future<bool> isUsernameTaken(String username) async {
    final querySnapshot =
        await firestore
            .collection('Users')
            .where('username', isEqualTo: username)
            .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> makeMove(String currentMove, String gameId) async {
    try {
      if (gameId.isEmpty) {
        throw Exception("Game ID cannot be empty");
      }
      await firestore.collection('Games').doc(gameId).collection('moves').add({
        'move': currentMove,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to record move: $e");
    }
  }

  Stream<List<String>> getMovesStream(String gameId) {
    return firestore
        .collection('Games')
        .doc(gameId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs.map((doc) => doc['move'] as String).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final querySnapshot = await firestore.collection('Users').get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getUsersExcluding(
    String currentUserId,
  ) async {
    final querySnapshot =
        await firestore
            .collection('Users')
            .where('uid', isNotEqualTo: currentUserId)
            .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Stream<List<Map<String, dynamic>>> getFriends(String currentUserId) {
    return firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('Friends')
        .snapshots()
        .asyncMap((querySnapshot) async {
          List<Map<String, dynamic>> friends = [];
          for (var friendDoc in querySnapshot.docs) {
            try {
              final uid = friendDoc.data()?['uid'];
              if (uid == null) {
                continue;
              }
              final userSnapshot =
                  await firestore.collection('Users').doc(uid).get();
              if (userSnapshot.exists) {
                final friendData = {
                  'uid': uid,
                  'username': userSnapshot.data()?['username'] ?? 'Unknown',
                  'email': userSnapshot.data()?['email'] ?? '',
                };
                friends.add(friendData);
                print("Friend added: $friendData"); // Debugging log
              } else {
                print("User document does not exist for uid: $uid");
              }
            } catch (e) {
              print(
                "Error fetching friend details for document ${friendDoc.id}: $e",
              );
            }
          }
          return friends;
        });
  }

  Future<void> addFriend(String currentUserId, String uid) async {
    if (currentUserId == uid) {
      throw Exception("You cannot add yourself as a friend");
    }

    final existingFriend =
        await firestore
            .collection('Users')
            .doc(currentUserId)
            .collection('Friends')
            .doc(uid)
            .get();

    if (existingFriend.exists) {
      throw Exception("User is already a friend");
    }

    await firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('Friends')
        .doc(uid)
        .set({'uid': uid, 'timestamp': FieldValue.serverTimestamp()});
  }

  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    final querySnapshot =
        await firestore
            .collection('Users')
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> addFriendRequest(String currentUserId, String friendId) async {
    await firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('FriendRequests')
        .doc(friendId)
        .set({'friendId': friendId, 'timestamp': FieldValue.serverTimestamp()});
  }

  Future<List<Map<String, dynamic>>> getFriendRequests(
    String currentUserId,
  ) async {
    final querySnapshot =
        await firestore
            .collection('Users')
            .doc(currentUserId)
            .collection('FriendRequests')
            .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> acceptGameRequest(
    String currentUserId,
    String gameId,
    String senderRequestId,
  ) async {
    await firestore.collection("Games").doc(gameId).set({
      'black': senderRequestId,
      'white': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('GameRequests')
        .doc(gameId)
        .delete();
  }

  Stream<bool> listenForGameAcceptance(String gameId) {
    return FirebaseFirestore.instance
        .collection('Games')
        .doc(gameId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> sendGameRequest(
    String currentUserId,
    String receiverId,
    String gameId,
  ) async {
    await firestore
        .collection('Users')
        .doc(receiverId)
        .collection('GameRequests')
        .doc(gameId)
        .set({
          'gameId': gameId,
          'senderId': currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<String> getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await firestore.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['username'] ?? 'Unknown User';
      }
    }
    return 'Unknown User';
  }

  Stream<Map<String, dynamic>?> listenForGameRequests(String currentUserId) {
    return firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('GameRequests')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.data() as Map<String, dynamic>;
          }
          return null;
        });
  }

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    final doc = await firestore.collection('Users').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> declineGameRequest(String currentUserId, String gameId) async {
    await firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('GameRequests')
        .doc(gameId)
        .delete();
  }

  Future<String?> getPlayerColor(String gameId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final gameSnapshot = await firestore.collection("Games").doc(gameId).get();

    if (gameSnapshot.exists) {
      final data = gameSnapshot.data();
      if (data != null) {
        if (data['black'] == userId) {
          return 'black';
        } else if (data['white'] == userId) {
          return 'white';
        }
      }
    }
    return null;
  }

  Stream<List<Map<String, dynamic>>> getUserGames(String? uid) {
    return firestore.collection("Games").snapshots().asyncMap((
      gamesSnapshot,
    ) async {
      List<Map<String, dynamic>> userGames = [];
      for (var gameDoc in gamesSnapshot.docs) {
        final data = gameDoc.data();

        if (data != null && (data['black'] == uid || data['white'] == uid)) {
          final movesSnapshot =
              await gameDoc.reference
                  .collection('moves')
                  .orderBy('timestamp', descending: false)
                  .get();

          final moves =
              movesSnapshot.docs.map((doc) => doc['move'] as String).toList();

          final whiteUid = data['white'];
          final blackUid = data['black'];

          final whiteUserSnapshot =
              await firestore.collection('Users').doc(whiteUid).get();
          final blackUserSnapshot =
              await firestore.collection('Users').doc(blackUid).get();

          final whiteUserName =
              whiteUserSnapshot.data()?['username'] ?? 'Unknown';
          final blackUserName =
              blackUserSnapshot.data()?['username'] ?? 'Unknown';

          final haveMoves =
              await firestore
                  .collection("Games")
                  .doc(gameDoc.id)
                  .collection("moves")
                  .limit(1)
                  .get();
          if (haveMoves.docs.isNotEmpty) {
            userGames.add({
              'gameId': gameDoc.id,
              'white': whiteUserName,
              'black': blackUserName,
              'moves': moves,
            });
          }
        }
      }
      return userGames;
    });
  }
}
