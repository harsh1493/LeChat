import 'dart:core';
import 'dart:io';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:le_chat/screens/pages/confirm_image.dart';
import 'package:le_chat/screens/slivers.dart';
import 'package:flutter/material.dart';
import 'package:le_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatMessages extends StatefulWidget {
  static const String id = 'chat_room';
  final roomId;
  final gdp;
  final groupName;
  final isGroup;

  ChatMessages(
      {@required this.roomId,
      @required this.gdp,
      @required this.groupName,
      @required this.isGroup});
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  List<DropdownMenuItem<int>> listItems = [];
  bool emojiExpanded = false;
  String imageUrl;

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
    populateGroupMembers();
    //getGroupDp();
    print('Room ID: ${widget.roomId}');
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

  void populateGroupMembers() async {
    List<String> memebers = [];
    String uid = '';

    await for (var snapshots in _firestore
        .collection('chatRoom')
        .doc(widget.roomId)
        .collection('userMails')
        .snapshots()) {
      // print(List<String>.from(snapshots.docs));
      for (var mail in snapshots.docs) {
        memebers.add(mail.data()['email']);
      }
      print(memebers.contains(_auth.currentUser.email));
      if (!memebers.contains(_auth.currentUser.email)) {
        await _firestore
            .collection('chatRoom')
            .doc(widget.roomId)
            .collection('userMails')
            .add({'email': _auth.currentUser.email});

        // await _firestore
        //     .collection('chatRoom')
        //     .doc(widget.roomId)
        //     .collection('members')
        //     .add({
        //   'email': _auth.currentUser.email,
        //   'isAdmin': true,
        //   'timestamp': FieldValue.serverTimestamp(),
        //   'username': _auth.currentUser.displayName,
        //   'photoUrl': _auth.currentUser.photoURL
        // });
        print('added');
      } else {
        print('paile se hai');
      }
    }
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
          for (var message in messages.docs) {
            print(message.data());
          }
        }
      }
    }
  }

  uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;
    image = await _picker.getImage(source: ImageSource.gallery);
    var file = File(image.path);
    if (image != null) {
      var snapshot =
          await _storage.ref().child(image.path).putFile(file).onComplete;
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
        print(imageUrl);
      });
    } else {
      print('No path received');
    }
  }

  uploadCameraImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;
    image = await _picker.getImage(source: ImageSource.camera);
    var file = File(image.path);
    if (image != null) {
      var snapshot =
          await _storage.ref().child(image.path).putFile(file).onComplete;
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
        print(imageUrl);
      });
    } else {
      print('No path received');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              //Implement logout functionality
              //_auth.signOut();
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
          child: InkWell(
            onTap: () {
              //Navigator.pushNamed(context, Slivers.id);
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Slivers(
                  roomId: widget.roomId,
                  gdp: widget.gdp,
                  name: widget.groupName,
                  isGroup: widget.isGroup,
                );
              }));
            },
            child: Row(
              children: [
                Hero(
                  tag: 'group',
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundImage: NetworkImage(widget.gdp),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    Text(widget.groupName),
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
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              groupId: widget.roomId,
            ),
            Container(
              //decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      child: Stack(
                        children: [
                          Material(
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
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.grey,
                                ),
                                suffixIcon: Icon(
                                  Icons.attachment,
                                  color: Colors.grey,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                          // Positioned()
                          IconButton(
                              splashRadius: 20,
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey,
                                size: 25,
                              ),
                              onPressed: () {
                                print('emoji');
                              }),
                          Positioned(
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.grey,
                                      size: 25,
                                    ),
                                    onPressed: () async {
                                      print('camera');
                                      await uploadCameraImage();
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ConfirmImage(
                                            imageUrl: imageUrl,
                                            roomId: widget.roomId);
                                      }));
                                      print('uploaded');
                                    }),
                                IconButton(
                                    splashRadius: 20,
                                    icon: Icon(
                                      Icons.attachment,
                                      color: Colors.grey,
                                      size: 25,
                                    ),
                                    onPressed: () async {
                                      print('attach');
                                      await uploadImage();
                                      print(
                                          'image url from chat -----------$imageUrl');
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ConfirmImage(
                                            imageUrl: imageUrl,
                                            roomId: widget.roomId);
                                      }));
                                      print('uploaded');
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    child: FittedBox(
                      child: FloatingActionButton(
                        backgroundColor: Colors.grey,
                        onPressed: () {
                          //Implement send functionality.to send text & sender
                          if (messageText.length > 0) {
                            //_firestore.collection('messages')
                            _firestore
                                .collection('chatRoom')
                                .doc(widget.roomId)
                                .collection('messages')
                                .add({
                              'text': messageText,
                              'email': loggedInUser.email,
                              'timestamp': FieldValue.serverTimestamp(),
                              'username': loggedInUser.displayName,
                              //'datetime':
                            });
                          }
                          messageTextController.clear();
                          messageText = '';
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
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
  final String groupId;
  MessagesStream({@required this.groupId});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //: _firestore.collection('messages').snapshots(),
      // stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
      stream: _firestore
          .collection('chatRoom')
          .doc(groupId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
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
        print('MEssages      ${messages.length}');
        if (messages.length > 0) {
          _firestore
              .collection('chatRoom')
              .doc(groupId)
              .set({'justAdded': false}, SetOptions(merge: true));
        }
        List<StatelessWidget> messageWidgets = [];
        List<bool> isAD = [false];
        List<DateTime> dateList = [];
        int i = 0;
        for (var message in messages) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['username'];
          final mediaUrl = message.data()['mediaUrl'];
          final currentUser = loggedInUser.email;
          print(loggedInUser.displayName);
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
            mediaUrl: mediaUrl,
            isMe: message.data()['email'] == currentUser,
            ts: ts,
            isAD: dt.difference(ts).isNegative,
          );

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
          messageWidgets.add(messageWidget);
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
  final String mediaUrl;
  final bool isMe;
  final DateTime ts;
  final bool isAD;
  // static const DateTime dt;
  // dt = new DateTime.now();
  MessageBubble(
      {@required this.messageText,
      @required this.messageSender,
      @required this.mediaUrl,
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
          Visibility(
            visible: !isMe,
            child: Text(
              '$messageSender',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
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
            color: isMe ? Color.fromRGBO(20, 27, 40, 1) : Colors.black,
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
                  child: mediaUrl == null || mediaUrl == ''
                      ? Text(
                          '$messageText',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              textBaseline: TextBaseline.alphabetic),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                          child: Image(
                                            image: NetworkImage(mediaUrl),
                                          ),
                                        ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image(
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.fitWidth,
                                  image: NetworkImage(mediaUrl),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '  $messageText',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  textBaseline: TextBaseline.alphabetic),
                            )
                          ],
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
    return Container(
      padding: EdgeInsets.fromLTRB(
          150 - date.length.toDouble(), 0, 150 - date.length.toDouble(), 0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        elevation: 10,
        color: Color.fromRGBO(246, 246, 246, 0.2),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(
            date,
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
