import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
class Stories extends StatefulWidget {
  final String uid;
  Stories({@required this.uid});
  static const String id = 'story_view';
  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  final storyController = StoryController();
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItemsz = [
      StoryItem.text(
        title: "I guess you'd love to see more of our food. That's great.",
        backgroundColor: Colors.blue,
      ),
      StoryItem.text(
        title: "Nice!\n\nTap to continue.",
        backgroundColor: Colors.red,
        textStyle: TextStyle(
          fontFamily: 'Dancing',
          fontSize: 40,
        ),
      ),
      StoryItem.pageImage(
        url:
            "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
        caption: "Still sampling",
        controller: storyController,
      ),
      StoryItem.pageImage(
          url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
          caption: "Working with gifs",
          controller: storyController),
      StoryItem.pageImage(
        url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
        caption: "Hello, from the other side",
        controller: storyController,
      ),
      StoryItem.pageImage(
        url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
        caption: "Hello, from the other side2",
        controller: storyController,
      ),
    ];
    return StoryItemStream(widget: widget, storyController: storyController);
  }
}

//Scaffold(
//       body: StoryView(
//         storyItems: items,
//         onStoryShow: (s) {
//           print("Showing a story");
//         },
//         onComplete: () {
//           print("Completed a cycle");
//           Navigator.pop(context);
//         },
//         progressPosition: ProgressPosition.top,
//         repeat: false,
//         controller: storyController,
//       ),
//     )

class StoryItemStream extends StatelessWidget {
  const StoryItemStream({
    Key key,
    @required this.widget,
    @required this.storyController,
  }) : super(key: key);

  final Stories widget;
  final StoryController storyController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('stories').doc(widget.uid).collection('storyItem').snapshots(),
      builder: (context,snapshots){
        if (!snapshots.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
          // ignore: missing_return
        }
        final storyItems=snapshots.data.docs;
        List<StoryItem> sItems=[];
        for(var storyItem in storyItems ){
          print('*********************${storyItem.data()['caption']} ${storyItem.data()['imageUrl']}');
          sItems.add(StoryItem.pageImage(url:storyItem.data()['imageUrl'] , controller: storyController,caption: storyItem.data()['caption']));
        }
        return StoryView(
          storyItems: sItems,
          onStoryShow: (s) {
            print("Showing a story");
          },
          onComplete: () {
            print("Completed a cycle");
            Navigator.pop(context);
          },
          progressPosition: ProgressPosition.top,
          repeat: false,
          controller: storyController,
        );
      },
    );
  }
}
