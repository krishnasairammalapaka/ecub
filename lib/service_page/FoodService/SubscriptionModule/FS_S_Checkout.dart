import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static const DATE_FORMAT = 'dd/MM/yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class FS_S_Checkout extends StatefulWidget {
  @override
  _FS_S_CheckoutState createState() => _FS_S_CheckoutState();
}

class _FS_S_CheckoutState extends State<FS_S_Checkout> {
  final User? user = FirebaseAuth.instance.currentUser;

  DateTime fromDate = DateTime.now();
  DateTime endingDate = DateTime.now().add(Duration(days: 7));
  int price = 0;
  late String packID;
  late String subscriptionType;
  late List<String> foodlist;

  late Map<String, dynamic> breakfast;
  late Map<String, dynamic> lunch;
  late Map<String, dynamic> snack;
  late Map<String, dynamic> dinner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    packID = args['packID'];
    subscriptionType = args['subscription_type'];
    foodlist = args['selectedFoodIds'];

    if (subscriptionType == 'Monthly') {
      endingDate = fromDate.add(Duration(days: 30));
    } else if (subscriptionType == 'Weekly') {
      endingDate = fromDate.add(Duration(days: 7));
    }

    // Initialize meal settings data
    breakfast = {
      'count': 1,
      'days': List.generate(7, (_) => true),
      'time': TimeOfDay(hour: 7, minute: 0),
      'isOn': true,
    };
    lunch = {
      'count': 1,
      'days': List.generate(7, (_) => true),
      'time': TimeOfDay(hour: 12, minute: 0),
      'isOn': true,
    };
    snack = {
      'count': 1,
      'days': List.generate(7, (_) => true),
      'time': TimeOfDay(hour: 16, minute: 0),
      'isOn': true,
    };
    dinner = {
      'count': 1,
      'days': List.generate(7, (_) => true),
      'time': TimeOfDay(hour: 19, minute: 0),
      'isOn': true,
    };

    _calculatePrice();
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  void _calculatePrice() async {
    final packDoc = await FirebaseFirestore.instance
        .collection('fs_packs')
        .doc(packID)
        .get();
    if (packDoc.exists) {
      final packData = packDoc.data()!;
      int packPrice;

      if (subscriptionType == 'Weekly') {
        packPrice = packData['pack_price_w'] as int;
      } else if (subscriptionType == 'Monthly') {
        packPrice = packData['pack_price_m'] as int;
      } else {
        // For customized dates, use a similar logic to calculate daily price
        packPrice = (packData['pack_price_m'] / 30)
            .toInt(); // Assume 30 days in a month
      }

      // Calculate per meal price
      int perMealPrice =
          packPrice ~/ 28; // Weekly price divided by the total meals in a week

      // Initialize totalMeals as an integer
      int totalMeals = 0;

      // Define a helper function to sum meal counts
      int sumMealCounts(Map<String, dynamic> meal) {
        int count = meal['count'] as int? ?? 0;
        List<dynamic> days = meal['days'] ?? [];
        int daysCount = days.where((day) => day == true).length;
        bool isOn = meal['isOn'] as bool? ?? true;
        return isOn ? count * daysCount : 0;
      }

      // Sum up the total meal count based on selections
      totalMeals += sumMealCounts(breakfast);
      totalMeals += sumMealCounts(lunch);
      totalMeals += sumMealCounts(snack);
      totalMeals += sumMealCounts(dinner);

      // Calculate the total price based on per meal price and total meals
      setState(() {
        price = totalMeals * perMealPrice;
      });
    }
  }

  void updateMeal(
      String title, int count, List<bool> days, TimeOfDay time, bool isOn) {
    setState(() {
      if (title == 'Breakfast') {
        breakfast['count'] = count;
        breakfast['days'] = days;
        breakfast['time'] = time;
        breakfast['isOn'] = isOn;
      } else if (title == 'Lunch') {
        lunch['count'] = count;
        lunch['days'] = days;
        lunch['time'] = time;
        lunch['isOn'] = isOn;
      } else if (title == 'Snack') {
        snack['count'] = count;
        snack['days'] = days;
        snack['time'] = time;
        snack['isOn'] = isOn;
      } else if (title == 'Dinner') {
        dinner['count'] = count;
        dinner['days'] = days;
        dinner['time'] = time;
        dinner['isOn'] = isOn;
      }

      _calculatePrice(); // Calculate price whenever meal settings are updated
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Color(0xFF0D5EF9),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDateSetting('From Date', fromDate, (date) {
                setState(() {
                  fromDate = date;
                  _calculatePrice();
                });
              }),
              _buildDateSetting('Ending Date', endingDate, (date) {
                setState(() {
                  endingDate = date;
                  _calculatePrice();
                });
              }),
              SizedBox(height: 20),
              AlarmSetting(
                title: 'Breakfast',
                initialTime: TimeOfDay(hour: 7, minute: 0),
                initialIsOn: true,
                onChanged: (count, days, time, isOn) {
                  updateMeal('Breakfast', count, days, time, isOn);
                },
              ),
              AlarmSetting(
                title: 'Lunch',
                initialTime: TimeOfDay(hour: 12, minute: 0),
                initialIsOn: true,
                onChanged: (count, days, time, isOn) {
                  updateMeal('Lunch', count, days, time, isOn);
                },
              ),
              AlarmSetting(
                title: 'Snack',
                initialTime: TimeOfDay(hour: 16, minute: 0),
                initialIsOn: true,
                onChanged: (count, days, time, isOn) {
                  updateMeal('Snack', count, days, time, isOn);
                },
              ),
              AlarmSetting(
                title: 'Dinner',
                initialTime: TimeOfDay(hour: 19, minute: 0),
                initialIsOn: true,
                onChanged: (count, days, time, isOn) {
                  updateMeal('Dinner', count, days, time, isOn);
                },
              ),
              SizedBox(height: 20),
              Text(
                'Total Price: ₹$price',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Create a reference to the Firestore collection
                    final firestore = FirebaseFirestore.instance;
                    final userEmail = FirebaseAuth.instance.currentUser?.email;

                    if (userEmail != null) {
                      final collectionRef = firestore
                          .collection('users')
                          .doc(userEmail)
                          .collection('fs_service')
                          .doc('packs'); // Use the correct document ID or create a unique one if needed

                      // Define the data you want to update in Firestore
                      final data = {
                        'packID': packID,
                        'subscription_type': subscriptionType,
                        'fromDate': fromDate,
                        'endingDate': endingDate,
                        'breakfastCount': breakfast['count'],
                        'lunchCount': lunch['count'],
                        'snackCount': snack['count'],
                        'dinnerCount': dinner['count'],
                        'breakfastDays': breakfast['days'],
                        'lunchDays': lunch['days'],
                        'snackDays': snack['days'],
                        'dinnerDays': dinner['days'],
                        'breakfastTime': breakfast['time'].format(context),
                        'lunchTime': lunch['time'].format(context),
                        'snackTime': snack['time'].format(context),
                        'dinnerTime': dinner['time'].format(context),
                        'breakfastIsOn': breakfast['isOn'],
                        'lunchIsOn': lunch['isOn'],
                        'snackIsOn': snack['isOn'],
                        'dinnerIsOn': dinner['isOn'],
                        'totalPrice': price,
                        'selectedFoodIds': foodlist // Ensure foodlist is properly defined
                      };

                      // Update Firestore
                      await collectionRef.set(data);

                      // Navigate to the next screen
                      Navigator.pushNamed(
                        context,
                        '/fs_home',
                        arguments: {
                          'packID': packID,
                          'subscription_type': subscriptionType,
                          'fromDate': fromDate,
                          'endingDate': endingDate,
                          'breakfastCount': breakfast['count'],
                          'lunchCount': lunch['count'],
                          'snackCount': snack['count'],
                          'dinnerCount': dinner['count'],
                          'breakfastDays': breakfast['days'],
                          'lunchDays': lunch['days'],
                          'snackDays': snack['days'],
                          'dinnerDays': dinner['days'],
                          'breakfastTime': breakfast['time'].format(context),
                          'lunchTime': lunch['time'].format(context),
                          'snackTime': snack['time'].format(context),
                          'dinnerTime': dinner['time'].format(context),
                          'breakfastIsOn': breakfast['isOn'],
                          'lunchIsOn': lunch['isOn'],
                          'snackIsOn': snack['isOn'],
                          'dinnerIsOn': dinner['isOn'],
                          'totalPrice': price,
                        },
                      );
                    } else {
                      print('User is not logged in.');
                    }
                  } catch (e) {
                    // Handle any errors
                    print('Error updating Firestore: $e');
                  }
                },
                child: Text('Confirm Subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D5EF9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSetting(
      String label, DateTime date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context, date, onDateSelected),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class AlarmSetting extends StatefulWidget {
  final String title;
  final TimeOfDay initialTime;
  final bool initialIsOn;
  final Function(int, List<bool>, TimeOfDay, bool) onChanged;

  AlarmSetting({
    required this.title,
    required this.initialTime,
    required this.initialIsOn,
    required this.onChanged,
  });

  @override
  _AlarmSettingState createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {
  late TimeOfDay selectedTime;
  late bool isOn;
  int mealCount = 1;
  List<bool> selectedDays = List.generate(7, (_) => true);

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    isOn = widget.initialIsOn;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.onChanged(mealCount, selectedDays, selectedTime, isOn);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: TextStyle(fontSize: 18)),
                Switch(
                  value: isOn,
                  onChanged: (value) {
                    setState(() {
                      isOn = value;
                      widget.onChanged(
                          mealCount, selectedDays, selectedTime, isOn);
                    });
                  },
                ),
              ],
            ),
            if (isOn) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meals per Day: $mealCount',
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: mealCount > 1
                        ? () {
                      setState(() {
                        mealCount--;
                        widget.onChanged(
                            mealCount, selectedDays, selectedTime, isOn);
                      });
                    }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        mealCount++;
                        widget.onChanged(
                            mealCount, selectedDays, selectedTime, isOn);
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${selectedTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                children: List.generate(7, (index) {
                  return ChoiceChip(
                    label: Text(
                      DateFormat('E').format(
                        DateTime.now().add(Duration(days: index)),
                      ),
                    ),
                    selected: selectedDays[index],
                    onSelected: (selected) {
                      setState(() {
                        selectedDays[index] = selected;
                        widget.onChanged(
                            mealCount, selectedDays, selectedTime, isOn);
                      });
                    },
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
