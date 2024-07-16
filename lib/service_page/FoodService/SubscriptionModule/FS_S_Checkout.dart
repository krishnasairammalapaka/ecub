import 'package:flutter/material.dart';

class FS_S_Checkout extends StatefulWidget {
  @override
  _FS_S_CheckoutState createState() => _FS_S_CheckoutState();
}

class _FS_S_CheckoutState extends State<FS_S_Checkout> {
  DateTime fromDate = DateTime.now();
  DateTime endingDate = DateTime.now().add(Duration(days: 7));
  double price = 0.0;

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

  void _calculatePrice() {
    setState(() {
      // Simple example price calculation based on the number of days
      int days = endingDate.difference(fromDate).inDays + 1;
      price = days * 10.0; // Example: $10 per day
    });
  }

  @override
  void initState() {
    super.initState();
    _calculatePrice();
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
            ),
            AlarmSetting(
              title: 'Lunch',
              initialTime: TimeOfDay(hour: 12, minute: 0),
            ),
            AlarmSetting(
              title: 'Snack',
              initialTime: TimeOfDay(hour: 16, minute: 0),
            ),
            AlarmSetting(
              title: 'Dinner',
              initialTime: TimeOfDay(hour: 19, minute: 0),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Text(
                    'Total Price: \$${price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Handle finish action
                    },
                    child: Text('Finish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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

  Widget _buildDateSetting(String title, DateTime date, Function(DateTime) onDateSelected) {
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

  AlarmSetting({required this.title, required this.initialTime});

  @override
  _AlarmSettingState createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {
  bool isExpanded = false;
  bool isOn = true;
  TimeOfDay selectedTime;
  List<bool> selectedDays = List.generate(7, (_) => false);
  int foodCount = 1;

  _AlarmSettingState() : selectedTime = TimeOfDay(hour: 7, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${selectedTime.format(context)}'),
                IconButton(
                  icon: Icon(Icons.alarm),
                  onPressed: () => _selectTime(context),
                ),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
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
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('On/Off'),
                  value: isOn,
                  onChanged: (value) {
                    setState(() {
                      isOn = value;
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
                        });
                      },
                    ),
                    Text('$foodCount'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          foodCount++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
      ),
    );
  }
}
