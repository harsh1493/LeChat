import 'dart:async';
import 'package:le_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool visible = false;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      setState(() {
        visible = true;
      });
    });
    Timer(
        Duration(seconds: 4),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => WelcomeScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(33, 31, 37, 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/splash_g.gif',
              width: 100,
              height: 100,
              fit: BoxFit.fitHeight,
            ),
            SizedBox(
              height: 20,
            ),
            AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 2000),
              child: Text(
                ' Le Chat ',
                style: TextStyle(
                  color: Colors.greenAccent,
                  decoration: TextDecoration.none,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
