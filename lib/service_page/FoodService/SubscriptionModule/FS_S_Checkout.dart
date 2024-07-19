import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static const DATE_FORMAT = 'dd/MM/yyyy';
  String formattedDate(DateTime dateTime) {
    print('dateTime ($dateTime)');
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

    if (subscriptionType == 'monthly') {
      endingDate = fromDate.add(Duration(days: 30));
    } else if (subscriptionType == 'weekly') {
      endingDate = fromDate.add(Duration(days: 7));
    }

    _calculatePrice();

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

      if (subscriptionType == 'weekly') {
        packPrice = packData['pack_price_w'];
      } else if (subscriptionType == 'monthly') {
        packPrice = packData['pack_price_m'];
      } else {
        packPrice = packData['pack_price_w'] /
            7; // Assuming daily price for custom dates
      }

      setState(() {
        if (subscriptionType == 'weekly' || subscriptionType == 'monthly') {
          price = packPrice;
        } else {
          int days = endingDate.difference(fromDate).inDays + 1;
          price = (days * packPrice);
        }
      });
    }
  }

  void updateMeal(String title, int count, List<bool> days, TimeOfDay time, bool isOn) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
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
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Text(
                    'Total Price: ₹${price}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
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
                        },
                      );


                      print( packID);
                      print( subscriptionType);
                      print( fromDate);
                      print( endingDate);
                      print( breakfast['count']);
                      print( lunch['count']);
                      print( snack['count']);
                      print( dinner['count']);
                      print( breakfast['days']);
                      print( lunch['days']);
                      print( snack['days']);
                      print( dinner['days']);
                      print( breakfast['time'].format(context));
                      print( lunch['time'].format(context));
                      print( snack['time'].format(context));
                      print( dinner['time'].format(context));
                      print( breakfast['isOn']);
                      print( lunch['isOn']);
                      print( snack['isOn']);
                      print( dinner['isOn']);

                      String? userEmail =
                          FirebaseAuth.instance.currentUser?.email;
                      if (userEmail != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userEmail)
                            .collection('fs_service')
                            .doc('packs')
                            .set({
                          'packID': packID,
                          'subscription_type': subscriptionType,
                          'fromDate': '$fromDate',
                          'endingDate': '$endingDate',
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
                        });
                      }
                    },
                    child: Text('Finish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSetting(
      String title, DateTime date, Function(DateTime) onDateSelected) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${date.toLocal()}'.split(' ')[0]),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context, date, onDateSelected),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmSetting extends StatefulWidget {
  final String title;
  final TimeOfDay initialTime;
  final bool initialIsOn;
  final Function(int foodCount, List<bool> selectedDays, TimeOfDay time, bool isOn) onChanged;

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
  bool isExpanded = false;
  late bool isOn;
  late TimeOfDay selectedTime;
  late int foodCount;
  late List<bool> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    isOn = widget.initialIsOn;
    foodCount = 1; // Initial food count
    selectedDays = List.generate(7, (_) => true); // Initial selected days (all selected)
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.onChanged(foodCount, selectedDays, selectedTime, isOn);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: ListTile(
              title: Text(widget.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${selectedTime.format(context)}'),
                  IconButton(
                    icon: Icon(Icons.alarm),
                    onPressed: () => _selectTime(context),
                  ),
                  Switch(
                    value: isOn,
                    onChanged: (value) {
                      setState(() {
                        isOn = value;
                        widget.onChanged(foodCount, selectedDays, selectedTime, isOn);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Column(
              children: [
                ToggleButtons(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map((day) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(day),
                  ))
                      .toList(),
                  isSelected: selectedDays,
                  onPressed: (index) {
                    setState(() {
                      selectedDays[index] = !selectedDays[index];
                      widget.onChanged(foodCount, selectedDays, selectedTime, isOn);
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (foodCount > 1) foodCount--;
                          widget.onChanged(foodCount, selectedDays, selectedTime, isOn);
                        });
                      },
                    ),
                    Text('$foodCount'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          foodCount++;
                          widget.onChanged(foodCount, selectedDays, selectedTime, isOn);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
