import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final int price;
  final String image;
  final String desc;
  final String restaurant;
  final double rating;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.desc,
    required this.restaurant,
    required this.rating,
  });
}

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

  late Map<String, dynamic> breakfast;
  late Map<String, dynamic> lunch;
  late Map<String, dynamic> snack;
  late Map<String, dynamic> dinner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    packID = args['id'];
    futurePack = fetchPack(packID);

    fetchUserPackData().then((userData) {
      if (userData != null) {
        setState(() {
          subscriptionType = userData['subscription_type'] ?? 'weekly';
          fromDate = DateTime.parse(userData['fromDate']);
          endingDate = DateTime.parse(userData['endingDate']);

          breakfast = {
            'count': userData['breakfastCount'] ?? 1,
            'days': List<bool>.from(userData['breakfastDays'] ?? List.generate(7, (_) => true)),
            'time': _parseTimeOfDay(userData['breakfastTime'] ?? '07:00'),
            'isOn': userData['breakfastIsOn'] ?? true,
          };
          lunch = {
            'count': userData['lunchCount'] ?? 1,
            'days': List<bool>.from(userData['lunchDays'] ?? List.generate(7, (_) => true)),
            'time': _parseTimeOfDay(userData['lunchTime'] ?? '12:00'),
            'isOn': userData['lunchIsOn'] ?? true,
          };
          snack = {
            'count': userData['snackCount'] ?? 1,
            'days': List<bool>.from(userData['snackDays'] ?? List.generate(7, (_) => true)),
            'time': _parseTimeOfDay(userData['snackTime'] ?? '16:00'),
            'isOn': userData['snackIsOn'] ?? true,
          };
          dinner = {
            'count': userData['dinnerCount'] ?? 1,
            'days': List<bool>.from(userData['dinnerDays'] ?? List.generate(7, (_) => true)),
            'time': _parseTimeOfDay(userData['dinnerTime'] ?? '19:00'),
            'isOn': userData['dinnerIsOn'] ?? true,
          };
        });
      }
    });
  }


  TimeOfDay _parseTimeOfDay(String time) {
    try {
      final regex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
      final match = regex.firstMatch(time.trim());

      if (match == null) {
        print('Time format error: $time');
        return TimeOfDay(hour: 0, minute: 0); // Return a default value or handle it appropriately
      }

      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String? period = match.group(3);

      if (period != null) {
        if (period.toUpperCase() == 'PM' && hour != 12) {
          hour += 12;
        } else if (period.toUpperCase() == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time: $time, Error: $e');
      return TimeOfDay(hour: 0, minute: 0); // Return a default value or handle it appropriately
    }
  }



  Future<void> _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onDateSelected) async {
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

  Future<Map<String, dynamic>?> fetchUserPackData() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('fs_service')
          .doc('packs')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        print('Fetched user pack data: $data');
        return data;
      }
    }
    return null;
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

  Future<DocumentSnapshot<Map<String, dynamic>>>? futurePack;
  String selectedOption = 'weekly';

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchPack(String packID) async {
    return await FirebaseFirestore.instance.collection('fs_packs').doc(packID).get();
  }

  Future<List<Map<String, dynamic>>> fetchFoodItems(List<String> foodIds) async {
    List<Map<String, dynamic>> foodItems = [];
    for (String foodId in foodIds) {
      DocumentSnapshot<Map<String, dynamic>> foodDoc = await FirebaseFirestore.instance.collection('fs_food_items').doc(foodId).get();
      if (foodDoc.exists) {
        var foodData = foodDoc.data()!;
        foodData['id'] = foodDoc.id;
        foodItems.add(foodData);
      }
    }
    return foodItems;
  }

  void _onCheckoutPressed(String packID) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Navigator.pushNamed(
      context,
      '/fs_s_checkout',
      arguments: {
        'packID': packID,
        'subscription_type': selectedOption,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var packID = args['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Pack'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: futurePack,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No data found'));
                } else {
                  Map<String, dynamic> data = snapshot.data!.data()!;
                  List<String> foodIds = List<String>.from(data['pack_foods']);

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchFoodItems(foodIds),
                    builder: (context, foodSnapshot) {
                      if (foodSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (foodSnapshot.hasError) {
                        return ExpansionTile(
                          title: Text(data['pack_name']),
                          children: [
                            Center(child: Text('Error: ${foodSnapshot.error}'))
                          ],
                        );
                      } else if (!foodSnapshot.hasData || foodSnapshot.data!.isEmpty) {
                        return ExpansionTile(
                          title: Text(data['pack_name']),
                          children: [
                            Center(child: Text('No food items found'))
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                GridView.builder(
                                  itemCount: foodSnapshot.data!.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.9,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemBuilder: (context, index) {
                                    var foodData = foodSnapshot.data![index];
                                    MenuItem item = MenuItem(
                                      id: foodData['id'],
                                      name: foodData['productTitle'],
                                      price: foodData['productPrice'],
                                      image: foodData['productImg'],
                                      desc: foodData['productDesc'],
                                      restaurant: foodData['productOwnership'],
                                      rating: foodData['productRating'],
                                    );
                                    return MenuItemWidget(item: item);
                                  },
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
            _buildDateSetting('From Date', fromDate, (date) {
              setState(() {
                fromDate = date;
              });
            }),
            _buildDateSetting('Ending Date', endingDate, (date) {
              setState(() {
                endingDate = date;
              });
            }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                ],
              ),
            ),
            SizedBox(height: 16),
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
              child: Text('update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),

      ),

    );
  }

  Widget _buildDateSetting(String label, DateTime date, Function(DateTime) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text('$label:'),
          Spacer(),
          TextButton(
            onPressed: () => _selectDate(context, date, onDateSelected),
            child: Text('${date.year}/${date.month}/${date.day}'),
          ),
        ],
      ),
    );
  }
}




class MenuItemWidget extends StatelessWidget {
  final MenuItem item;

  MenuItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${item.price}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < item.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ],
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
