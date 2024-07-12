import 'package:flutter/material.dart';

class FS_S_Checkout extends StatefulWidget {
  @override
  _FS_S_CheckoutState createState() => _FS_S_CheckoutState();
}

class _FS_S_CheckoutState extends State<FS_S_Checkout> {
  TimeOfDay breakfastTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay lunchTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay snackTime = TimeOfDay(hour: 16, minute: 0);
  TimeOfDay dinnerTime = TimeOfDay(hour: 19, minute: 0);

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      onTimeSelected(picked);
    }
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
            _buildAlarmSetting('Breakfast', breakfastTime, (time) {
              setState(() {
                breakfastTime = time;
              });
            }),
            _buildAlarmSetting('Lunch', lunchTime, (time) {
              setState(() {
                lunchTime = time;
              });
            }),
            _buildAlarmSetting('Snack', snackTime, (time) {
              setState(() {
                snackTime = time;
              });
            }),
            _buildAlarmSetting('Dinner', dinnerTime, (time) {
              setState(() {
                dinnerTime = time;
              });
            }),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmSetting(String title, TimeOfDay time, Function(TimeOfDay) onTimeSelected) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${time.format(context)}'),
            IconButton(
              icon: Icon(Icons.alarm),
              onPressed: () => _selectTime(context, time, onTimeSelected),
            ),
          ],
        ),
      ),
    );
  }
}
