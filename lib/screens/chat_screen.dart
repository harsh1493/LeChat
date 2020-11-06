import 'dart:core';

import 'package:le_chat/screens/slivers.dart';
import 'package:flutter/material.dart';
import 'package:le_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  List<DropdownMenuItem<int>> listItems = [];

  void loadData() {
    listItems.add(
      new DropdownMenuItem(
        child: Text('Hello'),
        value: 1,
      ),
    );
    listItems.add(
      new DropdownMenuItem(
        child: Text('Hello'),
        value: 2,
      ),
    );
    listItems.add(
      new DropdownMenuItem(
        child: Text('Hello'),
        value: 3,
      ),
    );
  }

  String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    loadData();
    usersStream();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print('hello ${loggedInUser.email}');
      }
    } catch (e) {
      print(e);
    }
  }

  //this does not pull live data(only new data message) from database as new data is added by another user or admin
  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }

  //this returns all the data(list of data messages) each time any change is made to db
  //data is sent ass soon aas it is generated without being even queried for(i.e without using get() method)
  //as list of String is List<String>,similarly list if Future<String> is Stream<String>
  void addUser(String email) async {
    await _firestore.collection('users').add({'name': email});
  }

  void usersStream() async {
    await for (var snapshot in _firestore.collection('users').snapshots()) {
      for (var user in snapshot.docs) {
        print(user.data());
      }
    }
  }

  void messageStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              //Implement logout functionality
              _auth.signOut();
              Navigator.pop(context);
              //getMessages();
              //messageStream();
            }),
        actions: <Widget>[
          DropdownButton(
              icon: Icon(Icons.menu),
              iconSize: 25,
              items: listItems,
              onChanged: (value) {
                print(value);
              })
        ],
        title: Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Slivers.id);
                }, // handle your image tap here
                child: Hero(
                  tag: 'group',
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundImage: AssetImage('images/group.webp'),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Wrap(
                direction: Axis.vertical,
                children: [
                  Text('Flutter Group'),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Tap here for group info',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              //decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 8),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.white,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: messageTextController,
                          onChanged: (value) {
                            //Do something with the user input.
                            messageText = value;
                            //print('$value text $messageText');
                          },
                          decoration: kMessageTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              Icons.add_a_photo,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.to send text & sender
                      if (messageText.length > 0) {
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'email': loggedInUser.email,
                          'timestamp': FieldValue.serverTimestamp(),
                          'username': '',
                          //'datetime':
                        });
                      }
                      messageTextController.clear();
                      messageText = '';
                    },
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      color: Colors.grey.shade500, // button color
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Icon(Icons.send),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //: _firestore.collection('messages').snapshots(),
      stream:
          _firestore.collection('messages').orderBy('timestamp').snapshots(),
      // ignore: missing_return
      builder: (context, snapshot) {
        //used to rebuild the list of test widgets on screen as new data is pipelined or streamed
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ));
        }
        final messages = snapshot.data.docs.reversed;
        List<StatelessWidget> messageWidgets = [];
        List<bool> isAD = [false];
        List<DateTime> dateList = [];
        int i = 0;
        for (var message in messages) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['email'];
          final currentUser = loggedInUser.email;

          // if (messageSender == currentUser) {
          //   //message from signed in user
          // }

          Timestamp op = message.data()['timestamp'];
          final ts = op == null ? DateTime.now() : op.toDate();
          dateList.add(ts);
          var dt = new DateTime.now();
          //print(ts.toDate());
          final messageWidget = MessageBubble(
            messageText: messageText,
            messageSender: messageSender,
            isMe: messageSender == currentUser,
            ts: ts,
            isAD: dt.difference(ts).isNegative,
          );
          messageWidgets.add(messageWidget);

          if (i > 0) {
            if (dateList[i].day < dateList[i - 1].day) {
              isAD.add(true);
            } else {
              // print(dateList[i].day);
              // print(dateList[i - 1].day);
              isAD.add(false);
            }
          }

          if (isAD[i]) {
            final DateFormat formatter = DateFormat('dd-MM-yyyy');

            messageWidgets.add(AnotherDay(
                date: formatter.format(dt) == formatter.format(dateList[i - 1])
                    ? 'Today'
                    : formatter.format(dateList[i - 1]).toString()));
          }
          // if (dt.day > ts.day) {
          //   messageWidgets.add(AnotherDay(date: ts.toString()));
          // }
          i++;
        }
        print(isAD);
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String messageText;
  final String messageSender;
  final bool isMe;
  final DateTime ts;
  final bool isAD;
  // static const DateTime dt;
  // dt = new DateTime.now();
  MessageBubble(
      {@required this.messageText,
      @required this.messageSender,
      @required this.isMe,
      @required this.ts,
      @required this.isAD});

  String Time() {
    int hr = ts.hour;
    int min = ts.minute;
    return '$hr : $min';
  }

  // bool IsNewDay() {
  //   var dt = new DateTime.now();
  //   return !dt.difference(ts.toDate()).isNegative;
  // }

  @override
  Widget build(BuildContext context) {
    // if (IsNewDay()) {
    //   return AnotherDay();
    // }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$messageSender',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            color: isMe ? Colors.blue : Colors.black12,
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 5, left: 15, right: 15, bottom: 0),
                  child: Text(
                    //'${ts.toDate().hour}: ${ts.toDate().minute}',
                    Time(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    '$messageText',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        textBaseline: TextBaseline.alphabetic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnotherDay extends StatelessWidget {
  final String date;
  AnotherDay({@required this.date});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        elevation: 10,
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              date,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
