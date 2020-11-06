import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Contact(
                img: 'scene.jpg',
                name: 'Harsh',
              ),
              Contact(
                img: 'scene.jpg',
                name: 'Harsh',
              ),
              Contact(
                img: 'scene.jpg',
                name: 'Harsh',
              ),
              Contact(
                img: 'scene.jpg',
                name: 'Harsh',
              ),
            ]),
          )
        ],
      ),
    );
  }
}

class Contact extends StatelessWidget {
  final String img;
  final String name;
  Contact({@required this.img, @required this.name});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
          child: InkWell(
            onTap: () {
              print(name);
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: AssetImage('images/$img'),
                  backgroundColor: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(Icons.call_received),
                        Text(
                          'date ,time',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.videocam),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(
              height: 0,
              width: 70,
              child: Container(
                padding: EdgeInsets.all(15),
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 0.5,
              width: 327,
              child: Container(
                padding: EdgeInsets.all(15),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
