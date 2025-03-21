import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:jxp_app/screens/Wellness/active_hours_Screen.dart';
import 'package:jxp_app/screens/Wellness/sleep_wellness_Screen.dart';
import 'package:jxp_app/screens/Wellness/stand_hours_screen.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/wellness_response.dart';
import '../../providers/wellness_provider.dart';

class EditRecord extends StatefulWidget {

  final String module;
  final String title;
  final String inputText1, inputText2;
  final WellnessDetail wellnessDetail;

  const EditRecord({super.key, required this.module, required this.title, required this.inputText1, required this.inputText2, required this.wellnessDetail});

  @override
  State<EditRecord> createState() => _EditRecordState();
}

class _EditRecordState extends State<EditRecord> {

  String errorMessage = "", totalHoursString = "00:00";

  var input1Controller = TextEditingController();
  var input2Controller = TextEditingController();
  var sleepHourController = TextEditingController();
  var activeHourController = TextEditingController();
  var standHourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.wellnessDetail != null && widget.wellnessDetail.wakeupTime != null) {
      if(widget.module == 'sleephours'){
        input1Controller.text = widget.wellnessDetail.sleepTime!;
        input2Controller.text = widget.wellnessDetail.wakeupTime!;
      }else if(widget.module == 'activehours'){
        input1Controller.text = widget.wellnessDetail.activityHours.toString();
      }else {
        input1Controller.text = widget.wellnessDetail.standHours.toString();
      }
      sleepHourController.text = widget.wellnessDetail.sleepHours.toString();
      activeHourController.text = widget.wellnessDetail.activityHours.toString();
      standHourController.text = widget.wellnessDetail.standHours.toString();

      // Delay to ensure UI updates properly
      Future.delayed(Duration.zero, _updateTotalHours);
    }
  }


  @override
  void dispose() {
    input1Controller.dispose();
    input2Controller.dispose();
    sleepHourController.dispose();
    activeHourController.dispose();
    standHourController.dispose();
    super.dispose();
  }

  Widget buildInputData(String type, String measure, TextEditingController tec, IconData? icon,
      {bool isTimePicker = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$type:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Expanded(child: SizedBox()),

        SizedBox(
          height: 38,
          width: 130,
          child: TextField(
            controller: tec,
            readOnly: isTimePicker, // Only time pickers should be read-only
            keyboardType: isTimePicker ? null : TextInputType.number, // Enable number keyboard if not time picker
            onTap: isTimePicker ? () => _selectTime(context, tec) : null,

          ),
        ),

        const SizedBox(width: 10),
        if (measure.isNotEmpty)
          SizedBox(child: Text(measure), width: 20),
      ],
    );
  }


  Future<void> _selectTime(BuildContext context, TextEditingController tec) async {
    TimeOfDay initialTime = TimeOfDay.now();

    // If the text field has a valid time, use it as the initial time
    if (tec.text.isNotEmpty) {
      DateTime parsedTime = DateFormat("HH:mm").parse(tec.text);
      initialTime = TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input, // Enables both dial & keyboard input
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        tec.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      });
      _calculateHours(); // Update total hours after setting time
    }
  }

  // Function to format the date as DD-MM-YYYY
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString); // Convert string to DateTime
    return DateFormat('dd-MM-yyyy').format(date); // Format to DD-MM-YYYY
  }

  String formatHoursToHHMM(double hours) {
    int h = hours.floor();
    int m = ((hours - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }


  void _calculateHours() {
    try {
      if (input1Controller.text.isEmpty || input2Controller.text.isEmpty) return;

      DateTime sleepTime = DateFormat("HH:mm").parse(input1Controller.text);
      DateTime wakeUpTime = DateFormat("HH:mm").parse(input2Controller.text);

      if (wakeUpTime.isBefore(sleepTime)) {
        wakeUpTime = wakeUpTime.add(Duration(days: 1)); // Handle overnight case
      }

      int sleepMinutes = wakeUpTime.difference(sleepTime).inMinutes;
      double sleepHours = sleepMinutes / 60.0;

      setState(() {
        sleepHourController.text = formatHoursToHHMM(sleepHours);
        _updateTotalHours();
      });

    } catch (e) {
      print("Error calculating hours: $e");
    }
  }


  /*void _updateTotalHours() {
    int sleepHours = int.tryParse(sleepHourController.text.split(":")[0]) ?? 0;
    int sleepMinutes = int.tryParse(sleepHourController.text.split(":")[1]) ?? 0;

    int activeHours = int.tryParse(activeHourController.text.split(":")[0]) ?? 0;
    int activeMinutes = int.tryParse(activeHourController.text.split(":")[1]) ?? 0;

    int standHours = int.tryParse(standHourController.text.split(":")[0]) ?? 0;
    int standMinutes = int.tryParse(standHourController.text.split(":")[1]) ?? 0;

    // Convert everything to minutes
    int totalMinutes = (sleepHours * 60 + sleepMinutes) +
        (activeHours * 60 + activeMinutes) +
        (standHours * 60 + standMinutes);

    // Handle overflow cases (More than 24 hours)
    if (totalMinutes > 1440) {
      totalMinutes = 1440; // Cap at 24 hours
    }

    // Convert back to HH:mm format
    int totalHrs = totalMinutes ~/ 60;
    int totalMins = totalMinutes % 60;

    setState(() {
      totalHoursString = "${totalHrs.toString().padLeft(2, '0')}:${totalMins.toString().padLeft(2, '0')}";
    });
  }*/

  void _updateTotalHours() {
    double sleepHours = _parseHours(sleepHourController.text);
    double activeHours = _parseHours(activeHourController.text);
    double standHours = _parseHours(standHourController.text);

    // Calculate total hours
    double totalHours = sleepHours + activeHours + standHours;

    // Ensure totalHours does not exceed 24
    if (totalHours > 24) {
      totalHours = 24;
    }

    // Convert totalHours back to HH:mm format
    int totalHrs = totalHours.floor();
    int totalMins = ((totalHours - totalHrs) * 60).round();

    setState(() {
      totalHoursString =
      "${totalHrs.toString().padLeft(2, '0')}:${totalMins.toString().padLeft(2, '0')}";
    });
  }

  void _saveHoursToAPI(int wellnessId, String module, String wakeupTime, int dailySteps, double standHours, double activeHours, String sleepTime, double sleepHours) async {
    final wellnessProvider = Provider.of<WellnessProvider>(context, listen: false);

    await wellnessProvider.editHours(
        wellnessId,
        widget.module,
        wakeupTime,
        dailySteps ?? 0,
        standHours,
        activeHours,
        sleepTime,
        sleepHours
    );

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hours saved successfully!"))
    );

    Navigator.of(context).pop();

    if(widget.module == 'activehours'){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ActiveHoursScreen()), // Reload the same screen
      );
    }else if(widget.module == 'standhours') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StandHoursScreen()), // Reload the same screen
      );
    }else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SleepWellnessScreen()), // Reload the same screen
      );
    }

  }


// Helper function to parse hours from either HH:mm format or decimal format
  double _parseHours(String text) {
    if (text.contains(":")) {
      // HH:mm format
      List<String> parts = text.split(":");
      int hours = int.tryParse(parts[0]) ?? 0;
      int minutes = int.tryParse(parts[1]) ?? 0;
      return hours + (minutes / 60.0);
    } else {
      // Decimal format
      return double.tryParse(text) ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Date: ${formatDate(widget.wellnessDetail.date.toString())}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                buildInputData(
                  widget.inputText1,
                  'Hr',
                  input1Controller,
                  null,
                  isTimePicker: widget.module == 'sleephours',
                ),
                if (widget.inputText2.isNotEmpty)
                  buildInputData(
                    widget.inputText2,
                    'Hr',
                    input2Controller,
                    null,
                    isTimePicker: widget.module == 'sleephours',
                  ),
                buildInputData(
                  'Sleep Hour',
                  'Hr',
                  sleepHourController,
                  null,
                  isTimePicker: false,
                ),
                if(widget.module != 'activehours')
                  buildInputData(
                    'Active Hour',
                    'Hr',
                    activeHourController,
                    null,
                    isTimePicker: false,
                  ),
                if(widget.module != 'standhours')
                  buildInputData(
                    'Stand Hour',
                    'Hr',
                    standHourController,
                    null,
                    isTimePicker: false,
                  ),
                const SizedBox(height: 30),
                GestureDetector(
                    child: Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: btnsColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onTap: () {
                      _updateTotalHours(); // Update the total hours first

                      if (totalHoursString == "24:00") {
                        _saveHoursToAPI(
                          widget.wellnessDetail.wellnessId,
                          widget.module,
                          input2Controller.text,
                          0,
                          double.parse(standHourController.text),
                          double.parse(activeHourController.text),
                          input1Controller.text,
                          double.parse(sleepHourController.text),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Total hours must be 24 to save!")),
                        );
                      }
                    }

                ),
                const SizedBox(height: 10),
                Text(
                  "Total Hours: $totalHoursString hr",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: totalHoursString == "24:00" ? Colors.green : Colors.red,
                  ),
                ),


              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );

  }
}

