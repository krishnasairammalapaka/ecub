import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PayHomeFood extends StatefulWidget {
  final double amount;

  PayHomeFood({required this.amount});

  @override
  _PayHomeFoodState createState() => _PayHomeFoodState();
}

class _PayHomeFoodState extends State<PayHomeFood> {
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
                Navigator.pushNamed(context, '/fs_home');
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

  void openCheckout() {
    double cost = widget.amount;
    if (widget.amount < 1) {
      cost = 500;
    }
    var options = {
      'key': 'rzp_test_ILKXehI3hPXJdo',
      'amount': cost * 100, // Amount in paise
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
