import 'dart:async';

import 'package:le_chat/screens/chat_messages.dart';
import 'package:le_chat/screens/pages/add_room.dart';
import 'package:le_chat/screens/pages/call_Screen.dart';
import 'package:le_chat/screens/pages/camera_screen.dart';
import 'package:le_chat/screens/pages/group_screen.dart';
import 'package:le_chat/screens/pages/image_gallery.dart';
import 'package:le_chat/screens/pages/nw_group.dart';
import 'package:le_chat/screens/pages/status_screen.dart';
import 'package:le_chat/screens/editPages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class HomePage extends StatefulWidget {
  static const String id = 'home_page';
  final isFromReg;
  final tabIndex;
  HomePage({@required this.isFromReg,@required this.tabIndex});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isSearching = false;
  bool isTapped = false;
  final _query = TextEditingController();
  List<String> chatRoomName = [];
  List<String> chatRoomId = [];
  List<Widget> chatRooms = [];

  final _auth = FirebaseAuth.instance;
  TabController _tabController;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to logout '),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  _auth.signOut();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void getGroupStream() async {
    setState(() async {
      await for (var snapshot
          in _firestore.collection('chatRoom').snapshots()) {
        for (var group in snapshot.docs) {
          chatRoomName.add(group.data()['roomName']);
          chatRoomId.add(group.id);
          chatRooms.add(ChatRoom(
              img: group.data()['groupDp'],
              name: group.data()['roomName'],
              chatroomId: group.id));
          print('Chat room a: ${chatRoomName[0]},${chatRoomId[1]}');
          //print(groupName.data()['roomName']);
          //print(groupName.id);
        }
      }
    });
  }

  void setUserProfile(String userName, String photoUrl) async {
    var user = _auth.currentUser;
    try {
      await user.updateProfile(
          displayName:
              userName == null ? _auth.currentUser.displayName : userName,
          photoURL: photoUrl == null ? _auth.currentUser.photoURL : photoUrl);
      await _auth.currentUser.reload();
    } catch (e) {
      print(e);
    }
  }

  void setDefaultName() {
    if (_auth.currentUser.displayName == null ||
        _auth.currentUser.displayName == '') {
      setUserProfile(_auth.currentUser.email, null);
    }
  }

  void addUser() async {
    await _firestore.collection('users').doc(_auth.currentUser.uid).set({
      'email': _auth.currentUser.email,
      'mobile': _auth.currentUser.phoneNumber,
      'photoUrl': _auth.currentUser.photoURL,
      'username': _auth.currentUser.displayName == null
          ? _auth.currentUser.email
          : _auth.currentUser.displayName,
      'timestamp': new DateTime.now(),
      'uid': _auth.currentUser.uid,
    }, SetOptions(merge: true));
    print('added');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.tabIndex);
    _tabController.addListener(_handleTabIndex);
    setDefaultName();

    // getGroupStream();
    print('IS FROM REGISTRATION PAGE: ${widget.isFromReg}');
    if (widget.isFromReg) {
      addUser();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_auth
                                      .currentUser.photoURL ==
                                  null
                              ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                              : _auth.currentUser.photoURL),
                          radius: 35,
                          child: GestureDetector(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                    child: Image(
                                  image: NetworkImage(_auth
                                              .currentUser.photoURL ==
                                          null
                                      ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                                      : _auth.currentUser.photoURL),
                                )),
                              );
                            },
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          splashColor: Colors.blue,
                          child: Icon(Icons.edit),
                          onTap: () {
                            print('EDIt');
                            Navigator.pushNamed(context, ProfilePage.id);
                          },
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    Text(
                      _auth.currentUser.displayName == null
                          ? 'Add Name'
                          : _auth.currentUser.displayName,
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(_auth.currentUser.email),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.group_add,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'New Group',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                onTap: () {
                  // Update the state of the app.
                  Navigator.pushNamed(context, NwGroup.id);
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.save_alt,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Saved Messages',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                onTap: () {
                  // Update the state of the app.
                  print('Setting');
                  // ...
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                onTap: () {
                  // Update the state of the app.
                  _auth.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);

                  // ...
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: !isSearching
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTapped = true;
                          Timer(Duration(seconds: 3), () {
                            setState(() {
                              isTapped = false;
                            });
                          });
                        });
                      },
                      child: isTapped
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.2, right: 16),
                              child: Image(
                                image: AssetImage('images/splash_g.gif'),
                                height: 35,
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 7, right: 10),
                              child: Image(
                                image: AssetImage('images/splash_i.png'),
                                height: 69,
                              ),
                            ),
                    ),
                    Text(
                      'Le Chat',
                      style: TextStyle(fontSize: 30),
                    ),
                  ],
                )
              : TextField(
                  controller: _query,
                  onChanged: (value) {
                    print(_query.text);
                  },
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    contentPadding:
                        EdgeInsets.only(left: 0, bottom: 0, top: 15, right: 0),
                  ),
                ),
          actions: [
            isSearching
                ? IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isSearching = false;
                      });
                    },
                  )
                : IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    icon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isSearching = true;
                      });
                    },
                  ),
          ],
          bottom: new TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.camera_alt),
              ),
              Tab(
                text: "CHAT",
              ),
              Tab(
                text: "STATUS",
              ),
              Tab(
                text: "CALLS",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            CameraScreen(),
            GroupScreen(
              chatRoomName: chatRoomName,
              chatRoomId: chatRoomId,
              chatRooms: chatRooms,
              query: _query.text,
            ),
            StatusScreen(),
            CallScreen(),
          ],
        ),
        floatingActionButton: Float(id: _tabController.index),
      ),
    );
  }
}

class Float extends StatelessWidget {
  final int id;
  Float({@required this.id});

  IconData setId() {
    if (id == 0) {
      return Icons.camera_alt;
    }
    if (id == 1) {
      return Icons.message;
    }
    if (id == 2) {
      return Icons.camera_alt;
    }
    if (id == 3) {
      return Icons.call;
    }
    return Icons.message;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).backgroundColor,
      child: Icon(
        setId(),
        color: Colors.white,
      ),
      onPressed: () {
        print('Hello chat');
        if (id == 1) Navigator.pushNamed(context, AddRoom.id);
        if (id == 2) Navigator.pushNamed(context, ImageGallery.id);
      },
    );
  }
}

class ImageDialog extends StatelessWidget {
  final imgPath;
  ImageDialog(this.imgPath);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage(imgPath), fit: BoxFit.cover)),
      ),
    );
  }
}
