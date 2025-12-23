import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenwall/account.dart';
import 'package:zenwall/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenwall/credit.dart';
import 'package:zenwall/send.dart';
import 'package:zenwall/friends.dart';
import 'package:zenwall/crypto.dart';
import 'package:zenwall/help.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

Future<List<String>> _getData() async {
  List<String> fr = [];
  var result = await db
      .collection("Users")
      .doc(inputData())
      .collection("Purchases")
      .get();
  for (var res in result.docs) {
    fr.add(res.id.toString());
  }

  return (fr);
}

Future<List<Object?>> _gettata(String? iD) async {
  CollectionReference collectionRef =
      db.collection("Users").doc("$iD").collection("Purchases");
  // Get docs from collection reference
  QuerySnapshot querySnapshot = await collectionRef.get();

  // Get data from docs and convert map to List
  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

  return (allData);
}

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

class Homescreen extends StatelessWidget {
  const Homescreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyStatefulWidgetfinal(),
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

class MyStatefulWidgetThree extends StatefulWidget {
  const MyStatefulWidgetThree({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidgetThree> createState() => _MyStatefulWidgetStateThree();
}

class MyStatefulWidgetfinal extends StatefulWidget {
  const MyStatefulWidgetfinal({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidgetfinal> createState() => _MyStatefulWidgetStatefinal();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) return;

    final isClosed = state == AppLifecycleState.detached;

    if (isClosed) {
      context.read<AuthenticationService>().signOut();
    }
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
              body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff4169e1),
                  Color(0xffFFE5B4),
                ],
                stops: [0, 0],
              ),
            ),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: 100,
                          child: Card(
                            child: InkWell(
                              splashColor: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const FriendPage()),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  const Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 19.0),
                                      child: Text(
                                        "Account \nInfo",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 14.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Image.asset(
                                          "lib/images/card.png",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: 100,
                          child: Card(
                            child: InkWell(
                              splashColor: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SendPage()),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  const Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 19.0),
                                      child: Text(
                                        "Balance",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 14.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Image.asset(
                                          "lib/images/tf.png",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.33,
                          height: 100,
                          child: Card(
                            child: InkWell(
                              splashColor: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CreditPage()),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  const Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 19.0),
                                      child: Text(
                                        "Zenex Wallet",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 14.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Image.asset(
                                          "lib/images/card.png",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ],
            ),
          ));
        });
  }
}

class _MyStatefulWidgetStateTwo extends State<MyStatefulWidgetTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xffFFE5B4),
        ),
        child: FutureBuilder(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Column(children: [
              const SizedBox(height: 5),
              Center(
                child: Container(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: const Color(0xff4169e1),
                  ),
                  child: const Center(
                      child: Text(
                    "Recent Transactions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .38,
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                      future: _gettata(inputData()),
                      builder: (context, AsyncSnapshot lnapshots) {
                        if (snapshot.hasData && lnapshots.hasData) {
                          if (snapshot.data.length == 0) {
                            return Container(
                              height: 0,
                              width: (MediaQuery.of(context).size.width - 50),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: const Color.fromARGB(255, 150, 135, 108),
                              ),
                              child: Center(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .20,
                                  width:
                                      (MediaQuery.of(context).size.width - 50),
                                  child: const Text(
                                    "No Recent Transactions",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container(
                            height: 0,
                            width: (MediaQuery.of(context).size.width - 50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: const Color.fromARGB(255, 150, 135, 108),
                            ),
                            child: ListView.builder(
                                padding: const EdgeInsets.all(0.0),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  // We grab the specific transaction data once here
                                  var transactionData = lnapshots.data[
                                      snapshot.data
                                          .indexOf(snapshot.data[index])];

                                  if (transactionData["Transfer"] == true) {
                                    return SizedBox(
                                      child: Card(
                                        child: ExpansionTile(
                                          title: Text(transactionData["From"]
                                              .toString()),
                                          children: <Widget>[
                                            Column(
                                              children: [
                                                Center(
                                                  child: ListTile(
                                                    trailing:
                                                        const FlutterLogo(),
                                                    title: Text(
                                                        "Money Spent: ${transactionData["Value"]}"),
                                                  ),
                                                ),
                                                Center(
                                                  child: ListTile(
                                                    trailing:
                                                        const FlutterLogo(),
                                                    title: Text(
                                                        "Card Used: ${transactionData["Card Used"]}"),
                                                  ),
                                                ),
                                                Center(
                                                  child: ListTile(
                                                    trailing:
                                                        const FlutterLogo(),
                                                    title: Text(
                                                        "Date: ${transactionData["Date"]}"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      child: Card(
                                        child: ExpansionTile(
                                          title: Text(
                                              snapshot.data[index].toString()),
                                          children: <Widget>[
                                            Column(
                                              children: [
                                                Center(
                                                  child: ListTile(
                                                    trailing:
                                                        const FlutterLogo(),
                                                    title: Text(
                                                        "Money Spent: ${transactionData["Value"]}"),
                                                  ),
                                                ),
                                                Center(
                                                  child: ListTile(
                                                    trailing:
                                                        const FlutterLogo(),
                                                    title: Text(
                                                        "Card Used: ${transactionData["Card Used"]}"),
                                                  ),
                                                ),
                                                Center(
                                                  child: Center(
                                                    child: ListTile(
                                                      trailing:
                                                          const FlutterLogo(),
                                                      title: Text(
                                                          "Location: ${transactionData["Location"]}"),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: ListTile(
                                                    trailing:
                                                        const FlutterLogo(),
                                                    title: Text(
                                                        "Date: ${transactionData["Date"]}"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                }),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        // By default show a loading spinner.
                        return const CircularProgressIndicator();
                      }),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _MyStatefulWidgetStateThree extends State<MyStatefulWidgetThree> {
  String imageUrl = "";
  Timer? timer;

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
    timer = Timer.periodic(const Duration(seconds: 45), (_) => printurl());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: db.collection("Users").doc(inputData()).get().then((value) {
          return value.data()!["Username"];
        }),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                                    top: MediaQuery.of(context).size.height *
                                        0.08),
                                child: Center(
                                  child: Center(
                                      child: Text(
                                    "Welcome back ${snapshot.data}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.09),
                                  )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.02),
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.12,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.26,
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
                                        child: InkWell(onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AccountScreen()),
                                          );
                                        }),
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
        });
  }
}

class _MyStatefulWidgetStatefinal extends State<MyStatefulWidgetfinal> {
  int _selectedIndex = 1;
  final pages = [
    const CryptoScreen(),
    const CryptoScreen(),
    const CustScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: const Color(0xffFFE5B4),
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(bodySmall: const TextStyle(color: Colors.grey))),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Crypto Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Customer Service',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
      body: Center(
        child: _selectedIndex != 1
            ? pages[_selectedIndex]
            : Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.32,
                        child: const MyStatefulWidgetThree(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: const MyStatefulWidget(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: const MyStatefulWidgetTwo(),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}