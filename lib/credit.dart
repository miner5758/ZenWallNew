import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenwall/addc.dart';

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

Future<void> _delete(String tit) async {
  await db
      .collection("Users")
      .doc(inputData())
      .collection("Cards")
      .doc(tit)
      .delete();
}

Future<List<String>> _getData() async {
  List<String> fr = [];
  var result =
      await db.collection("Users").doc(inputData()).collection("Cards").get();
  for (var res in result.docs) {
    fr.add(res.id.toString());
  }

  return (fr);
}

Future<List<Object?>> _gettata(String? iD) async {
  CollectionReference collectionRef =
      db.collection("Users").doc("$iD").collection("Cards");
  // Get docs from collection reference
  QuerySnapshot querySnapshot = await collectionRef.get();

  // Get data from docs and convert map to List
  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

  return (allData);
}

class CreditPage extends StatelessWidget {
  const CreditPage({Key? key}) : super(key: key);
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
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String tit = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = true;
  bool reveals = true;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withValues(alpha: 0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isSwitched = false;
  bool isSwitchedtwo = false;
  var textValue = 'Is Default: No';

  Future<void> tog(String name) async {
    try {
      final post = await db
          .collection("Users")
          .doc(inputData())
          .collection("Cards")
          .where('Default', isEqualTo: true)
          .limit(1)
          .get()
          .then((QuerySnapshot snapshot) {
        //Here we get the document reference and return to the post variable.
        return snapshot.docs[0].reference;
      });

      final tost =
          db.collection("Users").doc(inputData()).collection("Cards").doc(name);

      var batch = db.batch();
      //Updates the field value, using post as document reference
      batch.update(post, {'Default': false});
      batch.update(tost, {'Default': true});
      batch.commit();
    } catch (e) {
      if (e.toString() ==
          "RangeError (index): Invalid value: Valid value range is empty: 0") {
        final tost = db
            .collection("Users")
            .doc(inputData())
            .collection("Cards")
            .doc(name);

        var batch = db.batch();
        //Updates the field value, using post as document reference
        batch.update(tost, {'Default': true});
        batch.commit();
      }
    }
  }

  Future<void> off(BuildContext context, String name) async {
  try {
    final tost =
        db.collection("Users").doc(inputData()).collection("Cards").doc(name);

    var batch = db.batch();
    // Updates the field value, using post as document reference
    batch.update(tost, {'Default': false});
    
    // Added 'await' so we can actually catch errors if the commit fails
    await batch.commit(); 
  } catch (e) {
    // Safety check
    if (!context.mounted) return;

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

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Is Default: Yes';
      });
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Is Default: No ';
      });
    }
  }

  void reveal(bool value) {
    setState(() {
      isSwitchedtwo = !isSwitchedtwo;
      reveals = !reveals;
    });
  }

  void def(bool value, AsyncSnapshot lnapshots) {
    setState(() {
      isSwitchedtwo = !isSwitchedtwo;
      reveals = !reveals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return FutureBuilder(
                future: _gettata(inputData()),
                builder: (BuildContext context, AsyncSnapshot lnapshots) {
                  if (snapshot.hasData && lnapshots.hasData) {
                    if (snapshot.data.length == 0) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: !useBackgroundImage
                                ? const DecorationImage(
                                    image:
                                        ExactAssetImage('lib/images/pig.jpg'),
                                    fit: BoxFit.fill,
                                  )
                                : null,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xff4169e1),
                                Color(0xffFFE5B4),
                              ],
                              stops: [0, 0.45],
                            ),
                          ),
                          child: SafeArea(
                            child: Column(children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .12,
                                width: (MediaQuery.of(context).size.width),
                                foregroundDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    image: const DecorationImage(
                                      image: AssetImage('lib/images/fall.png'),
                                      fit: BoxFit.fill,
                                    )),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.10,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .05,
                                width: (MediaQuery.of(context).size.width - 50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: const Color.fromRGBO(54, 99, 233, 1),
                                ),
                                child: const Center(
                                    child: Text(
                                  "You Dont have any cards added right now",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.10,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                width: (MediaQuery.of(context).size.width - 50),
                                foregroundDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      width:
                                          5, //                   <--- border width here
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage('lib/images/plus.png'),
                                      fit: BoxFit.fill,
                                    )),
                                child: InkWell(onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddCreditPage()),
                                  );
                                }),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.10,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .05,
                                width: (MediaQuery.of(context).size.width - 50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: const Color.fromRGBO(54, 99, 233, 1),
                                ),
                                child: const Center(
                                    child: Text(
                                  "Click The Plus icon to add a card now!",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.10,
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .20,
                                width: (MediaQuery.of(context).size.width),
                                foregroundDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    image: const DecorationImage(
                                      image: AssetImage('lib/images/fall.png'),
                                      fit: BoxFit.fill,
                                    )),
                              ),
                            ]),
                          ));
                    } else {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: !useBackgroundImage
                              ? const DecorationImage(
                                  image: ExactAssetImage('lib/images/pig.jpg'),
                                  fit: BoxFit.fill,
                                )
                              : null,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff4169e1),
                              Color(0xffFFE5B4),
                            ],
                            stops: [0, 0.45],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.03,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.52,
                              width: MediaQuery.of(context).size.width * 0.99,
                              child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05,
                                          width: (MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              50),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            color: const Color.fromRGBO(
                                                54, 99, 233, 1),
                                          ),
                                          child: Center(
                                              child: Text(
                                            snapshot.data[index].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CreditCardWidget(
                                          glassmorphismConfig: useGlassMorphism
                                              ? Glassmorphism.defaultConfig()
                                              : null,
                                          cardNumber: lnapshots.data[
                                                  snapshot.data.indexOf(
                                                      snapshot.data[index])]
                                                  ["Card Num"]
                                              .toString(),
                                          expiryDate: lnapshots.data[
                                                  snapshot.data.indexOf(
                                                      snapshot.data[index])]
                                                  ["Exper"]
                                              .toString(),
                                          cardHolderName: lnapshots.data[
                                                  snapshot.data.indexOf(
                                                      snapshot.data[index])]
                                                  ["CardHoldName"]
                                              .toString(),
                                          cvvCode: lnapshots.data[snapshot.data
                                                      .indexOf(
                                                          snapshot.data[index])]
                                                  ["three di"]
                                              .toString(),
                                          showBackView: false,
                                          obscureCardNumber: reveals,
                                          obscureCardCvv: reveals,
                                          isHolderNameVisible: true,
                                          cardBgColor: Colors.red,
                                          backgroundImage: useBackgroundImage
                                              ? 'lib/images/black.jpg'
                                              : null,
                                          isSwipeGestureEnabled: false,
                                          isChipVisible: true,
                                          onCreditCardWidgetChange:
                                              (CreditCardBrand
                                                  creditCardBrand) {},
                                          customCardTypeIcons: <
                                              CustomCardTypeIcon>[
                                            CustomCardTypeIcon(
                                              cardType: CardType.mastercard,
                                              cardImage: Image.asset(
                                                'lib/images/pig.jpg',
                                                height: 68,
                                                width: 48,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .30,
                                            ),
                                            Text(
                                              (() {
                                                if (lnapshots.data[snapshot.data
                                                            .indexOf(snapshot
                                                                .data[index])]
                                                        ["Default"] ==
                                                    true) {
                                                  return "Is Default: Yes";
                                                } else {
                                                  return "Is Default: No";
                                                }
                                              }()),
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05,
                                            ),
                                            Transform.scale(
                                                scale: 2,
                                                child: Switch(
                                                  value: (() {
                                                    if (lnapshots.data[snapshot
                                                                .data
                                                                .indexOf(snapshot
                                                                        .data[
                                                                    index])]
                                                            ["Default"] ==
                                                        true) {
                                                      return true;
                                                    } else {
                                                      return false;
                                                    }
                                                  }()),
                                                  onChanged: (((value) {
                                                    if (lnapshots.data[snapshot
                                                                .data
                                                                .indexOf(snapshot
                                                                        .data[
                                                                    index])]
                                                            ["Default"] ==
                                                        true) {
                                                      off(context, snapshot.data[index]
                                                          .toString());
                                                      setState(() {});
                                                    } else if (lnapshots.data[snapshot
                                                                .data
                                                                .indexOf(snapshot
                                                                        .data[
                                                                    index])]
                                                            ["Default"] ==
                                                        false) {
                                                      tog(snapshot.data[index]
                                                          .toString());
                                                      setState(() {});
                                                    }
                                                  })),
                                                  activeThumbColor: Colors.blue,
                                                  activeTrackColor:
                                                      Colors.yellow,
                                                  inactiveThumbColor:
                                                      Colors.redAccent,
                                                  inactiveTrackColor:
                                                      Colors.orange,
                                                )),
                                          ],
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.19,
                                          foregroundDecoration: BoxDecoration(
                                            border: Border.all(
                                              width: 5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: InkWell(
                                              splashColor: Colors.blue,
                                              onTap: () {
                                                _delete(snapshot.data[index]
                                                    .toString());
                                                setState(() {});
                                              },
                                              child: const FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: Icon(
                                                    Icons.delete_outlined,
                                                  )
                                                  )),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * .33,
                              width: MediaQuery.of(context).size.width * .93,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: const Color.fromARGB(255, 150, 135, 108),
                              ),
                              child: ListView(children: [
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
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
                                                    const AddCreditPage()),
                                          );
                                        },
                                        child: const ListTile(
                                          trailing: FlutterLogo(),
                                          title: Text(
                                            "Add Card",
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .85,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      child: ListTile(
                                        trailing: Transform.scale(
                                            scale: 2,
                                            child: Switch(
                                              onChanged: toggleSwitch,
                                              value: isSwitched,
                                              activeThumbColor: Colors.blue,
                                              activeTrackColor: Colors.yellow,
                                              inactiveThumbColor:
                                                  Colors.redAccent,
                                              inactiveTrackColor: Colors.orange,
                                            )),
                                        title: const Text(
                                          "Lock all Cards",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .85,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      child: InkWell(
                                        splashColor: Colors.blue,
                                        onTap: () => showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  "Coming Soon!",
                                                  style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text("Close"))
                                                ],
                                              );
                                            }),
                                        child: const ListTile(
                                          trailing: FlutterLogo(),
                                          title: Text(
                                            "Passports, Keys, etc",
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .85,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      child: ListTile(
                                        trailing: Transform.scale(
                                            scale: 2,
                                            child: Switch(
                                              onChanged: reveal,
                                              value: isSwitchedtwo,
                                              activeThumbColor: Colors.blue,
                                              activeTrackColor: Colors.yellow,
                                              inactiveThumbColor:
                                                  Colors.redAccent,
                                              inactiveTrackColor: Colors.orange,
                                            )),
                                        title: const Text(
                                          "Reveal Card Info",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ]),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                });
          }),
    );
  }
}
