import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:le_chat/screens/home_page.dart';
import 'package:le_chat/screens/pages/status_screen.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ConfirmStory extends StatefulWidget {
  static const String id = 'confirm_story';
  final List<Asset> images;
  ConfirmStory({@required this.images});
  @override
  _ConfirmStoryState createState() => _ConfirmStoryState();
}

class _ConfirmStoryState extends State<ConfirmStory> {
  final _comment = TextEditingController();
  var comment='';
  int imageIndex = 0;
  var storyItem=new Map();
  List<Map> storyItemList=[];
  List<String> imageUrls=[];
  List<String> captions=[];


  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  void populateImages() async{
    for(var x=0;x< widget.images.length;x++){
      captions.add('');
    }
    for(var x in  widget.images){
      print(x.identifier);
      var imgUrl=await postImage(x);
      print(imgUrl);
      imageUrls.add(imgUrl);
    }
  }
  
  void uploadStatus()async{
    var l=imageUrls.length;
   var ref=  _firestore.collection('stories').doc(_auth.currentUser.uid);
    await for(var snapshots in  ref.collection('storyItem').snapshots()){

      l=snapshots.docs.length+imageUrls.length;
      print(l);
      break;
    }

   await ref.set({
      'timeAdded':FieldValue.serverTimestamp(),
      'uid':_auth.currentUser.uid,
       'userName':_auth.currentUser.displayName,
     'storyThumb':imageUrls[0],
     'storyLength':l,
    },SetOptions(merge: true));
   for(var x=0;x< widget.images.length;x++) {

     await ref.collection('storyItem').doc(imageUrls[x].toString().substring(imageUrls[x].length-5)).set({
       'caption':captions[x]==null?'':captions[x],
       'imageUrl':imageUrls[x],
       'type':captions[x]==''?'text':'pageImage',
        'title':''
     });
   }

   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return HomePage(
       isFromReg: false,
       tabIndex: 2,
     );
   }));
  }

  @override
  void initState() {
    populateImages();
    // TODO: implement initState
    _comment.clear();
    super.initState();
  }

  Widget buildListView() {
    print(widget.images.length);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.images.length,
      itemBuilder: (BuildContext context, int index) {
        //return AssetThumb(asset: widget.images[index], width: 50, height: 50);
        return Container(
          height: 10,
          color: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(imageUrls);
    print(captions);
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
      body: Stack(
        children:[
          SingleChildScrollView(
          child: Center(
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      //child: Image(image: AssetImage(widget.images[imageIndex].),),
                      child: AssetThumb(
                        width: 300,
                        height: 300,
                        asset: widget.images[imageIndex],
                        quality: 100,
                      ),
                    ),
                  ),
                  // Spacer(),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(
                            splashRadius: 25,
                            icon: Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                            ),
                            onPressed: ()  {

                            }),
                        Container(
                          color: Colors.white,
                          margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: SizedBox(
                            width: 0.5,
                            height: 30,
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
                              setState(() {
                                comment=value;
                                captions[imageIndex]=value;
                              });


                            },
                          ),
                        ),
                        FloatingActionButton(
                            backgroundColor: Color.fromRGBO(0, 175, 156, 1),
                            child: Icon(Icons.send),
                            onPressed: ()async {
                              print('add image');
                              await uploadStatus();
                            }),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 80,
                      padding: EdgeInsets.all(5),
                      child: Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.images.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  imageIndex = index;
                                  _comment.text=captions[index];
                                  print(widget.images[index].identifier);
                                });
                              },
                              child: Container(
                                decoration: index == imageIndex
                                    ? BoxDecoration(
                                        border:
                                            Border.all(color: Colors.blueAccent))
                                    : null,
                                padding: EdgeInsets.all(2),
                                child: AssetThumb(
                                    asset: widget.images[index],
                                    width: 50,
                                    height: 50),
                              ),
                            );
                            // return Container(
                            //   height: 10,
                            //   color: Colors.red,
                            // );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Center(child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Text(captions[imageIndex],style: TextStyle(color: Colors.yellow,fontSize: 50),),
        ))
        ]
      ),
    );
  }
}
