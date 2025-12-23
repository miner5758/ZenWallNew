import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:zenwall/home.dart';
import 'package:intl/intl.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

class SendPage extends StatelessWidget {
  const SendPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  List _allResults = [];
  List _friendresults = [];
  List _resultsList = [];
  List _card = [];
  List _username = [];
  bool def = true;
  String four = "";
  String username = "";
  late Future resultsLoaded;

  // FIX: Added Future<String> type
  Future<String> gettata() async {
    var data = await db
        .collection("Users")
        .where("ID", isNotEqualTo: inputData().toString())
        .get();

    var user = await db
        .collection("Users")
        .where("ID", isEqualTo: inputData().toString())
        .get();

    var datatwo = await db
        .collection("Users")
        .doc(inputData())
        .collection("Friends")
        .get();

    var datathree = await db
        .collection("Users")
        .doc(inputData())
        .collection("Cards")
        .where("Default", isEqualTo: true)
        .get();

    // FIX: Check mounted before calling setState
    if (!mounted) return "failed";

    setState(() {
      _allResults = data.docs;
      _friendresults = datatwo.docs;
      _card = datathree.docs;
      _username = user.docs;
    });
    searchResults();
    return "complete";
  }

  @override
  void initState() {
    super.initState();
    _percontroller.addListener(_onSearchChaned);
  }

  // FIX: Added void type
  void _onSearchChaned() {
    searchResults();
  }

  @override
  void dispose() {
    _percontroller.removeListener(_onSearchChaned);
    _percontroller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = gettata();
  }

  // FIX: Added void type
  void searchResults() {
    var showResults = [];
    if (_percontroller.text != "") {
      for (var tripSnapshot in _allResults) {
        var title = tripSnapshot["Username"].toString().toLowerCase();
        var number = tripSnapshot["Phone"].toString().toLowerCase();
        try {
          if (_card.isNotEmpty) {
            four = _card[0]["Card Num"].toString();
          }
        } on Error {
          setState(() {
            def = false;
          });
        }
        if (_username.isNotEmpty) {
          username = _username[0]["Username"];
        }
        
        if (title.contains(_percontroller.text.toLowerCase())) {
          showResults.add(tripSnapshot);
        } else if (number.contains(_percontroller.text)) {
          try {
             if (_card.isNotEmpty) {
               four = _card[0]["Card Num"].toString();
             }
          } on Error {
            setState(() {
              def = false;
            });
          }
           if (_username.isNotEmpty) {
             username = _username[0]["Username"];
           }
          showResults.add(tripSnapshot);
        }
      }
    } else {
      try {
         if (_card.isNotEmpty) {
           four = _card[0]["Card Num"].toString();
         }
      } on Error {
        setState(() {
          def = false;
        });
      }
       if (_username.isNotEmpty) {
         username = _username[0]["Username"];
       }
      showResults = List.from(_friendresults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  String tit = "";
  final PanelController _pc1 = PanelController();
  final TextEditingController _percontroller = TextEditingController();
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        maintainState: true,
        maintainAnimation: true,
        visible: _visible,
        child: SlidingUpPanel(
          controller: _pc1,
          isDraggable: false,
          minHeight: MediaQuery.of(context).size.height * 0,
          maxHeight: MediaQuery.of(context).size.height * .95,
          panel: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff4169e1),
                  Color(0xffFFE5B4),
                ],
                stops: [0, 0.45],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.88,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.10,
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(
                          width: 5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () {
                            _pc1.close();
                          },
                          child: const FittedBox(
                            fit: BoxFit.fill,
                            child: Icon(
                              Icons.close,
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.09,
                ),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: (MediaQuery.of(context).size.width - 50),
                    child: TextField(
                      controller: _percontroller,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Search by Username or Phone Number',
                        labelStyle: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.10,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .38,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      itemCount: _resultsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_resultsList[index]["Username"] == "None") {
                          return const SizedBox(
                              child: Center(
                            child: Text(
                              "No friends :(",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ));
                        } else {
                          return SizedBox(
                            child: Card(
                              child: ListTile(
                                  trailing: Image.asset("lib/images/pig.jpg"),
                                  title: Text(_resultsList[index]["Username"]
                                      .toString()),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            insetPadding: const EdgeInsets.only(
                                              right: 50,
                                              left: 50,
                                              top: 100,
                                              bottom: 280,
                                            ),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Text(
                                                    "Are you sure you want to send \$$tit to ",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .80,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .20,
                                                  foregroundDecoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'lib/images/pig.jpg'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Center(
                                                  // FIX: String Interpolation
                                                  child: Text(
                                                    "${_resultsList[index]["Username"]}?",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .05,
                                                    ),
                                                    Container(
                                                      height: 50,
                                                      width: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          .30),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        color: const Color(
                                                            0xff4169e1),
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text("Close"),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .10,
                                                    ),
                                                    Container(
                                                      height: 50,
                                                      width: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          .30),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        color: const Color(
                                                            0xff4169e1),
                                                      ),
                                                      child: ElevatedButton(
                                                        // FIX: Made function async to handle database calls safely
                                                        onPressed: () async {
                                                          String finalfour =
                                                              four.split(
                                                                  ' ')[3];

                                                          var now =
                                                              DateTime.now();
                                                          var formatter =
                                                              DateFormat(
                                                                  'MM-dd-yyyy');
                                                          String formattedDate =
                                                              formatter
                                                                  .format(now);

                                                          // FIX: String Interpolation for "To ..."
                                                          final city = {
                                                            "Card Used":
                                                                "Card Ending In $finalfour",
                                                            "Transfer": true,
                                                            "Date":
                                                                formattedDate
                                                                    .toString(),
                                                            "From": "To ${_resultsList[index]["Username"]}",
                                                            "Value":
                                                                double.tryParse(
                                                                    tit),
                                                          };

                                                          final id = UniqueKey()
                                                              .toString();

                                                          // FIX: String Interpolation for "From ..."
                                                          final citytwo = {
                                                            "Card Used": "None",
                                                            "Transfer": true,
                                                            "Date":
                                                                formattedDate
                                                                    .toString(),
                                                            "From": "From $username",
                                                            "Value":
                                                                double.tryParse(
                                                                    tit),
                                                          };

                                                          var othercoll = db
                                                              .collection(
                                                                  "Users")
                                                              .doc(_resultsList[
                                                                          index]
                                                                      ["ID"]
                                                                  .toString())
                                                              .collection(
                                                                  "Purchases")
                                                              .doc(id);

                                                          var collection = db
                                                              .collection(
                                                                  "Users")
                                                              .doc(inputData())
                                                              .collection(
                                                                  "Purchases")
                                                              .doc(id);

                                                          // FIX: Replaced .then/.catchError with try/await/catch
                                                          try {
                                                            await collection.set(city);
                                                            await othercoll.set(citytwo);

                                                            // Check mounted before showing success dialog
                                                            if (!context.mounted) return;

                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) =>
                                                                  AlertDialog(
                                                                title: const Text(
                                                                  "Sent!",
                                                                  style: TextStyle(
                                                                      fontSize: 30,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => const Homescreen()),
                                                                      );
                                                                    },
                                                                    child: const Text("Close"),
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          } catch (error) {
                                                            // Check mounted before showing error dialog
                                                            if (!context.mounted) return;

                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) =>
                                                                  AlertDialog(
                                                                title: const Text(
                                                                  "Something Went Wrong, Please Try Again",
                                                                  style: TextStyle(
                                                                      fontSize: 30,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: const Text("Close"))
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child:
                                                            const Text("Send"),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                            ),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff4169e1),
                  Color(0xffFFE5B4),
                ],
                stops: [0, 0.45],
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.23,
                ),
                SizedBox(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 50),
                  child: Center(
                      child: Text(
                    tit,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                ),
                // Below are all the Numpad buttons. I fixed the interpolation for all of them.
                Center(
                  child: Row(
                    children: [
                      _buildNumKey(context, "1"),
                      _buildNumKey(context, "2"),
                      _buildNumKey(context, "3"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    children: [
                      _buildNumKey(context, "4"),
                      _buildNumKey(context, "5"),
                      _buildNumKey(context, "6"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    children: [
                      _buildNumKey(context, "7"),
                      _buildNumKey(context, "8"),
                      _buildNumKey(context, "9"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    children: [
                      // "." Key
                      Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.33,
                        height: MediaQuery.of(context).size.height * .12,
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () {
                            setState(() {
                              if (tit.length == 7 ||
                                  tit.contains('.') ||
                                  tit.length >= 5) {
                                tit = tit;
                              } else {
                                // FIX: Interpolation
                                tit = "$tit.";
                              }
                            });
                          },
                          child: const Center(
                              child: Text(
                            ".",
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      // "0" Key
                      Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        width: MediaQuery.of(context).size.width * 0.33,
                        height: MediaQuery.of(context).size.height * .12,
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () {
                            setState(() {
                              if (tit.length == 7 || tit.isEmpty) {
                                tit = tit;
                              } else {
                                // FIX: Interpolation
                                tit = "${tit}0";
                              }
                              if (tit.contains('.')) {
                                final decitit = tit.split('.');
                                if (decitit[1].length == 3) {
                                  tit = tit.substring(
                                      0, tit.lastIndexOf('.') + 3);
                                }
                              }
                            });
                          },
                          child: const Center(
                              child: Text(
                            "0",
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      // Backspace Key
                      Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        width: MediaQuery.of(context).size.width * 0.33,
                        height: MediaQuery.of(context).size.height * .12,
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: () {
                            setState(() {
                              if (tit.isEmpty) {
                                tit = tit;
                              } else {
                                tit = tit.substring(0, tit.length - 1);
                              }
                            });
                          },
                          child: const Center(
                              child: Text(
                            "<",
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Row(children: [
                    Container(
                        height: MediaQuery.of(context).size.height * .10,
                        width: (MediaQuery.of(context).size.width * .30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: const Color(0xff4169e1),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (tit == "") {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text(
                                    "Must input amount wished to be sent",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Close"))
                                  ],
                                ),
                              );
                            } else if (def == false) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text(
                                    "You either do not have any cards on your account or you do not have a default set!",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Close"))
                                  ],
                                ),
                              );
                            } else {
                              _visible = true;
                              setState(() {});
                              _pc1.open();
                            }
                          },
                          child: const Center(child: Text("Send")),
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .10,
                      width: MediaQuery.of(context).size.width * .40,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * .10,
                        width: (MediaQuery.of(context).size.width * .30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: const Color(0xff4169e1),
                        ),
                        child: ElevatedButton(
                          // FIX: Used debugPrint
                          onPressed: () => debugPrint("object"),
                          child: const Center(child: Text("Request")),
                        )),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to reduce code repetition for Number Keys
  Widget _buildNumKey(BuildContext context, String num) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: Colors.white),
      width: MediaQuery.of(context).size.width * 0.33,
      height: MediaQuery.of(context).size.height * .12,
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () {
          setState(
            () {
              if (tit.length == 7) {
                tit = tit;
              } else {
                // FIX: Interpolation
                tit = "$tit$num";
              }
              if (tit.contains('.')) {
                final decitit = tit.split('.');
                if (decitit[1].length == 3) {
                  tit = tit.substring(
                      0, tit.lastIndexOf('.') + 3);
                }
              }
            },
          );
        },
        child: Center(
            child: Text(
          num,
          style: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}