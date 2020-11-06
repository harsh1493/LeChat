import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:le_chat/constants.dart';
import 'package:le_chat/screens/pages/nw_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat_messages.dart';

final _firestore = FirebaseFirestore.instance;

class AddRoom extends StatefulWidget {
  @override
  static const String id = 'add_room';
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Contact> contactList = [];

  void populateContactList() async {
    await for (var snapshots in _firestore.collection('users').snapshots()) {
      for (var user in snapshots.docs) {
        setState(() {
          if (user.data()['email'] != _auth.currentUser.email) {
            contactList.add(Contact(
              img: user.data()['photoUrl'] == null
                  ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                  : user.data()['photoUrl'],
              name: user.data()['username'] == null
                  ? user.data()['email']
                  : user.data()['username'],
              isAdmin: false,
              isUser: true,
              mobile: user.data()['mobile'],
              email: user.data()['email'],
              uid: user.data()['uid'],
            ));
          }
          //print(user.data().toString());
          print('populate called');
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    populateContactList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      print('size${contactList.length}');
    });
    setState(() {});
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            sliver: SliverAppBar(
              title: Text('Select Contacts '),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Contact(
                img: 'addGroup.jpg',
                name: 'New group',
                isAdmin: true,
                isUser: false),
            Contact(
                img: 'add.png',
                name: 'New Contact',
                isAdmin: false,
                isUser: false),
            Column(
              children: contactList,
            )
          ])),
        ],
      ),
    );
  }
}

class Contact extends StatelessWidget {
  final String img;
  final String name;
  final bool isAdmin;
  final bool isUser;
  final String email;
  final String uid;
  final String mobile;

  final _auth = FirebaseAuth.instance;
  Contact({
    @required this.img,
    @required this.name,
    @required this.isAdmin,
    @required this.isUser,
    @required this.email,
    @required this.uid,
    @required this.mobile,
  });

  void createRoom(BuildContext context) async {
    var doc1 = await _firestore.collection('users').doc(uid).get();
    var doc2 =
        await _firestore.collection('users').doc(_auth.currentUser.uid).get();

    // await for (var snapshots in _firestore.collection('chatRoom').snapshots()) {
    //   print('-----------------------------------${snapshots.docs}');
    // }
    var r = await _firestore
        .collection('chatRoom')
        .doc(uid + _auth.currentUser.uid)
        .get();
    print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk:   ${r.exists}');
    var rn =
        r.exists ? uid + _auth.currentUser.uid : _auth.currentUser.uid + uid;
    var ref = _firestore.collection('chatRoom').doc(rn);

    await ref.set({
      //'roomName': name + '/' + _auth.currentUser.displayName,
      'roomName': uid + '/' + _auth.currentUser.uid,
      'groupDp': doc1.data()['photoUrl'],
      'justAdded': true,
      'isGroup': false
      // 'memberNames': {
      //   uid: name,
      //   _auth.currentUser.uid: _auth.currentUser.displayName
      // }
    }, SetOptions(merge: true));

    await ref.collection('members').doc(doc1.data()['uid']).set(
          doc1.data(),
        );
    await ref.collection('members').doc(doc2.data()['uid']).set(
          doc2.data(),
        );
    // await ref.collection('userMails').
    //await ref.collection('userMails').
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatMessages(
        roomId: rn,
        gdp: doc1.data()['photoUrl']==null?dpAlt:doc1.data()['photoUrl'],
        groupName: name,
        isGroup: false,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!isUser && isAdmin) {
          Navigator.pushNamed(context, NwGroup.id);
        } else if (isUser) {
          print('$name $uid');
          createRoom(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 2, 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage:
                  isUser ? NetworkImage(img) : AssetImage('images/$img'),
              backgroundColor: Colors.white,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              name,
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
