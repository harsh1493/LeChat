import 'package:le_chat/screens/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupInfoScreen extends StatefulWidget {
  static const String id = 'group_info_screen';
  @override
  _GroupInfoScreenState createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Stack(children: [
              FittedBox(
                child: Hero(
                  tag: 'group',
                  child: Image.asset(
                    'images/group.webp',
                    fit: BoxFit.contain,
                  ),
                ),
                fit: BoxFit.fill,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    // /color: Colors.green,
                    // height: 100,
                    // width: 690,
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          alignment: Alignment.topLeft,
                          icon: Icon(
                            Icons.arrow_back,
                            size: 35,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          alignment: Alignment.topLeft,
                          icon: Icon(
                            Icons.add_circle,
                            size: 35,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Slivers.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //color: Colors.green,
                    height: 100,
                    // width: 680,
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(10),
                    margin:
                        EdgeInsets.only(top: 0, bottom: 40, left: 10, right: 0),
                    child: Text(
                      'Flutter Group',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ]),
          ),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'hello',
                    style: TextStyle(color: Colors.black, fontSize: 45),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
