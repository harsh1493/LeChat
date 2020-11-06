import 'package:le_chat/screens/pages/confirm_story.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';

class ImageGallery extends StatefulWidget {
  static const String id = 'story_view';
  @override
  _ImageGalleryState createState() => new _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Detected';

  @override
  void initState() {
    loadAssets();
    super.initState();
  }

  Widget buildGridView() {
    print(images.length);
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = [];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Choose images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      print('no images ');

    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    print(resultList);
    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Confirm Images'),
          actions: [
            IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  print(images.length);
                  // Navigator.pushNamed(context, ConfirmStory.id,
                  //     arguments: {images: images});
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ConfirmStory(images: images);
                  }));
                })
          ],
        ),
        body: Column(
          children: <Widget>[
            // RaisedButton(
            //   child: Text("Pick images"),
            //   onPressed: loadAssets,
            // ),
            Expanded(
              child: buildGridView(),
            )
          ],
        ),
      ),
    );
  }
}
