import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zenwall/credit.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

String? inputData() {
  final User? user = auth.currentUser;
  final uid = user?.uid;
  return uid;
}

class AddCreditPage extends StatelessWidget {
  const AddCreditPage({Key? key}) : super(key: key);
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
  TextEditingController cardnamecontroller = TextEditingController();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = true;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withValues(alpha: 0.7),
        width: 2.0,
      ),
    );
    super.initState();
    cardnamecontroller.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    cardnamecontroller.dispose();
    super.dispose();
  }

  String tit = "";
  void _printLatestValue() {
    setState(() {
      tit = cardnamecontroller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        resizeToAvoidBottomInset: false,
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
          child: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 35,
                ),
                Container(
                  height: 50,
                  width: (MediaQuery.of(context).size.width - 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: const Color.fromRGBO(54, 99, 233, 1),
                  ),
                  child: Center(
                      child: Text(
                    tit,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                const SizedBox(
                  height: 30,
                ),
                CreditCardWidget(
                  glassmorphismConfig:
                      useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  obscureCardNumber: false,
                  obscureCardCvv: false,
                  isHolderNameVisible: true,
                  cardBgColor: Colors.red,
                  backgroundImage:
                      useBackgroundImage ? 'lib/images/black.jpg' : null,
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                  customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'lib/images/black.jpg',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * .85,
                            child: TextField(
                              controller: cardnamecontroller,
                              decoration: InputDecoration(
                                labelText: 'Card Name',
                                hintText: 'Ex.Favorite Credit Card',
                                hintStyle: const TextStyle(color: Colors.black),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                focusedBorder: border,
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      width: 0.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        CreditCardForm(
                          formKey: formKey,
                          obscureCvv: true,
                          obscureNumber: true,
                          cardNumber: cardNumber,
                          cvvCode: cvvCode,
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardHolderName: cardHolderName,
                          expiryDate: expiryDate,
                          onCreditCardModelChange: onCreditCardModelChange,
                          
                          // Updated Configuration
                          inputConfiguration: InputConfiguration(
                            // 1. Define text styles for each field individually
                            cardNumberTextStyle: const TextStyle(color: Colors.black),
                            cardHolderTextStyle: const TextStyle(color: Colors.black),
                            expiryDateTextStyle: const TextStyle(color: Colors.black),
                            cvvCodeTextStyle: const TextStyle(color: Colors.black),

                            // 2. Define decorations
                            cardNumberDecoration: InputDecoration(
                              labelText: 'Number',
                              hintText: 'XXXX XXXX XXXX XXXX',
                              hintStyle: const TextStyle(color: Colors.black),
                              labelStyle: const TextStyle(color: Colors.black),
                              focusedBorder: border,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 0.0,
                                ),
                              ),
                            ),
                            
                            expiryDateDecoration: InputDecoration(
                              hintStyle: const TextStyle(color: Colors.black),
                              labelStyle: const TextStyle(color: Colors.black),
                              focusedBorder: border,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 0.0,
                                ),
                              ),
                              labelText: 'Expired Date',
                              hintText: 'XX/XX',
                            ),
                            
                            cvvCodeDecoration: InputDecoration(
                              hintStyle: const TextStyle(color: Colors.black),
                              labelStyle: const TextStyle(color: Colors.black),
                              focusedBorder: border,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 0.0,
                                ),
                              ),
                              labelText: 'CVV',
                              hintText: 'XXX',
                            ),
                            
                            cardHolderDecoration: InputDecoration(
                              hintStyle: const TextStyle(color: Colors.black),
                              labelStyle: const TextStyle(color: Colors.black),
                              focusedBorder: border,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 0.0,
                                ),
                              ),
                              labelText: 'Card Holder',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor: const Color(0xff1b447b),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            child: const Text(
                              'Validate',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'halter',
                                fontSize: 14,
                                package: 'flutter_credit_card',
                              ),
                            ),
                          ),
                          onPressed: () async { // 1. Added 'async' here
                            if (formKey.currentState!.validate()) {
                              final city = {
                                "Card Num": cardNumber.toString(),
                                "CardHoldName": cardHolderName.toString(),
                                "Default": false,
                                "Exper": expiryDate.toString(),
                                "three di": cvvCode.toString(),
                              };

                              // Consolidated your collection references into one for cleaner code
                              var cardDocRef = db
                                  .collection("Users")
                                  .doc(inputData())
                                  .collection("Cards")
                                  .doc(cardnamecontroller.text);

                              try {
                                // 2. Use 'await' to pause execution until the database checks if the card exists
                                var docSnapshot = await cardDocRef.get();

                                // 3. SAFETY CHECK: If the user left the screen during the 'await', stop here.
                                if (!context.mounted) return; 

                                if (docSnapshot.exists) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "You cant have 2 cards with the same name!!! try again."),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Try Again"))
                                          ],
                                        );
                                      });
                                } else {
                                  // Card doesn't exist, proceed to save
                                  await cardDocRef.set(city);
                                  
                                  // SAFETY CHECK AGAIN after the second await
                                  if (!context.mounted) return;

                                  // Navigate only after successful save
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CreditPage()),
                                  );
                                }
                              } catch (error) {
                                // Handle errors
                                if (!context.mounted) return; // One last safety check
                                
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          "Invalid",
                                          style: TextStyle(
                                              fontSize: 30, fontWeight: FontWeight.bold),
                                        ),
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
                            } else {
                              // Form validation failed
                              showDialog( // Changed from just creating AlertDialog to showing it
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Something Went Wrong, Please Try Again",
                                        style: TextStyle(
                                            fontSize: 30, fontWeight: FontWeight.bold),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Close"))
                                      ],
                                    );
                                  }
                              );
                            }
                          },
                        ),
                      ],
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

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
  // Only run if the model is not null
  if (creditCardModel != null) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
}
