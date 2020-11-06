import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:le_chat/main.dart';
import 'package:le_chat/screens/chat_screen.dart';
import 'package:le_chat/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User loggedInUser;
  String email;
  String password;
  bool showSpinner = false;
  var errorMessageEmail;
  var errorMessagePassword;

  bool emailErrorExists = true;
  bool passwordErrorExists = true;

  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _validateEmail = false;
  bool _validatePassword = false;

  bool hidden = false;

  bool emailVerification() {
    User user = _auth.currentUser;
    user.sendEmailVerification();
    print('USer : ${user.email}');
    if (user.emailVerified) {
      //addUser(user.email);

      return true;
    }
    return false;
  }

  void usersStream() async {
    await for (var snapshot in _firestore.collection('users').snapshots()) {
      for (var user in snapshot.docs) {
        print(user.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Firebase.initializeApp();
    usersStream();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        print(loggedInUser.displayName);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/welcome.jpg"),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image(
                        image: AssetImage(
                          'images/splash_i.png',
                        ),
                        height: 250,
                        width: 250,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  controller: _email,
                  onChanged: (value) {
                    //Do something with the user input.
                    email = value;
                    _email.text.isEmpty
                        ? _validateEmail = true
                        : _validateEmail = false;
                    setState(() {
                      _email.text.isEmpty
                          ? emailErrorExists = true
                          : emailErrorExists = false;
                    });
                  },
                  style: TextStyle(color: Colors.blue),
                  decoration: kTextFieldDecoration.copyWith(
                    errorStyle: TextStyle(color: Colors.grey),
                    errorText: _validateEmail
                        ? 'Email Can\'t Be Empty'
                        : errorMessageEmail,
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: Colors.blue,
                    ),
                    suffixIcon: Visibility(
                      visible: !emailErrorExists,
                      child: Icon(
                        Icons.check,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _password,
                  onChanged: (value) {
                    //Do something with the user input.
                    password = value;
                    _password.text.isEmpty
                        ? _validatePassword = true
                        : _validatePassword = false;

                    setState(() {
                      _password.text.isEmpty
                          ? passwordErrorExists = true
                          : passwordErrorExists = false;
                    });
                  },
                  obscureText: hidden ? false : true,
                  style: TextStyle(color: Colors.blue),
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password',
                    errorStyle: TextStyle(color: Colors.grey),
                    errorText: _validatePassword
                        ? 'Password Can\'t Be Empty'
                        : passwordErrorExists
                            ? errorMessagePassword
                            : null,
                    // errorText: errorMessagePassword,
                    prefixIcon: Icon(
                      Icons.lock_open,
                      color: Colors.blue,
                    ),
                    suffixIcon: Wrap(children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Visibility(
                          visible: !passwordErrorExists,
                          child: Icon(
                            Icons.check,
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            hidden
                                ? Icons.remove_red_eye
                                : FontAwesomeIcons.solidEyeSlash,
                            color: Colors.white,
                            size: hidden ? 20 : 15,
                          ),
                          onPressed: () {
                            setState(() {
                              hidden = !hidden;
                            });
                          }),
                    ]),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        //Implement registration functionality.
                        setState(() {
                          showSpinner = true;
                        });
                        print(email);
                        print(password);
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);

                          if (newUser != null) {
                            //Navigator.pushNamed(context, HomePage.id);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return HomePage(isFromReg: true,tabIndex: 1,);
                            }));
                            errorMessagePassword = '';
                            errorMessageEmail = '';
                          }
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          setState(() {
                            showSpinner = false;
                            if (e.hashCode == 328678433) {
                              errorMessagePassword =
                                  'Password should be at least 6 characters';
                              passwordErrorExists = true;
                            }
                            if (e.hashCode == 540662271) {
                              errorMessageEmail =
                                  'The email address is badly formatted.';
                              emailErrorExists = true;
                            }
                            if (e.hashCode == 86194409) {
                              errorMessageEmail =
                                  'The email address is already in use by another account.';
                              emailErrorExists = true;
                            }
                            if (e.hashCode == 889654280) {
                              errorMessagePassword = 'Enter password';
                              passwordErrorExists = true;
                            }
                          });
                          print(e);
                          print(e.hashCode);
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
