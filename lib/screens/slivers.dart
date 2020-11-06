import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:le_chat/screens/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

String groupName;
String photoUrl;
List<String> admins = [];
final _firestore = FirebaseFirestore.instance;

class Slivers extends StatefulWidget {
  static const String id = 'slivers';
  final roomId;
  final gdp;
  final name;
  final isGroup;
  Slivers(
      {@required this.roomId,
      @required this.gdp,
      @required this.name,
      @required this.isGroup});
  @override
  _SliversState createState() => _SliversState();
}

class _SliversState extends State<Slivers> {
  List<Contact> contacts = [];
  final _auth = FirebaseAuth.instance;
  ScrollController _scrollController;
  List<String> users = [];

  // void leaveGroup()async{
  // implement it
  //
  // }

  void getAdmmins() async {
    var doc = await _firestore.collection('chatRoom').doc(widget.roomId).get();
    //admins = doc.data()['admins'].toList();
    for (var s in doc.data()['admins']) {
      print(s);
      admins.add(s);
    }
    print(admins);
  }

  void usersStream() async {
    await for (var snapshot in _firestore
        .collection('chatRoom')
        .doc(widget.roomId)
        .collection('members')
        .snapshots()) {
      for (var user in snapshot.docs) {
        var doc1 = await _firestore
            .collection('users')
            .doc(user.id)
            .get()
            .then((doc1) {
          print(doc1.data()['username']);
          setState(() {
            print('${user.id} in $admins');

            if (user.data()['email'] == _auth.currentUser.email) {
              contacts.add(Contact(
                isUser: true,
                isAdmin: admins.contains(user.id),
                img: _auth.currentUser.photoURL == null
                    ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                    : _auth.currentUser.photoURL,
                name: 'You',
              ));
            } else {
              contacts.add(Contact(
                  isUser: true,
                  isAdmin: admins.contains(user.id),
                  img: doc1.data()['photoUrl'] == null
                      ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                      : doc1.data()['photoUrl'],
                  name: doc1.data()['username']));
            }
          });
        });
      }
    }
  }

  void leaveGroup() async {
    var doc = _firestore
        .collection('chatRoom')
        .doc(widget.roomId)
        .collection('members')
        .doc(_auth.currentUser.uid)
        .delete();
    _firestore
        .collection('chatRoom')
        .doc(widget.roomId)
        .collection('userMails')
        .doc(_auth.currentUser.uid)
        .delete();
    var room = _firestore.collection('chatRoom').doc(widget.roomId);
    var g = await room.get();
    List<String> adminList = [];
    for (var x in g.data()['admins']) {
      if (x != _auth.currentUser.uid) {
        adminList.add(x);
      }
    }

    room.set({'admins': adminList}, SetOptions(merge: true));
  }
  //void populateMedia() async

  Widget buildFAB() {
    final double defaultTopMargin = 256.0 - 4.0;
    //pixels from top where scaling should start
    final double scaleStart = 96.0;
    //pixels from top where scaling should end
    final double scaleEnd = scaleStart / 2;
    Color color = Colors.blueAccent;
    double top = 236.0;
    double scale = 1.0;
    bool expanded = true;
    if (_scrollController.hasClients) {
      double offset = _scrollController.offset;
      top -= offset;
      if (offset < defaultTopMargin - scaleStart) {
        //offset small => don't scale down
        scale = 1.0;
      } else if (offset < defaultTopMargin - scaleEnd) {
        //offset between scaleStart and scaleEnd => scale down
        scale = (defaultTopMargin - scaleEnd - offset) / scaleEnd;
      } else {
        //offset passed scaleEnd => hide fab
        scale = 1;
        color = Colors.black26;
        expanded = false;
      }
    }
    return Positioned(
      top: top,
      right: 16,
      child: Transform(
        transform: new Matrix4.identity()..scale(scale),
        alignment: Alignment.center,
        child: expanded
            ? FloatingActionButton(
                onPressed: () {
                  Edit(
                      context,
                      EditDpWidget(
                        notifyParent: refresh,
                        roomId: widget.roomId,
                      ));
                },
                backgroundColor: color,
                child: new Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              )
            : IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  Edit(
                    context,
                    EditDpWidget(
                      notifyParent: refresh,
                      roomId: widget.roomId,
                    ),
                  );
                }),
      ),
    );
  }

  refresh() async {
    setState(() {});
  }

  @override
  void initState() {
    admins = [];
    photoUrl = null;
    //admins = [];
    // TODO: implement initState
    getAdmmins();
    usersStream();
    print(users);
    //populateUserList();
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //populateUserList();
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      print('add member');
                    },
                  )
                ],
                pinned: true,
                expandedHeight: 240,
                leading: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    alignment: Alignment.topRight,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'group',
                    child: Image.network(
                      photoUrl == null ? widget.gdp : photoUrl,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: Padding(
                    padding: const EdgeInsets.only(
                        left: 45.0, right: 0.0, top: 0.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                widget.isGroup
                    ? Card(
                        // color: Colors.blueAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            'Add group description',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 5,
                ),
              ])),
              SliverToBoxAdapter(
                child: Card(
                  child: MediaStream(
                    roomId: widget.roomId,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Card(
                    // color: Colors.blueAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Encryption',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Messages and calls are end-to-end encrypted',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.lock,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  !widget.isGroup
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About and phone number',
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 175, 156, 1),
                                      fontSize: 15),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Sleeping',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'September 4',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 15),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 0),
                                  width: double.infinity,
                                  height: 0.35,
                                  color: Colors.white,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '+91 8962372084',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'mobile',
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.message,
                                              color: Colors.white,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context)),
                                        IconButton(
                                            icon: Icon(Icons.call,
                                                color: Colors.white),
                                            onPressed: () => print('call')),
                                        IconButton(
                                            icon: Icon(Icons.videocam,
                                                color: Colors.white),
                                            onPressed: () =>
                                                print('video call')),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  widget.isGroup
                      ? Card(
                          // color: Colors.blueAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.isGroup
                                    ? Wrap(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 0, 0, 10),
                                            child: Text(
                                              '${contacts.length} participants',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Contact(
                                            isAdmin: false,
                                            isUser: false,
                                            name: 'Add Contacts',
                                            img: 'add.png',
                                          ),
                                          SizedBox(
                                            height: 1,
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Contact(
                                            isAdmin: false,
                                            isUser: false,
                                            name: 'Invite via link',
                                            img: 'inviteLink.png',
                                          ),
                                          SizedBox(
                                            height: 1,
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                                Wrap(
                                  children: contacts,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  Card(
                    // color: Colors.blueAccent,
                    child: InkWell(
                      onTap: () {
                        if (widget.isGroup) {
                          print('Leave');
                          leaveGroup();
                        } else {
                          print('Block');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              widget.isGroup ? Icons.exit_to_app : Icons.block,
                              color: Colors.grey,
                              size: 30,
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              widget.isGroup ? 'Exit group' : 'Block',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    // color: Colors.blueAccent,
                    child: InkWell(
                      onTap: () {
                        widget.isGroup
                            ? print('report group')
                            : print('report contact');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.thumb_down,
                              color: Colors.grey,
                              size: 30,
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              widget.isGroup
                                  ? 'Report group'
                                  : 'Report contact',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
          widget.isGroup ? buildFAB() : Container(),
        ],
      ),
    );
  }
}

class MediaStream extends StatelessWidget {
  final roomId;
  MediaStream({@required this.roomId});
  @override
  Widget build(BuildContext context) {
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
        final messages = snapshots.data.docs;
        List<StatelessWidget> media = [];
        for (var message in messages) {
          print(message.data().toString());
          final imgUrl = message.data()['mediaUrl'];
          final text = message.data()['text'];
          if (imgUrl != null)
            media.add(Container(
              margin: EdgeInsets.all(5),
              width: 80.0,
              color: imgUrl == null ? Colors.red : Colors.black87,
              child: imgUrl == null
                  ? Text(text)
                  : GestureDetector(
                      onTap: () async {
                        await showDialog(
                            context: context,
                            builder: (_) => Dialog(
                                  child: Image(
                                    image: NetworkImage(imgUrl),
                                  ),
                                ));
                      },
                      child: Image(
                        fit: BoxFit.fill,
                        width: double.infinity,
                        // image: AssetImage('images/group.webp'),
                        image: NetworkImage(imgUrl),
                      ),
                    ),
            ));
        }
        return media.length > 0
            ? Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Media,links and docs',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          media.length.toString(),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: media,
                      ),
                    ),
                  ],
                ),
              )
            : Container();
      },
    );
  }
}

class ContactStream extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final roomid;
  ContactStream({@required this.roomid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatRoom')
          .doc(roomid)
          .collection('members')
          .snapshots(),
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
        final contacts = snapshots.data.docs;
        List<StatelessWidget> members = [];

        for (var user in contacts) {
          var doc1 =
              _firestore.collection('users').doc(user.id).get().then((doc1) {
            print(doc1.data()['username']);
            if (user.data()['email'] == _auth.currentUser.email) {
              members.add(Contact(
                isUser: true,
                isAdmin: admins.contains(user.id),
                img: _auth.currentUser.photoURL,
                name: 'You',
              ));
            } else {
              members.add(Contact(
                  isUser: true,
                  isAdmin: admins.contains(user.id),
                  img: doc1.data()['photoUrl'] == null
                      ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                      : doc1.data()['photoUrl'],
                  name: doc1.data()['username']));
            }
          });
        }
        print(members.length);
        return Expanded(
            child: ListView(
          children: members,
        ));
      },
    );
  }
}

class Contact extends StatelessWidget {
  final String img;
  final String name;
  final bool isAdmin;
  final bool isUser;

  Contact(
      {@required this.img,
      @required this.name,
      @required this.isAdmin,
      @required this.isUser});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(name);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage:
                      isUser ? NetworkImage(img) : AssetImage('images/$img'),
                  backgroundColor: Colors.white70,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
            isAdmin
                ? Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Text(
                      "Group Admin",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : SizedBox(
                    width: 0,
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}

void Edit(context, Widget editWidget) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(20, 27, 40, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: editWidget,
          ),
        );
      });
}

class EditDpWidget extends StatefulWidget {
  final Function() notifyParent;
  final String roomId;
  EditDpWidget({@required this.notifyParent, @required this.roomId});
  @override
  _EditDpWidgetState createState() => _EditDpWidgetState();
}

class _EditDpWidgetState extends State<EditDpWidget> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String imageUrl;

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
    return Container(
      padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile photo',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Column(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      print('delete');
                      photoUrl =
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU';

                      widget.notifyParent();
                      await _firestore
                          .collection('chatRoom')
                          .doc(widget.roomId)
                          .set({
                        'groupDp':
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                      }, SetOptions(merge: true));

                      Navigator.pop(context);

                      setState(() {});
                    },
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    ' Remove \n   photo',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              SizedBox(
                width: 30,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      print('galary');
                      await uploadImage();
                      //await updateUserDp(imageUrl);
                      print(imageUrl);
                      widget.notifyParent();
                      setState(() {
                        photoUrl = imageUrl;
                      });
                      print(
                          'group id -------------------------------${widget.roomId}');
                      await _firestore
                          .collection('chatRoom')
                          .doc(widget.roomId)
                          .set({'groupDp': imageUrl}, SetOptions(merge: true));

                      Navigator.pop(context);
                      setState(() {});
                    },
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Galary \n',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              SizedBox(
                width: 30,
              ),
              Column(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      print('Camera');
                      await uploadCameraImage();
                      //await updateUserDp(imageUrl);
                      print(imageUrl);
                      widget.notifyParent();
                      setState(() {
                        photoUrl = imageUrl;
                      });
                      print(
                          'group id -------------------------------${widget.roomId}');
                      await _firestore
                          .collection('chatRoom')
                          .doc(widget.roomId)
                          .set({'groupDp': imageUrl}, SetOptions(merge: true));

                      Navigator.pop(context);
                      setState(() {});
                    },
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    ' Camera \n',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
