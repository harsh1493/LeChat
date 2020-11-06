// ignore: avoid_web_libraries_in_flutter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../chat_messages.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
String groupName;
String photoUrl;

class ConfirmNewGroup extends StatefulWidget {
  static const String id = 'confirm_new_group';
  final Map selectedContacts;
  ConfirmNewGroup({@required this.selectedContacts});
  @override
  _ConfirmNewGroupState createState() => _ConfirmNewGroupState();
}

class _ConfirmNewGroupState extends State<ConfirmNewGroup> {
  final _groupName = TextEditingController();
  List<ContactCard> selectedContacts = [];

  void populateSelected() {
    print(widget.selectedContacts.keys);
    for (var contacts in widget.selectedContacts.values) {
      print(contacts);
      selectedContacts.add(ContactCard(
          username: contacts['username'],
          photoUrl: contacts['photoUrl'],
          uid: contacts['uid']));
    }
  }

  void createGroup(BuildContext context) async {
    var doc = await _firestore.collection('chatRoom').add({
      //'roomName': name + '/' + _auth.currentUser.displayName,
      'roomName': _groupName.text,
      'groupDp': photoUrl == null
          ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
          : photoUrl,
      'justAdded': true,
      'isGroup': true,
      'admins': [_auth.currentUser.uid]
    });
    print(doc.id);
    var doc1 = await _firestore.collection('groups').doc(doc.id);
    await doc1.set({'groupName': _groupName.text, 'justAdded': true});
    var members = new Map();

    var you =
        await _firestore.collection('users').doc(_auth.currentUser.uid).get();
    await doc.collection('members').doc(_auth.currentUser.uid).set(you.data());
    doc
        .collection('userMails')
        .doc(_auth.currentUser.uid)
        .set({'email': _auth.currentUser.email});
    doc1
        .collection('members')
        .doc(_auth.currentUser.uid)
        .set({'username': _auth.currentUser.displayName});
    List<String> mems = [_auth.currentUser.uid.toString()];
    for (var contacts in widget.selectedContacts.values) {
      mems.add(contacts['uid']);
      var doc3 =
          await _firestore.collection('users').doc(contacts['uid']).get();
      await doc.collection('members').doc(contacts['uid']).set(doc3.data());

      var mem1 = doc.collection('userMails').doc(contacts['uid']);
      mem1.set({'email': doc3.data()['email']});

      var mem3 = doc1.collection('members').doc(contacts['uid']);
      mem3.set({'username': contacts['username']});
    }
    await doc.set({'members': mems}, SetOptions(merge: true));
    var group = await doc.get();

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatMessages(
        roomId: group.id,
        gdp: group.data()['groupDp'],
        groupName: group.data()['roomName'],
        isGroup: group.data()['isGroup'],
      );
    }));
  }

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    photoUrl = null;
    _groupName.clear();
    populateSelected();
    // print(widget.selectedContacts['h8eolpY1scdqca3YDyCO1dgWAg23']['username']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New group',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            Text(
              'Add Subject',
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Color.fromRGBO(20, 27, 40, 1),
                padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              photoUrl == null
                                  ? 'https://image.shutterstock.com/image-vector/camera-vector-icon-on-transparent-260nw-1149434012.jpg'
                                  : photoUrl,
                            ),
                          ),
                          onTap: () {
                            Edit(
                                context,
                                EditDpWidget(
                                  notifyParent: refresh,
                                ));
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white30, width: 1),
                              ),
                              hintText: 'Type group subject here.',
                            ),
                            controller: _groupName,
                            autofocus: true,
                            //initialValue: _auth.currentUser.displayName,
                            onChanged: (value) {
                              print(value);
                            },
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              size: 30,
                              color: Colors.white30,
                            ),
                            onPressed: () => print('No emoji'))
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Provide a group subject and optional group icon',
                      style: TextStyle(color: Colors.white30),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participants',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: selectedContacts,
                    )
                  ],
                ),
              )
            ],
          ),
          Positioned(
            top: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                print('create group');
                print(_groupName.text);
                print(photoUrl);
                createGroup(context);
              },
              backgroundColor: Color.fromRGBO(0, 175, 156, 1),
              child: new Icon(
                Icons.check_outlined,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final String username;
  final String photoUrl;
  final String uid;
  ContactCard(
      {@required this.username, @required this.photoUrl, @required this.uid});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(photoUrl == null
                ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU'
                : photoUrl),
            radius: 25,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            username,
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
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
  EditDpWidget({@required this.notifyParent});
  @override
  _EditDpWidgetState createState() => _EditDpWidgetState();
}

class _EditDpWidgetState extends State<EditDpWidget> {
  final _auth = FirebaseAuth.instance;
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
                      print(imageUrl);
                      widget.notifyParent();
                      setState(() {
                        photoUrl = imageUrl;
                      });
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
