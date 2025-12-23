import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

String? inputDatatwo() {
  final User? user = auth.currentUser;
  final uid = user?.email;
  return uid;
}

class ChangePassword extends StatelessWidget {
  const ChangePassword({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.32,
                child: const MyStatefulWidget(),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.68,
                child: const MyStatefulWidgetTwo(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class MyStatefulWidgetTwo extends StatefulWidget {
  const MyStatefulWidgetTwo({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidgetTwo> createState() => _MyStatefulWidgetStateTwo();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String imageUrl = "";

  void printurl() async {
    try {
      final id = inputData();
      final ref =
          FirebaseStorage.instance.ref().child('$id/profilePicture/file');

      var url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      setState(() {
        imageUrl = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    printurl();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.32,
                child: Stack(
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.height * 0.32),
                      width: (MediaQuery.of(context).size.width),
                      foregroundDecoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('lib/images/blu.jpg'),
                        fit: BoxFit.fill,
                      )),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.08),
                          child: Center(
                            child: Center(
                                child: Text(
                              "Update Password",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.09),
                            )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.02),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  width:
                                      MediaQuery.of(context).size.width * 0.26,
                                  foregroundDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: imageUrl != ""
                                          ? NetworkImage(imageUrl)
                                          : const AssetImage(
                                                  'lib/images/pig.jpg')
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ]),
        ],
      ),
    );
  }
}

class _MyStatefulWidgetStateTwo extends State<MyStatefulWidgetTwo> {
  TextEditingController newpasswordcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();

  String result = "";

  Future<void> resetPassword(String passwo, String newPass) async {
    var message = "";
    try {
      final User? users = auth.currentUser;
      UserCredential? authResult = await users?.reauthenticateWithCredential(
        EmailAuthProvider.credential(
            email: users.email.toString(), password: passwo),
      );
      final newuse = authResult?.user;
      await newuse!
          .updatePassword(newPass)
          .then(
            (value) => message = 'Success',
          )
          .catchError((onError) => message = 'error');
    } on FirebaseAuthException {
      message = "Not Changed";
    }
    if (!mounted) return;
    if (message == "Not Changed") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Wrong Password"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      result = "";
                    },
                    child: const Text("Try Again"))
              ],
            );
          });
    } else if (message == "Success") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Complete!"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"))
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Something went wrong, please try again"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      result = "";
                    },
                    child: const Text("Try Again"))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFE5B4),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .04,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  child: TextFormField(
                    controller: passwordcontroller,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: ((value) {
                      if (value!.isEmpty == true) {
                        return 'Please enter some text';
                      } else {
                        return null;
                      }
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      hintText: 'Ex.Animals123',
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 0.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: newpasswordcontroller,
                    validator: (value) {
                      bool hasUppercase = value!.contains(RegExp(r'[A-Z]'));
                      bool hasDigits = value.contains(RegExp(r'[0-9]'));
                      bool hasLowercase = value.contains(RegExp(r'[a-z]'));
                      bool hasSpecialCharacters =
                          value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                      bool hasMinLength = value.length >= 8;
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      } else if (hasUppercase == true &&
                          hasDigits == true &&
                          hasLowercase == true &&
                          hasSpecialCharacters == true &&
                          hasMinLength == true) {
                        return null;
                      } else {
                        return "Password is not strong enough.";
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Ex.Animal123',
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 0.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .95,
              child: TextFormField(
                controller: confirmpasswordcontroller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ((value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  } else if (value != newpasswordcontroller.text) {
                    return "Password's do not match up";
                  } else {
                    return null;
                  }
                }),
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Ex.Animal123',
                  hintStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0), width: 0.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: const Color(0xff4169e1),
                ),
                width: MediaQuery.of(context).size.width * .90,
                child: TextButton(
                  onPressed: (() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        bool hasUppercase = newpasswordcontroller.text
                            .contains(RegExp(r'[A-Z]'));
                        bool hasDigits = newpasswordcontroller.text
                            .contains(RegExp(r'[0-9]'));
                        bool hasLowercase = newpasswordcontroller.text
                            .contains(RegExp(r'[a-z]'));
                        bool hasSpecialCharacters = newpasswordcontroller.text
                            .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                        bool hasMinLength =
                            newpasswordcontroller.text.length >= 8;
                        if (hasUppercase != true ||
                            hasDigits != true ||
                            hasLowercase != true ||
                            hasSpecialCharacters != true ||
                            hasMinLength != true) {
                          return AlertDialog(
                            title: const Text("Password is not strong enough!"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    confirmpasswordcontroller.text = "";
                                    newpasswordcontroller.text = "";
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok")),
                            ],
                          );
                        } else if (newpasswordcontroller.text ==
                            confirmpasswordcontroller.text) {
                          return AlertDialog(
                            title: const Text(
                                "Are you sure you want to change your password?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    resetPassword(passwordcontroller.text,
                                        newpasswordcontroller.text);
                                  },
                                  child: const Text("Yes")),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .50,
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No"))
                            ],
                          );
                        } else {
                          return AlertDialog(
                            title: const Text(
                                "Confirmation password and new password are not the same"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    confirmpasswordcontroller.text = "";
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok")),
                            ],
                          );
                        }
                      },
                    );
                  }),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
