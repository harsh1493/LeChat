import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:le_chat/components/rounded_button.dart';
import 'package:translator/translator.dart';

final translator = GoogleTranslator();

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  AnimationController controller;
  Animation animation;

  String translatedText = 'Or via Social Link';

  Future<User> signIn(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    User userDetails = (await _auth.signInWithCredential(credential)).user;
    ProviderDetails providerInfo = ProviderDetails(userDetails.uid);
    List<ProviderDetails> providerData = List<ProviderDetails>();
    providerData.add(providerInfo);
    UserDetails details = UserDetails(
        providerDetails: userDetails.uid,
        userName: userDetails.displayName,
        photoUrl: userDetails.photoURL,
        providerData: providerData);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomePage(
        isFromReg: true,
        tabIndex: 1,
      );
    }));
    print(userDetails);
    return userDetails;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
      //upperBound: 100.0,//not applicable with animation object
    );

    //animation = ColorTween(begin: Colors.blueGrey, end: Colors.white70).animate(controller);
    animation = CurvedAnimation(
        parent: controller, curve: Curves.decelerate); //for curved animations
    //controller.reverse();//to reverse the animation
    controller.forward();

    controller.addListener(() {
      setState(() {});
      //print(controller.value);
      print(animation.value);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller
        .dispose(); //so that the controller dont consume resources in background after the screen is disposed or changed.
  }

  @override
  Widget build(BuildContext context) {
    //translate();
    return Scaffold(
      backgroundColor: Colors.white60,
      //backgroundColor: animation.value,//used with ColorTween animation object to trasform color property b/w 2 colors
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/welcome.jpg"),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image(
                        image: AssetImage(
                          'images/splash_i.png',
                        ),
                        height: 150 * animation.value,
                      ),
                      // child: Icon(
                      //   Icons.flash_on,
                      //   color: Colors.yellow,
                      //   size: 100 * animation.value,
                      // ),
                      //height: 60.0,
                      //height: animation.value * 200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: TypewriterAnimatedTextKit(
                      text: ['le Chat'],
                      //'${controller.value.toInt()}%',
                      textStyle: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                      isRepeatingAnimation: true,
                      speed: Duration(milliseconds: 400),
                      pause: Duration(milliseconds: 2000),
                      totalRepeatCount: 5,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 80.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                title: 'Log in',
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                  //Go to login screen.
                },
              ),
              RoundedButton(
                color: Colors.blueAccent,
                title: 'Register',
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
              ),
              SizedBox(
                height: 80,
              ),
              SizedBox(
                height: 15 * animation.value,
                child: Text(
                  translatedText,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    onPressed: () {
                      signIn(context)
                          .then((User user) => print(user))
                          .catchError((e) => print(e));
                    },
                    elevation: 2.0,
                    fillColor: Colors.red,
                    child: Icon(
                      FontAwesomeIcons.google,
                      size: animation.value * 22,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                  RawMaterialButton(
                    onPressed: () {},
                    elevation: 2.0,
                    fillColor: Color.fromRGBO(45, 117, 232, 1),
                    child: Icon(
                      FontAwesomeIcons.facebookF,
                      size: animation.value * 22,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                  RawMaterialButton(
                    onPressed: () {},
                    elevation: 2.0,
                    fillColor: Color.fromRGBO(50, 82, 167, 1),
                    child: Icon(
                      Icons.mail,
                      size: animation.value * 22,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UserDetails {
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final List<ProviderDetails> providerData;
  UserDetails(
      {@required this.providerDetails,
      @required this.userName,
      @required this.photoUrl,
      @required this.providerData});
}

class ProviderDetails {
  ProviderDetails(this.providerDetails);
  final String providerDetails;
}
