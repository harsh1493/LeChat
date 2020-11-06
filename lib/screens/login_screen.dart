import 'package:le_chat/screens/chat_screen.dart';
import 'package:le_chat/screens/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  String errorText;
  bool showSpinner = false;
  var errorMessageEmail;
  var errorMessagePassword;

  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _validateEmail = false;
  bool _validatePassword = false;

  var errorCodes = new Map();

  bool emailErrorExists = true;
  bool passwordErrorExists = true;
  bool hidden = false;
  @override
  void initState() {
    // TODO: implement initState
    errorCodes['218430393'] = 'Invalid Password';
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
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
                        fit: BoxFit.fitHeight,
                      ),
                      //height: 200.0,
                      // child: Icon(
                      //   Icons.flash_on,
                      //   color: Colors.yellow,
                      //   size: 200,
                      // ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  controller: _email,
                  onChanged: (value) {
                    email = value;
                    _email.text.isEmpty
                        ? _validateEmail = true
                        : _validateEmail = false;
                    setState(() {
                      _email.text.isEmpty
                          ? emailErrorExists = true
                          : emailErrorExists = false;
                    });

                    //Do something with the user input.
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
                    password = value;
                    _password.text.isEmpty
                        ? _validatePassword = true
                        : _validatePassword = false;
                    setState(() {
                      _password.text.isEmpty
                          ? passwordErrorExists = true
                          : passwordErrorExists = false;
                    });
                    //Do something with the user input.
                  },
                  style: TextStyle(color: Colors.blue),
                  obscureText: hidden ? false : true,
                  decoration: kTextFieldDecoration.copyWith(
                    errorStyle: TextStyle(color: Colors.grey),
                    errorText: _validatePassword
                        ? 'Password Can\'t Be Empty'
                        : passwordErrorExists
                            ? errorMessagePassword
                            : null,
                    hintText: 'Enter your password',
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
                    color: Colors.lightBlueAccent,
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
                              await _auth.signInWithEmailAndPassword(
                                  email: email, password: password);

                          if (newUser != null) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return HomePage(isFromReg: false,tabIndex: 1,);
                            }));
                          }
                          setState(() {
                            showSpinner = false;
                            //passwordErrorExists = false;
                          });
                        } catch (error) {
                          //print('Exception :$error');
                          setState(() {
                            showSpinner = false;
                          });
                          print('Error:${error.hashCode}');
                          print(error);
                          setState(() {
                            if (error.hashCode == 218430393) {
                              errorMessagePassword = 'Invalid password';
                              passwordErrorExists = true;
                            }
                            if (error.hashCode == 246276089) {
                              errorMessageEmail = 'User not found';
                              emailErrorExists = true;
                            }
                            if (error.hashCode == 540662271) {
                              errorMessageEmail =
                                  'The email address is badly formatted.';
                              emailErrorExists = true;
                            }
                            if (error.hashCode == 294110625) {
                              errorMessagePassword = 'Password is required';
                              passwordErrorExists = true;
                            }
                            if (error.hashCode != 540662271 &&
                                    error.hashCode != 246276089 ||
                                error.hashCode == 849834254) {
                              errorMessageEmail = '';
                              emailErrorExists = false;
                            }
                            if (error.hashCode != 294110625 &&
                                error.hashCode != 218430393) {
                              errorMessagePassword = '';
                            }
                          });
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Log In',
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
