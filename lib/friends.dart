import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class FriendPage extends StatelessWidget {
  const FriendPage({Key? key}) : super(key: key);
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
  List _friendresults = [];
  List _resultsList = [];
  List _username = [];
  bool def = true;
  String four = "";
  String username = "";
  late Future resultsLoaded;

  // FIX: Added Return Type 'Future<String>'
  Future<String> gettata() async {
    var user = await db
        .collection("Users")
        .where("ID", isEqualTo: inputData().toString())
        .get();

    var datatwo = await db
        .collection("Users")
        .doc(inputData())
        .collection("Friends")
        .get();

    // FIX: Added safety check to prevent crash if widget is closed
    if (!mounted) return "failed";

    setState(() {
      _friendresults = datatwo.docs;
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

  // FIX: Added Return Type 'void'
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

  // FIX: Added Return Type 'void'
  void searchResults() {
    var showResults = [];
    if (_percontroller.text != "") {
      for (var tripSnapshot in _friendresults) {
        var title = tripSnapshot["Username"].toString().toLowerCase();
        var number = tripSnapshot["Phone"].toString().toLowerCase();

        // Safety check if _username is empty
        if (_username.isNotEmpty) {
           username = _username[0]["Username"];
        }
        
        if (title.contains(_percontroller.text.toLowerCase())) {
          showResults.add(tripSnapshot);
        } else if (number.contains(_percontroller.text)) {
           if (_username.isNotEmpty) {
             username = _username[0]["Username"];
           }
          showResults.add(tripSnapshot);
        }
      }
    } else {
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
  final TextEditingController _percontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                            title: Text(
                                _resultsList[index]["Username"].toString()),
                            onTap: () {
                              // FIX: Changed print to debugPrint
                              debugPrint(_resultsList[index]["Username"].toString());
                            }),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}