import 'package:ecub_s1_v2/models/CheckoutHistory_DB.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FS_Profile extends StatefulWidget {
  const FS_Profile({Key? key}) : super(key: key);

  @override
  State<FS_Profile> createState() => _FS_ProfileState();
}

class _FS_ProfileState extends State<FS_Profile> {
  Stream<int> fetchCartItemCount() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return FirebaseFirestore.instance
          .collection('me_cart')
          .doc(user.email)
          .collection('items')
          .snapshots()
          .map((snapshot) =>
      snapshot.docs.length); // Map the snapshots to their count
    } else {
      // Return a stream of 0 if the user is not logged in
      return Stream.value(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Profile'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(),
              Divider(),
              AccountSection(),
              Divider(),
              PaymentSection(),
              Divider(),
              HelpSection(),
              Divider(),
              PastOrdersSection(),
            ],
          ),
        )
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Karthik",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'EDIT',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '9711898182 . mokshgarg003@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'My Account'),
          SizedBox(height: 10),
          Text('Address, Favourites & Settings'),
          SizedBox(height: 20),
          AccountOption(title: 'Manage Address'),
          AccountOption(title: 'Favourites'),
          AccountOption(title: 'Settings'),
        ],
      ),
    );
  }
}

class PaymentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Payments & Refunds'),
          SizedBox(height: 10),
          Text('Manage your Refunds, Payment Modes'),
          SizedBox(height: 20),
          AccountOption(title: 'Refund Status', subtitle: '1 active refund'),
          AccountOption(title: 'Payment Modes'),
        ],
      ),
    );
  }
}

class HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Help'),
          SizedBox(height: 10),
          Text('FAQs & Links'),
        ],
      ),
    );
  }
}

class PastOrdersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Past Orders'),
          SizedBox(height: 20),
          OrdersListView(),
        ],
      ),
    );
  }
}

class AccountOption extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AccountOption({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class OrdersListView extends StatelessWidget {
  Future<List<CheckoutHistory_DB>> _getCheckoutHistory() async {
    final checkoutHistoryBox =
        await Hive.openBox<CheckoutHistory_DB>('checkoutHistoryBox');
    return checkoutHistoryBox.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CheckoutHistory_DB>>(
      future: _getCheckoutHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('An error occurred'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No past orders found'));
        } else {
          final orders = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderHistoryItem(
                orderId: order.key.toString(),
                restaurant: 'Restaurant Name',
                location: 'Location',
                date: order.TimeStamp,
                amount: 0,
              );
            },
          );
        }
      },
    );
  }
}

class OrderHistoryItem extends StatelessWidget {
  final String orderId;
  final String restaurant;
  final String location;
  final int amount;
  final String date;

  const OrderHistoryItem({
    required this.orderId,
    required this.restaurant,
    required this.location,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(location),
          Text('₹$amount'),
          Text(date),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('REORDER'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('RATE ORDER'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
