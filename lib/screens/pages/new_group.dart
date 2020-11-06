import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:le_chat/screens/pages/nw_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

int members = 0;

class NewGroup extends StatefulWidget {
  @override
  static const String id = 'new_group';
  _NewGroupState createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
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
    populateContactList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Group   $mems'),
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
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            Column(
              children: contactList,
            )
          ])),
        ],
      ),
    );
  }
}

class Contact extends StatefulWidget {
  final String img;
  final String name;
  final bool isAdmin;
  final bool isUser;
  NewGroup g;
  bool isSelected = false;

  Contact({
    @required this.img,
    @required this.name,
    @required this.isAdmin,
    @required this.isUser,
  });

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
    widget.isSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //tileColor: Colors.black.withOpacity(widget.isSelected ? 0.9 : 0),
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
            top: 10,
            right: 10,
            bottom: -16,
            left: 22,
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.grey,
              size: 19,
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
          widget.isSelected = !widget.isSelected;
          print('memebers      $members');
          rotationController.forward(from: 0.0);
          //Navigator.pushNamed(context, NwGroup.id);
        });
      },
    );
  }
}
