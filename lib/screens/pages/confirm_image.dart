import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ConfirmImage extends StatefulWidget {
  static const String id = 'confirm_image';
  final String imageUrl;
  final String roomId;
  ConfirmImage({@required this.imageUrl, @required this.roomId});
  @override
  _ConfirmImageState createState() => _ConfirmImageState();
}

class _ConfirmImageState extends State<ConfirmImage> {
  final _comment = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    _comment.clear();
    print('image url --------------- ${widget.imageUrl}  ${widget.roomId}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                splashRadius: 25,
                icon: Icon(
                  Icons.crop_rotate_outlined,
                  color: Colors.white,
                ),
                onPressed: () => print('rotate')),
            IconButton(
                splashRadius: 25,
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.white,
                ),
                onPressed: () => print('emoji')),
            IconButton(
                splashRadius: 25,
                icon: Icon(
                  Icons.text_fields,
                  color: Colors.white,
                ),
                onPressed: () => print('add text')),
            IconButton(
                splashRadius: 25,
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () => print('edit')),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Image(
                    fit: BoxFit.fitWidth,
                    height: 400,
                    width: double.infinity,
                    image: NetworkImage(widget.imageUrl),
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Spacer(),
                Row(
                  children: [
                    IconButton(
                        splashRadius: 25,
                        icon: Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                        ),
                        onPressed: () => print('add image')),
                    Container(
                      color: Colors.white,
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: SizedBox(
                        width: 0.5,
                        height: 30,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          fillColor: Colors.red,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white30, width: 0.8),
                          ),
                          hintText: 'Add a caption',
                        ),
                        controller: _comment,
                        autofocus: true,
                        //initialValue: _auth.currentUser.displayName,
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: Color.fromRGBO(0, 175, 156, 1),
                      child: Icon(Icons.send),
                      onPressed: () {
                        print(
                            'message sent ${_comment.text} ${widget.imageUrl}');
                        _firestore
                            .collection('chatRoom')
                            .doc(widget.roomId)
                            .collection('messages')
                            .add({
                          'text': _comment.text,
                          'email': _auth.currentUser.email,
                          'timestamp': FieldValue.serverTimestamp(),
                          'username': _auth.currentUser.displayName,
                          'mediaUrl': widget.imageUrl
                          //'datetime':
                        });
                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
