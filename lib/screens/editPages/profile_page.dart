import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

final _firestore = FirebaseFirestore.instance;

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_page';
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;

  void setUserProfile(String userName, String photoUrl) async {
    var user = _auth.currentUser;
    try {
      await user.updateProfile(
          displayName:
              userName == null ? _auth.currentUser.displayName : userName,
          photoURL: photoUrl == null ? _auth.currentUser.photoURL : photoUrl);
    } catch (e) {
      print(e);
    }
  }

  void updateUserName(String newName) async {
    _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get()
        .then((value) => print(value.data()['email']));

    await _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .update({'mobile': '8962372084', 'username': newName});
  }

  @override
  void initState() {
    // TODO: implement initState
    // updateUserName('hello');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(children: [
                StreamBuilder<User>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snapshot) {
                      return CircleAvatar(
                        // backgroundImage: AssetImage(_auth.currentUser.photoURL),
                        backgroundImage: NetworkImage(_auth
                                    .currentUser.photoURL ==
                                null
                            ? "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU"
                            : _auth.currentUser.photoURL),
                        radius: 80,
                      );
                    }),
                Positioned(
                  top: 10,
                  right: 10,
                  bottom: -101,
                  left: 100,
                  child: FloatingActionButton(
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        print('Upload Image');
                        Edit(context, EditDpWidget());
                      }),
                ),
              ]),
            ),
            InkWell(
              onTap: () {
                print('Edit name');
                Edit(context, EditNameWidget());
              },
              child: Card(
                // color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 35,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Name ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              StreamBuilder<User>(
                                stream: FirebaseAuth.instance.userChanges(),
                                builder: (context, user) {
                                  return Text(
                                    _auth.currentUser.displayName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Text(
                        '                   This name will be visible to your WhatsApp \n                   contacts only ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                print('Edit status');
              },
              child: Card(
                // color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 35,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'About ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Sleeping',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.edit,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                print('Edit mobile number');
              },
              child: Card(
                // color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.call,
                        color: Colors.grey,
                        size: 30,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mobile Number ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            _auth.currentUser.phoneNumber == null ||
                                    _auth.currentUser.phoneNumber == ""
                                ? '+91 8962372084'
                                : _auth.currentUser.phoneNumber,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.edit,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

//bottom sheet widget to update name
class EditNameWidget extends StatefulWidget {
  @override
  _EditNameWidgetState createState() => _EditNameWidgetState();
}

class _EditNameWidgetState extends State<EditNameWidget> {
  final _auth = FirebaseAuth.instance;
  String name;
  final _name = TextEditingController();
  bool isUpdated = false;

  void setUserProfile(String userName, String photoUrl) async {
    var user = _auth.currentUser;
    try {
      await user.updateProfile(
          displayName:
              userName == null ? _auth.currentUser.displayName : userName,
          photoURL: photoUrl == null ? _auth.currentUser.photoURL : photoUrl);
      await _auth.currentUser.reload();
      isUpdated = true;
    } catch (e) {
      print(e);
    }
  }

  //for users collection
  void updateUserName(String newName) async {
    _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get()
        .then((value) => print(value.data()['email']));

    await _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .update({'mobile': '8962372084', 'username': newName});
  }

  @override
  void initState() {
    // TODO: implement initState
    name = _auth.currentUser.displayName;
    _name.text = name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.black45,
      padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your name',
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          TextFormField(
            controller: _name,
            autofocus: true,
            //initialValue: _auth.currentUser.displayName,
            onChanged: (value) {
              print(value);
            },
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  print(name);
                },
              ),
              SizedBox(
                width: 20,
              ),
              InkWell(
                child: Text('Save', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    setUserProfile(_name.text, null);
                    updateUserName(_name.text);

                    Navigator.pop(context);
                    //Navigator.pop(context);
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

//bottom sheet widget to update profile picture
class EditDpWidget extends StatefulWidget {
  @override
  _EditDpWidgetState createState() => _EditDpWidgetState();
}

class _EditDpWidgetState extends State<EditDpWidget> {
  final _auth = FirebaseAuth.instance;
  String imageUrl;

  Future setUserProfile(String userName, String photoUrl) async {
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

  Future updateUserDp(String photoUrl) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser.uid)
        .update({'photoUrl': photoUrl});
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
                      print(_auth.currentUser.uid);
                      await setUserProfile(null,
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU');
                      await updateUserDp(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTHXi6kWCo1P3qJAuOnEAs6jWS1Dg1BqRkk8Q&usqp=CAU');
                      print(_auth.currentUser.photoURL);
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
                      await setUserProfile(null, imageUrl);
                      await updateUserDp(imageUrl);
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
                      await setUserProfile(null, imageUrl);
                      await updateUserDp(imageUrl);
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
