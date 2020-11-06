import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:le_chat/screens/pages/confirm_new_group.dart';
import 'package:le_chat/screens/pages/nw_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

int members = 0;
List<String> memberList = [];
var memberDetails = new Map();
final _firestore = FirebaseFirestore.instance;

class NwGroup extends StatefulWidget {
  @override
  static const String id = 'nw_group';
  _NwGroupState createState() => _NwGroupState();
}

class _NwGroupState extends State<NwGroup> {
  final _firestore = FirebaseFirestore.instance;
  List<Contact> contactList = [];
  int mems = 0;

  void populateContactList() async {
    await for (var snapshots in _firestore.collection('users').snapshots()) {
      for (var user in snapshots.docs) {
        setState(() {
          contactList.add(Contact(
            img: user.data()['photoUrl'] == null
                ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                : user.data()['photoUrl'],
            name: user.data()['username'] == null
                ? user.data()['email']
                : user.data()['username'],
            isAdmin: false,
            isUser: true,
          ));
          //print(user.data().toString());
          print('populate called');
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    //populateContactList();
    members = 0;
    memberList = [];
    memberDetails = {};
    super.initState();
  }

  refresh() {
    setState(() {
      mems = members;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Group '),
            SizedBox(
              height: 5,
            ),
            Text(
              'Add participants',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ContactStream(
              refresh: refresh,
            )
          ],
        ),
      ),
      floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                backgroundColor: Theme.of(context).backgroundColor,
                tooltip: 'Add Group',
                onPressed: () {
                  print('group created');
                  print(memberList.length);
                  print(memberList);
                  // print(memberDetails);
                  if (memberDetails.isEmpty || memberDetails == {}) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.black,
                      content: Text(
                        "No contact selected.\nSelect atleast one contact",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ConfirmNewGroup(
                        selectedContacts: memberDetails,
                      );
                    }));
                  }
                },
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              )),
    );
  }
}

class ContactStream extends StatelessWidget {
  final Function() refresh;
  final _auth = FirebaseAuth.instance;
  ContactStream({@required this.refresh});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
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
        // List<StatelessWidget> chatRooms = [];
        List<Contact> contactList = [];
        for (var user in contacts) {
          if (user.id != _auth.currentUser.uid) {
            contactList.add(Contact(
              img: user.data()['photoUrl'] == null
                  ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                  : user.data()['photoUrl'],
              name: user.data()['username'] == null
                  ? user.data()['email']
                  : user.data()['username'],
              isAdmin: false,
              isUser: true,
              uid: user.id,
              notifyParent: refresh,
            ));
          }
        }
        return Expanded(
            child: ListView(
          children: contactList,
        ));
      },
    );
  }
}

class Contact extends StatefulWidget {
  final String img;
  final String name;
  final bool isAdmin;
  final bool isUser;
  final String uid;
  bool isSelected = false;
  final Function() notifyParent;

  Contact(
      {@required this.img,
      @required this.name,
      @required this.isAdmin,
      @required this.isUser,
      @required this.uid,
      @required this.notifyParent});

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> with SingleTickerProviderStateMixin {
  AnimationController rotationController;

  @override
  void initState() {
    // TODO: implement initState
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    //widget.isSelected = false;
    //widget.notifyParent();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //widget.notifyParent();
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ListTile(
        tileColor: Colors.black12.withOpacity(widget.isSelected ? 0.9 : 0),
        leading: Stack(children: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
            child: CircleAvatar(
              radius: 20.0,
              backgroundImage: widget.isUser
                  ? NetworkImage(widget.img)
                  : AssetImage('images/${widget.img}'),
              backgroundColor: Colors.white,
            ),
          ),
          Visibility(
            visible: widget.isSelected,
            child: Positioned(
              top: 10,
              right: 10,
              bottom: -16,
              left: 22,
              child: Icon(
                Icons.bookmark,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          Visibility(
            visible: widget.isSelected,
            child: Positioned(
              top: 9,
              right: 10,
              bottom: -16,
              left: 22,
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
                size: 20,
              ),
            ),
          ),
        ]),
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onTap: () {
          print('hello ${widget.name} ');
          setState(() {
            widget.isSelected ? members-- : members++;
            if (widget.isSelected) {
              memberList.remove(widget.name);
              memberDetails.remove(widget.uid);
            } else {
              memberList.add(widget.name);
              memberDetails[widget.uid] = {
                'uid': widget.uid,
                'username': widget.name,
                'photoUrl': widget.img
              };
            }

            widget.isSelected = !widget.isSelected;
            print('memebers      $members');
            rotationController.forward(from: 0.0);
            //memberList.add(widget.name);
            //widget.notifyParent();
            //Navigator.pushNamed(context, NwGroup.id);
          });
          //widget.notifyParent();
        },
      ),
    );
  }
}
