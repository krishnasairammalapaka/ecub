import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PayHomeMed extends StatefulWidget {
  final double price;

  const PayHomeMed({required this.price, super.key});
  @override
  _PayHomeMedState createState() => _PayHomeMedState();
}

class _PayHomeMedState extends State<PayHomeMed> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  Map<String, Map<String, dynamic>> generateOrderSummary(
      List<DocumentSnapshot> docs, QuerySnapshot? snapshot) {
    if (docs.isEmpty || snapshot == null) return {};

    var summary = <String, Map<String, dynamic>>{};
    for (var doc in docs) {
      var name = doc['name'];
      var store = doc['storeName'];
      var quantity = doc['quantity'];
      // Update each document as a separate entry in the summary map
      summary[doc.id] = {
        'name': name,
        'storeName': store,
        'quantity': quantity,
      };
    }
    return summary;
  }

  clearCart() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('me_cart')
        .doc(user?.email)
        .collection('items')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment Success: ${response.paymentId}");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Text('Payment ID: ${response.paymentId}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (Route<dynamic> route) => false);
                Navigator.pushNamed(context, '/me');
                showDialog(
                  context: context,
                  builder: (context) {
                    int rating = 0;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Feedback'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.star,
                                        color: rating >= 1
                                            ? Colors.amber[200]
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        rating = 1;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.star,
                                        color: rating >= 2
                                            ? Colors.amber[200]
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        rating = 2;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.star,
                                        color: rating >= 3
                                            ? Colors.amber[200]
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        rating = 3;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.star,
                                        color: rating >= 4
                                            ? Colors.amber[200]
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        rating = 4;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.star,
                                        color: rating >= 5
                                            ? Colors.amber[200]
                                            : Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        rating = 5;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // TODO: Submit feedback with rating
                                },
                                child: Text('Submit'),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Error: ${response.code} - ${response.message}");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payment Failed'),
          content: Text('Error: ${response.message}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("External Wallet: ${response.walletName}");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('External Wallet Selected'),
          content: Text('Wallet: ${response.walletName}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> openCheckout() async {
  //     User? user = FirebaseAuth.instance.currentUser;
  //     DocumentSnapshot userData = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user!.email)
  //         .get();

  //     String name = userData['firstname'] + " " + userData['lastname'];
  //     String phonenumber=userData['phonenumber'];

  //     var options = {
  //       'key': 'rzp_test_ILKXehI3hPXJdo',
  //       'amount': 50000,
  //       'name': name,
  //       'prefill': {'contact': phonenumber, 'email': user.email},
  //       'external': {
  //         'wallets': ['paytm']
  //       }
  //     };

  //     try {
  //       _razorpay.open(options);
  //     } catch (e) {
  //       print(e.toString());
  //     }
  //   }

  getUserdetails() {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userData = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .get() as DocumentSnapshot;
    return userData;
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_ILKXehI3hPXJdo',
      'amount': widget.price * 100, // Amount in paise
      'name': 'ECUB',
      'description': '',
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razorpay Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: openCheckout,
          child: Text('Pay with Razorpay'),
        ),
      ),
    );
  }
}
