import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:le_chat/screens/pages/stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'image_gallery.dart';

final _auth = FirebaseAuth.instance;

final _firestore = FirebaseFirestore.instance;

class StatusScreen extends StatefulWidget {
  static const String id = 'status_screen';

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {

  List<String> contacts=[];
  void populateStories()async{
    await for(var snapshot in _firestore.collection('stories').snapshots()){
      for(var story in snapshot.docs) {
        contacts.add(story.id);
        // var storyLength=0;
        // var url='';
        //  await for (var storyItems in story.reference.collection('storyItem').snapshots()) {
        //    print(storyItems.docs.first.data()['caption']);
        //   storyLength =storyItems.docs.length;
        //   url=storyItems.docs.first.data()['imageUrl'];
        //  }
      }
    }
  }
  
  @override
  void initState() {

    populateStories();

    // TODO: implement initState
    super.initState();
  } 
  
  @override
  Widget build(BuildContext context) {
   // print('!!!!!!!!!!!!!${stories.length}');
    print(contacts);
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              AddStatus(
                img: _auth.currentUser.photoURL,
                name: 'Harsh',
                contacts:contacts
              ),

            ]),
          ),

        ],
      ),
    );
  }
}

class AddStatus extends StatelessWidget {
  final String img;
  final String name;
  final List<String> contacts;
  AddStatus({@required this.img, @required this.name,@required this.contacts});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            print('Status');
            if(contacts.contains(_auth.currentUser.uid)){
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Stories(uid: _auth.currentUser.uid,);
            }));}
            else{
              Navigator.pushNamed(context, ImageGallery.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 0, 15),
            child: Row(
              children: [
                Container(
                  width: 52.0,
                  height: 52.0,
                  padding: const EdgeInsets.all(2.0), // borde width
                  decoration: new BoxDecoration(
                    color: const Color(0xFFFFFFFF), // border color
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    overflow: Overflow.visible,
                    children: [
                      CircleAvatar(
                        radius: 25.0,
                        backgroundImage: NetworkImage(img),
                        backgroundColor: Colors.white,
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          bottom: -20,
                          left: 30,
                          child: Icon(
                            Icons.bookmark,
                            color: Colors.white,
                            size: 27,
                          )),
                      Positioned(
                          top: 10,
                          right: 10,
                          bottom: -20,
                          left: 30,
                          child: Icon(
                            Icons.add_circle,
                            color: Colors.lightGreen,
                            size: 30,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My story',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Tap to add story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 35,
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Recent updates',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      //  Story(storyThumbUrl: dpAlt, userName: 'harsh', ts: null, uid: _auth.currentUser.uid, storyLength: '1'),
      StoryStream()
      ],
    );
  }
}
class Story extends StatelessWidget {
  final String storyThumbUrl;
  final String userName;
  final Timestamp ts;
  final String uid;
  final String storyLength;
  Story({@required this.storyThumbUrl,@required this.userName,@required this.ts,@required this.uid,@required this.storyLength});
  @override
  Widget build(BuildContext context) {
    print(storyLength+"  llllll   ");

    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    String s= formatter.format(DateTime.now())==formatter.format(ts.toDate())?'Today':formatter.format(ts.toDate()).toString();
    String i=ts.toDate().compareTo(DateTime.now()).toString();
    String time= (ts.toDate().hour%12).toString()+':'+(ts.toDate().minute<10?'0'+ts.toDate().minute.toString():ts.toDate().minute.toString())+(ts.toDate().hour%12>0?' AM':' PM');
    print(s+', '+time);
    return InkWell(
      onTap: (){
        print('story clicked');
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Stories(uid: uid,);
        }));
      },
      child: ListTile(
        leading: CircleAvatar( backgroundColor: Colors.black12,backgroundImage: AssetImage('images/$storyLength.png'),radius: 30,child: CircleAvatar(backgroundImage: NetworkImage(storyThumbUrl),radius: 25,)),
        title: Text(userName,style: TextStyle(color: Colors.white,fontSize: 20)),
        subtitle: Text(s+', '+time,style: TextStyle(color: Colors.grey,fontSize: 13),),
      ),
    );
  }
}


class StoryStream extends StatefulWidget {
  @override
  _StoryStreamState createState() => _StoryStreamState();
}

class _StoryStreamState extends State<StoryStream> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(stream:_firestore.collection('stories').snapshots() ,
      builder: (context,snapshots){
        if (!snapshots.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
          // ignore: missing_return
        }
        final stories=snapshots.data.docs;
        List<StatelessWidget> storyList=[];
        for(var story in stories){

          //int storyItemCount= story.reference.collection('storyItem').snapshots().length;
          storyList.add(Story(storyThumbUrl: story.data()['storyThumb'], userName: story.data()['userName'], ts: story.data()['timeAdded'], uid: story.data()['uid'], storyLength: story.data()['storyLength'].toString()));
         
        }
      return Column(children: storyList);
      } );
  }
}
