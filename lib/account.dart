import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenwall/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:zenwall/changee.dart';
import 'package:zenwall/changep.dart';
import 'dart:io';

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

bool? inputDatatwo() {
  final User? user = auth.currentUser;
  final uid = user?.emailVerified;
  return uid;
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);
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

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(context);
      } 
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(context);
      } 
    });
  }

Future uploadFile(BuildContext context) async { // Added context parameter
  if (_photo == null) return;
  final id = inputData();
  final destination = '$id/profilePicture';

  try {
    final ref = FirebaseStorage.instance.ref(destination).child('file/');
    await ref.putFile(_photo!);
    printurl();
  } catch (e) {
    if (!context.mounted) return; // Safety check

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Upload Failed"),
            content: Text(e.toString()), // Displays the actual error message
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
                              "Account Information",
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
                                  child: InkWell(
                                    onTap: () => imgFromGallery(),
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
  TextEditingController passwordcontroller = TextEditingController();

  Future<void> deleteuser(BuildContext context, String passwo) async {
  final id = inputData(); // Get UID once at the start

  try {
    // --- 1. Delete Firestore Subcollections ---
    // We wrap these in their own try/catch blocks so a failure here 
    // doesn't stop the main account deletion process if you don't want it to.
    
    // Helper to delete a collection
    Future<void> deleteCollection(String collectionPath) async {
      try {
        var snapshots = await db
            .collection('Users')
            .doc(id)
            .collection(collectionPath)
            .get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Error deleting $collectionPath: $e");
      }
    }

    await deleteCollection("Cards");
    await deleteCollection("Purchases");
    await deleteCollection("Friends");

    // Delete the main User Document
    await db.collection('Users').doc(id).delete();

    // --- 2. Delete Storage Files ---
    try {
      final listResult = await FirebaseStorage.instance
          .ref('$id/profilePicture')
          .listAll();
          
      if (listResult.items.isNotEmpty) {
        // Delete the first file found (as per original logic)
        await FirebaseStorage.instance
            .ref(listResult.items.first.fullPath)
            .delete();
      }
    } catch (e) {
       debugPrint("Storage delete error: $e");
    }

    // --- 3. Authentication Deletion (Critical Step) ---
    final User? user = auth.currentUser;
    if (user != null) {
      // Re-authenticate first
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: passwo);
      
      await user.reauthenticateWithCredential(credential);
      
      // Check mounted before proceeding to delete
      if (!context.mounted) return; 

      // Delete the user
      await user.delete();

      // --- Success Dialog ---
      if (!context.mounted) return;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Complete!"),
              content: const Text("Your account has been deleted."),
              actions: [
                TextButton(
                    onPressed: () {
                      // Go back to the very first screen (usually login)
                      Navigator.popUntil(context,
                          (Route<dynamic> predicate) => predicate.isFirst);
                    },
                    child: const Text("Go Back"))
              ],
            );
          });
    }

  } on FirebaseAuthException catch (e) {
    // --- Auth Error Handling ---
    if (!context.mounted) return;

    String title = "Authentication Error";
    String message = e.message ?? "An error occurred";

    if (e.code == 'wrong-password') {
      title = "Wrong Password";
      message = "The password you entered is incorrect.";
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Try Again"))
            ],
          );
        });
  } catch (e) {
    // --- General Error Handling ---
    if (!context.mounted) return;
    
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Something went wrong"),
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

  Timer? timer;
  bool isEmailverified = false;

  @override
  void initState() {
    super.initState();
    isEmailverified = auth.currentUser!.emailVerified;
    if (!isEmailverified) {
      timer = Timer.periodic(const Duration(seconds: 6), (_) => checkvefied());
    }
  }

  Future checkvefied() async {
    await auth.currentUser!.reload();
    setState(() {
      isEmailverified = auth.currentUser!.emailVerified;
    });
    if (isEmailverified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

 Future sendVeficationEmail() async {
    final User? user = auth.currentUser;
    final uid = user?.email;
    String tit = "A verification email has been sent to $uid's inbox!";

    try {
      // Wait for the email to send
      await user?.sendEmailVerification();
    } catch (e) {
      tit = "Something went wrong, please try again!";
    }
    
    // FIX: Check if the widget is still on screen before showing the dialog
    if (!mounted) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(tit),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("ok"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usercontroller = TextEditingController();
    TextEditingController phonecontroller = TextEditingController();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFE5B4),
        ),
        child: FutureBuilder(
            future: db.collection("Users").doc(inputData()).get().then((value) {
              return value.data()!["Username"];
            }),
            builder: (BuildContext context, AsyncSnapshot snapshot) =>
                isEmailverified == false
                    ? ListView(
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .53,
                                width: MediaQuery.of(context).size.width * .93,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color:
                                      const Color.fromARGB(255, 150, 135, 108),
                                ),
                                child: ListView(children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            sendVeficationEmail();
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Verify Email",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ChangeEmail()));
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Email",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Insert New Username"),
                                                    content: TextFormField(
                                                      controller:
                                                          usercontroller,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: ((value) {
                                                        if (value!.isEmpty ==
                                                            true) {
                                                          return 'Please enter some text';
                                                        } else if (value
                                                                .length >
                                                            11) {
                                                          return "not a valid Username!!";
                                                        } else {
                                                          return null;
                                                        }
                                                      }),
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'New Username',
                                                        hintText:
                                                            'Ex.Zenex@gmail.com',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  width: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            String tit =
                                                                "Complete!";
                                                            if (usercontroller
                                                                    .text
                                                                    .isEmpty ||
                                                                usercontroller
                                                                        .text
                                                                        .length >
                                                                    11) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          "Not a valid Username!"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(
                                                                      inputData())
                                                                  .update({
                                                                'Username':
                                                                    usercontroller
                                                                        .text
                                                                        .toString()
                                                              }).catchError(
                                                                (error) => tit =
                                                                    "Something went wrong, please try again",
                                                              );
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          tit),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          child: const Text(
                                                              "Submit"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Username",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Insert New Phone Number"),
                                                    content: TextFormField(
                                                      controller:
                                                          phonecontroller,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: ((value) {
                                                        if (value!.isEmpty ==
                                                            true) {
                                                          return 'Please enter some text';
                                                        } else if (value
                                                                .length !=
                                                            10) {
                                                          return "not a valid Phone number!";
                                                        } else {
                                                          return null;
                                                        }
                                                      }),
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'New Phone Number',
                                                        hintText:
                                                            'Ex.7208892121',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  width: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            String tit =
                                                                "Complete!";
                                                            if (phonecontroller
                                                                    .text
                                                                    .length !=
                                                                10) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          "Not a valid phone number"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(
                                                                      inputData())
                                                                  .update({
                                                                'Phone':
                                                                    phonecontroller
                                                                        .text
                                                                        .toString()
                                                              }).catchError(
                                                                (error) => tit =
                                                                    "Something went wrong, please try again",
                                                              );
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          tit),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          child: const Text(
                                                              "Submit"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Phone Number",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "You cant do this until you verify your email!"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("ok"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Password",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            context
                                                .read<AuthenticationService>()
                                                .signOut();
                                            Navigator.popUntil(
                                                context,
                                                (Route<dynamic> predicate) =>
                                                    predicate.isFirst);
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Logout",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Are you sure you want to delete your account? You wont be able to undo this. type in your password and click yes if your sure"),
                                                    content: TextFormField(
                                                      controller:
                                                          passwordcontroller,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: ((value) {
                                                        if (value!.isEmpty ==
                                                            true) {
                                                          return 'Please enter some text';
                                                        } else {
                                                          return null;
                                                        }
                                                      }),
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'Current Password',
                                                        hintText:
                                                            'Ex.Animals123',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  width: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            deleteuser(
                                                                context,passwordcontroller
                                                                    .text);
                                                          },
                                                          child: const Text(
                                                              "Yes")),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .50,
                                                      ),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("No"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Delete Account",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .53,
                                width: MediaQuery.of(context).size.width * .93,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color:
                                      const Color.fromARGB(255, 150, 135, 108),
                                ),
                                child: ListView(children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ChangeEmail()),
                                            );
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Email",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Insert New Username"),
                                                    content: TextFormField(
                                                      controller:
                                                          usercontroller,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: ((value) {
                                                        if (value!.isEmpty ==
                                                            true) {
                                                          return 'Please enter some text';
                                                        } else if (value
                                                                .length >
                                                            11) {
                                                          return "not a valid Username!!";
                                                        } else {
                                                          return null;
                                                        }
                                                      }),
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'New Username',
                                                        hintText:
                                                            'Ex.Zenex@gmail.com',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  width: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            String tit =
                                                                "Complete!";
                                                            if (usercontroller
                                                                    .text
                                                                    .isEmpty ||
                                                                usercontroller
                                                                        .text
                                                                        .length >
                                                                    11) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          "Not a valid Username!"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(
                                                                      inputData())
                                                                  .update({
                                                                'Username':
                                                                    usercontroller
                                                                        .text
                                                                        .toString()
                                                              }).catchError(
                                                                (error) => tit =
                                                                    "Something went wrong, please try again",
                                                              );
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          tit),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          child: const Text(
                                                              "Submit"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Username",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Insert New Phone Number"),
                                                    content: TextFormField(
                                                      controller:
                                                          phonecontroller,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: ((value) {
                                                        if (value!.isEmpty ==
                                                            true) {
                                                          return 'Please enter some text';
                                                        } else if (value
                                                                .length !=
                                                            10) {
                                                          return "not a valid Phone number!";
                                                        } else {
                                                          return null;
                                                        }
                                                      }),
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'New Phone Number',
                                                        hintText:
                                                            'Ex.7208892121',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  width: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            String tit =
                                                                "Complete!";
                                                            if (phonecontroller
                                                                    .text
                                                                    .length !=
                                                                10) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          "Not a valid phone number"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            } else {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(
                                                                      inputData())
                                                                  .update({
                                                                'Phone':
                                                                    phonecontroller
                                                                        .text
                                                                        .toString()
                                                              }).catchError(
                                                                (error) => tit =
                                                                    "Something went wrong, please try again",
                                                              );
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          tit),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text("Ok"))
                                                                      ],
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          child: const Text(
                                                              "Submit"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Phone Number",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ChangePassword()));
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Change Password",
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            context
                                                .read<AuthenticationService>()
                                                .signOut();
                                            Navigator.popUntil(
                                                context,
                                                (Route<dynamic> predicate) =>
                                                    predicate.isFirst);
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Logout",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .85,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.blue,
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Are you sure you want to delete your account? You wont be able to undo this. type in your password and click yes if your sure"),
                                                    content: TextFormField(
                                                      controller:
                                                          passwordcontroller,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: ((value) {
                                                        if (value!.isEmpty ==
                                                            true) {
                                                          return 'Please enter some text';
                                                        } else {
                                                          return null;
                                                        }
                                                      }),
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'Current Password',
                                                        hintText:
                                                            'Ex.Animals123',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  width: 0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            deleteuser(
                                                                context,passwordcontroller
                                                                    .text);
                                                          },
                                                          child: const Text(
                                                              "Yes")),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .50,
                                                      ),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("No"))
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const ListTile(
                                            trailing: FlutterLogo(),
                                            title: Text(
                                              "Delete Account",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ],
                      )),
      ),
    );
  }
}
