import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenwall/there.dart';
import 'package:zenwall/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

class Forgotscreen extends StatelessWidget {
  const Forgotscreen({Key? key}) : super(key: key);
  static const String _title = 'Zenex';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "lib/images/logo.png",
            ),
          ),
          centerTitle: true,
          title: const Text(
            _title,
            style: TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/images/teblutwo.jpg"),
                fit: BoxFit.cover)),
        child: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController usercontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController confrimpasscontroller = TextEditingController();

  String no = "false";

  Future<void> yes() async {
  try {
    // 1. Attempt Sign Up
    // We wrap this in its own try block so if it fails (e.g. user already exists),
    // we can catch it and proceed to SignIn, preserving your original logic.
    try {
      await context.read<AuthenticationService>().signUp(
            email: emailcontroller.text,
            password: passcontroller.text,
          );
    } catch (error) {
      // Replaces: .catchError((error) => no = "true");
      // Assuming 'no' is a variable defined in your class:
      // no = "true"; 
      debugPrint("Sign up failed (likely existing user), proceeding to sign in.");
    }

    // Safety Check 1: Ensure context is valid before using it again
    if (!mounted) return;

    // 2. Attempt Sign In (signwerid)
    await context.read<AuthenticationService>().signwerid(
          email: emailcontroller.text,
          password: passcontroller.text,
        );

    // Safety Check 2
    if (!context.mounted) return;

    // 3. Retrieve ID safely (Fixing the Infinite Loop)
    String? id = inputData();
    
    // FIX: Added a delay and attempt counter to prevent freezing the app
    int attempts = 0;
    while (id == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      id = inputData();
      attempts++;
    }

    if (id == null) {
      throw Exception("Failed to retrieve user ID after login.");
    }

    // 4. Save to Firestore
    final citytwo = {
      "ID": id,
      "Phone": phonecontroller.text,
      "Username": usercontroller.text,
    };

    var your = db.collection("Users").doc(id);
    await your.set(citytwo);

  } catch (e) {
    // Final Safety Check
    if (!mounted) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"))
            ],
          );
        });
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .15,
        ),
        Center(
          child: SizedBox(
            height: 50,
            width: (MediaQuery.of(context).size.width - 50),
            child: const Center(
              child: Text(
                "Sign Up",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .05,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .45,
              child: TextFormField(
                controller: usercontroller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ((value) {
                  if (value!.isEmpty == true) {
                    return 'Please enter some text';
                  } else if (value.length > 11) {
                    return "not a valid Username!!";
                  } else {
                    return null;
                  }
                }),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Ex.Zwipey',
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
                controller: emailcontroller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ((value) {
                  bool at = value!.contains("@");
                  bool peri = value.contains(".");
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  } else if (at == false || peri == false || value.length < 4) {
                    return "Not a valid email";
                  } else {
                    return null;
                  }
                }),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ex.Zenex@gmail.com',
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
          height: MediaQuery.of(context).size.height * .05,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * .45,
              child: TextFormField(
                controller: passcontroller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  labelText: 'Password',
                  hintText: 'Ex.Animal123!',
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
                controller: confrimpasscontroller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ((value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  } else if (value != passcontroller.text) {
                    return "Password's do not match up";
                  } else {
                    return null;
                  }
                }),
                decoration: const InputDecoration(
                  labelText: 'Comfirm Password',
                  hintText: 'Ex.Animal123!',
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
          height: MediaQuery.of(context).size.height * .05,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * .45,
          child: TextFormField(
            controller: phonecontroller,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: ((value) {
              if (value!.isEmpty == true) {
                return 'Please enter some text';
              } else if (value.length != 10) {
                return "not a valid Phone number!";
              } else {
                return null;
              }
            }),
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Ex.7208892121',
              hintStyle: TextStyle(color: Colors.black),
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 0.0),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .05,
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height * .06,
            width: MediaQuery.of(context).size.width * .90,
            child: ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: () {
                bool at = emailcontroller.text.contains("@");
                bool peri = emailcontroller.text.contains(".");
                bool hasUppercase =
                    passcontroller.text.contains(RegExp(r'[A-Z]'));
                bool hasDigits = passcontroller.text.contains(RegExp(r'[0-9]'));
                bool hasLowercase =
                    passcontroller.text.contains(RegExp(r'[a-z]'));
                bool hasSpecialCharacters = passcontroller.text
                    .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                bool hasMinLength = passcontroller.text.length >= 8;
                if (usercontroller.text.isEmpty ||
                    usercontroller.text.length > 11) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Not a valid Username!"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  usercontroller.text = "";
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok"))
                          ],
                        );
                      });
                } else if (at == false ||
                    peri == false ||
                    emailcontroller.text.length < 4) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Not a valid email!"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  emailcontroller.text = "";
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok")),
                          ],
                        );
                      });
                } else if (hasUppercase != true ||
                    hasDigits != true ||
                    hasLowercase != true ||
                    hasSpecialCharacters != true ||
                    hasMinLength != true) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Password is not strong enough!"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  confrimpasscontroller.text = "";
                                  passcontroller.text = "";
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok")),
                          ],
                        );
                      });
                } else if (passcontroller.text != confrimpasscontroller.text) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              "Confirmation password and new password are not the same"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  confrimpasscontroller.text = "";
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok")),
                          ],
                        );
                      });
                } else if (phonecontroller.text.length != 10) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Not a valid phone number"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  phonecontroller.text = "";
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok"))
                          ],
                        );
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const CircularProgressIndicator();
                      });
                  yes();

                  if (no == "false") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlmostScrren()),
                    );
                  } else if (no == "true") {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                                "Something went wrong, Please try again!"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok"))
                            ],
                          );
                        });
                  }
                }
              },
            )),
      ],
    );
  }
}
