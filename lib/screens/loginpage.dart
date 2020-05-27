import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber;
  String verificationId, otp;
  ScrollController _controller = new ScrollController();
  TextEditingController otpc = new TextEditingController();
  TextEditingController phonec = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FadeInImage(
                  placeholder: AssetImage('assets/images/1920x1080.png'),
                  image: AssetImage('assets/images/login page image.png'),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 8,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    width: 320,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Theme(
                        data: ThemeData(primaryColor: Colors.green),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 8, bottom: 16),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: "LogIn",
                                ),
                              ),
                            ),
                            Container(
                              height: 150,
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                controller: _controller,
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  //Mobile Number
                                  Container(
                                    width: 304,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextField(
                                          controller: phonec,
                                          onChanged: (v) {
                                            this.phoneNumber = v;
                                          },
                                          maxLength: 10,
                                          keyboardType: TextInputType.number,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontFamily: 'LogIn',
                                              letterSpacing: 3),
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                              prefixText: '+91 ',
                                              labelText: 'Phone Number',
                                              labelStyle: TextStyle(
                                                  fontFamily: 'LogIn',
                                                  letterSpacing: 0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.red))),
                                        ),
                                        RaisedButton.icon(
                                            splashColor: Colors.black,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                    color: Colors.green)),
                                            onPressed: () {
                                              verifyPhone(phoneNumber);
                                            },
                                            icon: Icon(Icons.navigate_next,
                                                color: Colors.green),
                                            label: Text(
                                              "Next",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontFamily: 'LogIn',
                                                  fontSize: 16),
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 304,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextField(
                                          onChanged: (v) {
                                            this.otp = v;
                                          },
                                          controller: otpc,
                                          maxLength: 6,
                                          maxLines: 1,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                              fontFamily: 'LogIn',
                                              letterSpacing: 3),
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                              labelText: 'OTP',
                                              labelStyle: TextStyle(
                                                  fontFamily: 'LogIn',
                                                  letterSpacing: 0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.red))),
                                        ),
                                        RaisedButton.icon(
                                            splashColor: Colors.black,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                    color: Colors.green)),
                                            onPressed: () {
                                              AuthCredential credential =
                                                  PhoneAuthProvider
                                                      .getCredential(
                                                          verificationId:
                                                              verificationId,
                                                          smsCode: otp);
                                              FirebaseAuth.instance
                                                  .signInWithCredential(
                                                      credential)
                                                  .catchError((error) {
                                                print(123456789);
                                                showAlertDialog(context);
                                              });
                                            },
                                            icon: Icon(Icons.navigate_next,
                                                color: Colors.green),
                                            label: Text(
                                              "Verify",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontFamily: 'LogIn',
                                                  fontSize: 16),
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
        ));
  }

  Future<void> verifyPhone(pno) async {
    final PhoneVerificationCompleted verified = (AuthCredential ac) {
      FirebaseAuth.instance.signInWithCredential(ac).catchError((error) {
        showAlertDialog(context);
      });
    };

    final PhoneVerificationFailed verifailed = (AuthException ae) {
      print('${ae.message},12345678');
    };

    final PhoneCodeSent codeSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      _controller.animateTo(340,
          duration: Duration(milliseconds: 1000),
          curve: Curves.fastLinearToSlowEaseIn);
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeOut = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91' + pno,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verified,
        verificationFailed: verifailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: autoTimeOut);
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(16),
      title: Text("Wrong OTP"),
      content: Text("OTP you have entered is wrong.Please Try Again."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
