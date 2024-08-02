import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FS_S_PackCheck extends StatefulWidget {
  @override
  _FS_S_PackCheckState createState() => _FS_S_PackCheckState();
}

class _FS_S_PackCheckState extends State<FS_S_PackCheck> {
  final User? user = FirebaseAuth.instance.currentUser;

  DateTime fromDate = DateTime.now();
  DateTime endingDate = DateTime.now().add(Duration(days: 7));
  int price = 0;
  late String packID;
  late String subscriptionType;
  late List<String> foodlist = [];

  Map<String, dynamic> breakfast = {
    'count': 0,
    'days': List<bool>.filled(7, false),
    'time': TimeOfDay.now(),
    'isOn': false,
  };
  Map<String, dynamic> lunch = {
    'count': 0,
    'days': List<bool>.filled(7, false),
    'time': TimeOfDay.now(),
    'isOn': false,
  };
  Map<String, dynamic> snack = {
    'count': 0,
    'days': List<bool>.filled(7, false),
    'time': TimeOfDay.now(),
    'isOn': false,
  };
  Map<String, dynamic> dinner = {
    'count': 0,
    'days': List<bool>.filled(7, false),
    'time': TimeOfDay.now(),
    'isOn': false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final firestore = FirebaseFirestore.instance;
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      final collectionRef = firestore
          .collection('users')
          .doc(userEmail)
          .collection('fs_service')
          .doc('packs'); // Ensure this document ID is correct

      final doc = await collectionRef.get();
      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          fromDate = _getDateFromData(data['fromDate']);
          endingDate = _getDateFromData(data['endingDate']);

          breakfast = {
            'count': data['breakfastCount'] ?? 0,
            'days': List<bool>.from(data['breakfastDays'] ?? List.filled(7, false)),
            'time': _convertTimestampToTimeOfDay(_getTimestampFromData(data['breakfastTime'])),
            'isOn': data['breakfastIsOn'] ?? false,
          };
          lunch = {
            'count': data['lunchCount'] ?? 0,
            'days': List<bool>.from(data['lunchDays'] ?? List.filled(7, false)),
            'time': _convertTimestampToTimeOfDay(_getTimestampFromData(data['lunchTime'])),
            'isOn': data['lunchIsOn'] ?? false,
          };
          snack = {
            'count': data['snackCount'] ?? 0,
            'days': List<bool>.from(data['snackDays'] ?? List.filled(7, false)),
            'time': _convertTimestampToTimeOfDay(_getTimestampFromData(data['snackTime'])),
            'isOn': data['snackIsOn'] ?? false,
          };
          dinner = {
            'count': data['dinnerCount'] ?? 0,
            'days': List<bool>.from(data['dinnerDays'] ?? List.filled(7, false)),
            'time': _convertTimestampToTimeOfDay(_getTimestampFromData(data['dinnerTime'])),
            'isOn': data['dinnerIsOn'] ?? false,
          };
          price = data['totalPrice'] ?? 0;
        });

        _calculatePrice();
      } else {
        print('Document does not exist');
      }
    } else {
      print('No user is signed in');
    }
  }

  DateTime _getDateFromData(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      throw Exception('Invalid type for date: ${value.runtimeType}');
    }
  }

  Timestamp _getTimestampFromData(dynamic value) {
    if (value is Timestamp) {
      return value;
    } else if (value is String) {
      return Timestamp.fromDate(DateTime.parse(value));
    } else {
      throw Exception('Invalid type for timestamp: ${value.runtimeType}');
    }
  }

  TimeOfDay _convertTimestampToTimeOfDay(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return TimeOfDay.fromDateTime(dateTime);
  }

  void _calculatePrice() {
    // Implement price calculation based on fetched data if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                initialTime: breakfast['time'],
                initialIsOn: breakfast['isOn'],
                onChanged: (count, days, time, isOn) {
                  updateMeal('Breakfast', count, days, time, isOn);
                },
              ),
              AlarmSetting(
                title: 'Lunch',
                initialTime: lunch['time'],
                initialIsOn: lunch['isOn'],
                onChanged: (count, days, time, isOn) {
                  updateMeal('Lunch', count, days, time, isOn);
                },
              ),
              AlarmSetting(
                title: 'Snack',
                initialTime: snack['time'],
                initialIsOn: snack['isOn'],
                onChanged: (count, days, time, isOn) {
                  updateMeal('Snack', count, days, time, isOn);
                },
              ),
              AlarmSetting(
                title: 'Dinner',
                initialTime: dinner['time'],
                initialIsOn: dinner['isOn'],
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
