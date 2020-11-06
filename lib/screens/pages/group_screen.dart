import 'package:le_chat/screens/chat_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
var names = {};
List<int> isIn = [];

class GroupScreen extends StatefulWidget {
  final List<String> chatRoomName;
  final List<String> chatRoomId;
  final List<Widget> chatRooms;
  final String query;
  GroupScreen(
      {@required this.chatRoomName,
      @required this.chatRoomId,
      @required this.chatRooms,
      @required this.query});
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _auth = FirebaseAuth.instance;
  // final List<String> chatRoomName = ['v'];
  // final List<String> chatRoomId = ['w'];
  var lastMessage;
  List<ChatRoom> chatRooms = [];

  @override
  void initState() {
    //getCurrentUser();
    //getGroupMessageStream();
    //getGroupStream();
    getNames();
    print(names);
    // TODO: implement initState
    super.initState();
  }

  void getNames() async {
    await for (var snapshots in _firestore.collection('users').snapshots()) {
      for (var user in snapshots.docs) {
        print('-------------------');
        setState(() {
          print(user.data()['username']);
          names[user.data()['uid']] = {
            'name': user.data()['username'],
            'photoUrl': user.data()['photoUrl']
          };
        });
      }
    }
  }

  void getGroupStream() async {
    setState(() async {
      await for (var snapshot
          in _firestore.collection('chatRoom').snapshots()) {
        for (var group in snapshot.docs) {
          widget.chatRoomName.add(group.data()['roomName']);
          widget.chatRoomId.add(group.id);
          chatRooms.add(ChatRoom(
              img: group.data()['groupDp'],
              name: group.data()['roomName'],
              chatroomId: group.id));
          print('Chat room: ${widget.chatRoomName[0]},${widget.chatRoomId[0]}');
        }
      }
    });
  }

  void getGroupMessageStream() async {
    await for (var snapshot in _firestore.collection('chatRoom').snapshots()) {
      for (var groupName in snapshot.docs) {
        print(groupName.data());
        print(groupName.id);
        await for (var messages in _firestore
            .collection('chatRoom')
            .doc(groupName.id)
            .collection('messages')
            .snapshots()) {
          print(messages.docs.last.data()['text']);
          for (var message in messages.docs) {
            print(message.data());
          }
        }
      }
    }
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(
            'hello ${loggedInUser.email} username ${loggedInUser.displayName}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('--------${widget.query}');
    //getGroupMessageStream();
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          GroupStream(),
        ],
      )),
    );
  }
}

class GroupStream extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chatRoom').snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
          // ignore: missing_return
        }
        // ignore: missing_return
        final groups = snapshots.data.docs;
        List<StatelessWidget> chatRooms = [];
        int i = 0;

        for (var group in groups) {
          final img = group.data()['groupDp'];
          final name = group.data()['roomName'];
          final justCreated = group.data()['justAdded'];
          final id = group.id;
          final isGroup = group.data()['isGroup'];
          if (!isGroup) {
            i += 1;
            bool isEligible = false;
            var n = names[name.substring(
                name.indexOf('/') + 1, name.toString().length)]['name'];
            var p = names[name.substring(
                name.indexOf('/') + 1, name.toString().length)]['photoUrl'];
            if (_auth.currentUser.uid == name.substring(0, name.indexOf('/'))) {
              n = names[name.substring(
                  name.indexOf('/') + 1, name.toString().length)]['name'];
              p = names[name.substring(
                  name.indexOf('/') + 1, name.toString().length)]['photoUrl'];
              isEligible = true;
            } else if (_auth.currentUser.uid ==
                name.substring(name.indexOf('/') + 1, name.toString().length)) {
              n = names[name.substring(0, name.indexOf('/'))]['name'];
              p = names[name.substring(0, name.indexOf('/'))]['photoUrl'];
              isEligible = true;
            } else {
              n = names[name.substring(
                      name.indexOf('/') + 1, name.toString().length)]['name'] +
                  '/' +
                  names[name.substring(0, name.indexOf('/'))]['name'];
              p = 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU';
              isEligible = false;
            }

            final groupWidget = ChatRoom(
                img: p ??
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU',
                name: n,
                chatroomId: id,
                justCreated: justCreated,
                isGroup: isGroup);
            //chatRooms.add(groupWidget);
            isEligible && !chatRooms.contains(groupWidget)
                ? chatRooms.add(groupWidget)
                : print('');
          } else {
            List<dynamic> members = group.data()['members'];

            // group.reference
            //     .collection('members')
            //     .doc(_auth.currentUser.uid)
            //     .get()
            //     .then((value) {
            //   print(' ${group.data()['roomName']}---- ${value.exists}');
            //   value.exists ?? isIn.add(i);
            // });
            if (members.contains(_auth.currentUser.uid)) {
              final groupWidget = ChatRoom(
                img: img,
                name: name,
                chatroomId: id,
                justCreated: justCreated,
                isGroup: isGroup,
              );
              chatRooms.add(groupWidget);
            }
          }
          print(isIn);
        }
        return Expanded(
            child: ListView(
          children: chatRooms,
        ));
      },
    );
  }
}

class LastMessage extends StatelessWidget {
  final roomId;
  final bool justCreated;
  final bool getTime;
  final _auth = FirebaseAuth.instance;
  LastMessage(
      {@required this.roomId,
      @required this.justCreated,
      @required this.getTime});

  String toTime(DateTime dt) {
    int day = dt.day;
    int month = dt.month;
    int year = dt.year;
    bool isAM = true;
    var hr = dt.hour;
    var now = DateTime.now();

    if (year == now.year && month == now.month && day == now.day) {
      if (dt.hour > 12) {
        hr = dt.hour - 12;
        isAM = false;
      }
      var postfix = isAM ? 'AM' : 'PM';
      return hr.toString() +
          ':' +
          dt.minute.toString() +
          ' ' +
          postfix.toString();
    } else if (year == now.year && month == now.month && day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '$day/$month/$year';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (justCreated) {
      return Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chatRoom')
            .doc(roomId)
            .collection('messages')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshots) {
          if (!snapshots.hasData || snapshots.hasError) {
            return Text(
              'dd',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            );
            // ignore: missing_return
          }
          // ignore: missing_return
          //final groups = snapshots.data.docs;
          // var lm=snapshots.data.docs.sort()
          var unRead = snapshots.data.docs.length;
          var lastmessage = snapshots.data.docs.last.data()['text'];
          var lastsender = _auth.currentUser.email !=
                  snapshots.data.docs.last.data()['email']
              ? snapshots.data.docs.last.data()['username'] + ' :  '
              : '';
          Timestamp time = snapshots.data.docs.last.data()['timestamp'];
          var t = time.toDate().compareTo(DateTime.now());
          print(toTime(time.toDate()));
          if (!getTime) {
            return Text(
              '$lastsender$lastmessage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  toTime(time.toDate()),
                  style: TextStyle(
                    color: Color.fromRGBO(0, 175, 156, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                CircleAvatar(
                  backgroundColor: Color.fromRGBO(0, 175, 156, 1),
                  radius: 10,
                  child: Text(
                    unRead.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  foregroundColor: Colors.black,
                ),
              ],
            );
          }
        },
      );
    }
  }
}

class ChatRoom extends StatelessWidget {
  final String img;
  final String name;
  final String chatroomId;
  final bool justCreated;
  final bool isGroup;
  ChatRoom(
      {@required this.img,
      @required this.name,
      @required this.chatroomId,
      @required this.justCreated,
      @required this.isGroup});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            print(name);
            print(chatroomId);
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ChatMessages(
                  roomId: chatroomId,
                  gdp: img,
                  groupName: name,
                  isGroup: isGroup);
            }));
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 0, 15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(img),
                  backgroundColor: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    LastMessage(
                        roomId: chatroomId,
                        justCreated: justCreated,
                        getTime: false),
                  ],
                ),
                Spacer(),
                LastMessage(
                    roomId: chatroomId,
                    justCreated: justCreated,
                    getTime: true),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(
              height: 0,
              width: 70,
              child: Container(
                padding: EdgeInsets.all(15),
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 0.5,
              width: 335,
              child: Container(
                padding: EdgeInsets.all(15),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
