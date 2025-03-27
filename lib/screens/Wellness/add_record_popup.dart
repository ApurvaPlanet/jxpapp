import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jxp_app/constants/app_constants.dart';
import 'package:provider/provider.dart';

import '../../providers/wellness_provider.dart';

class AddRecordPopup extends StatefulWidget {
  final String module;
  final String title;
  final String inputText1, inputText2;

  const AddRecordPopup({
    super.key,
    required this.module,
    required this.title,
    required this.inputText1,
    required this.inputText2,
  });

  @override
  State<AddRecordPopup> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecordPopup> {
  var hourController = TextEditingController();
  var timeController = TextEditingController();
  double calculatedHours = 0.0;
  VoidCallback? _hourListener;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getScheduleData();
    _hourListener = () {
      if (widget.module == 'activehours') {
        _saveHoursForActiveModule();
      } else if (widget.module == 'standhours') {
        _saveHoursForStandModule();
      }
    };

    hourController.addListener(_hourListener!);
  }

  @override
  void dispose() {
    if (_hourListener != null) {
      hourController.removeListener(_hourListener!);
    }
    hourController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void _getScheduleData() async {
    try {
      final wellnessProvider = Provider.of<WellnessProvider>(
        context,
        listen: false,
      );
      await wellnessProvider.getScheduleDetails();

      if (mounted) {
        final scheduleData = wellnessProvider.scheduleData;

        if (widget.module == 'sleephours') {
          if (scheduleData != null && scheduleData.wakeupTime != null) {
            setState(() {
              timeController.text = scheduleData.wakeupTime!;
              hourController.text = scheduleData.sleepTime!;
              _saveHoursForSleepModule();
            });
          }
        } else if (widget.module == 'activehours') {
          if (scheduleData != null &&
              scheduleData.wakeupTime != null &&
              scheduleData.sleepTime != null) {
            double awakeDuration = calculateHoursBetween(
              scheduleData.wakeupTime!,
              scheduleData.sleepTime!,
            );

            setState(() {
              hourController.text = scheduleData.activityHours.toString();
              timeController.text = awakeDuration.toStringAsFixed(1);
            });
            // Validate immediately after setting initial values
            _saveHoursForActiveModule();
          }
        } else if (widget.module == 'standhours') {
          if (scheduleData != null &&
              scheduleData.wakeupTime != null &&
              scheduleData.sleepTime != null) {
            double awakeDuration = calculateHoursBetween(
              scheduleData.wakeupTime!,
              scheduleData.sleepTime!,
            );

            setState(() {
              hourController.text = scheduleData.standHours.toString();
              timeController.text = awakeDuration.toStringAsFixed(1);
            });
            // Validate immediately after setting initial values
            _saveHoursForStandModule();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching schedule data: $e");
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController tec,
  ) async {
    // Parse existing time from the controller or use current time
    TimeOfDay initialTime;
    if (tec.text.isNotEmpty) {
      List<String> parts = tec.text.split(":");
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      initialTime = TimeOfDay(hour: hour, minute: minute);
    } else {
      initialTime = TimeOfDay.now();
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      String formattedTime =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";

      setState(() {
        tec.text = formattedTime;
        if (widget.module == 'sleephours') {
          _saveHoursForSleepModule();
        } else if (widget.module == 'standhours') {
          _saveHoursForStandModule();
        } else if (widget.module == 'activehours') {
          _saveHoursForActiveModule();
        }
      });
    }
  }

  void _saveHoursForSleepModule() {
    if (hourController.text.isNotEmpty && timeController.text.isNotEmpty) {
      double sleepDuration = calculateHoursBetween(
        hourController.text,
        timeController.text,
      );
      setState(() {
        calculatedHours = sleepDuration;
      });
    }
  }

  void _saveHoursForStandModule() {
    if (hourController.text.isNotEmpty && timeController.text.isNotEmpty) {
      double standingHours = double.tryParse(hourController.text) ?? 0.0;
      double awakeHours = double.tryParse(timeController.text) ?? 0.0;

      if (standingHours > awakeHours) {
        setState(() {
          errorMessage = "Standing hours cannot exceed awake hours!";
        });
        return;
      }

      setState(() {
        calculatedHours = awakeHours - standingHours;
        errorMessage = null; // Clear the error if input is valid
      });
    }
  }

  void _saveHoursForActiveModule() {
    if (hourController.text.isNotEmpty && timeController.text.isNotEmpty) {
      double activeHours = double.tryParse(hourController.text) ?? 0.0;
      double awakeHours = double.tryParse(timeController.text) ?? 0.0;

      if (activeHours > awakeHours) {
        setState(() {
          errorMessage = "Active hours cannot exceed awake hours.";
        });
        return;
      }

      setState(() {
        calculatedHours = awakeHours - activeHours;
        errorMessage = null; // Clear the error if input is valid
      });
    }
  }

  double calculateHoursBetween(String startTime, String endTime) {
    try {
      DateFormat format = DateFormat("HH:mm");

      DateTime start = format.parse(startTime);
      DateTime end = format.parse(endTime);

      if (end.isBefore(start)) {
        end = end.add(Duration(days: 1));
      }

      return end.difference(start).inMinutes / 60.0;
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return 0.0;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                buildInputData(
                  widget.inputText1,
                  '',
                  hourController,
                  Icons.watch_later,
                  openTimePicker: widget.module == 'sleephours',
                ),
                buildInputData(
                  widget.inputText2,
                  '',
                  timeController,
                  Icons.watch_later,
                  readOnly: (widget.module == 'activehours' || widget.module == 'standhours'),
                  openTimePicker: widget.module == 'sleephours',
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  child: Container(
                    height: 40,
                    child: Center(
                      child: Text(
                        widget.module == 'sleephours'? 'Save Sleep Hours : ${calculatedHours.toStringAsFixed(1)}' : 'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: btnsColor, // Change to btnsColor if needed
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onTap: () async {
                    if(errorMessage == null){
                      final wellnessProvider = Provider.of<WellnessProvider>(
                        context,
                        listen: false,
                      );

                      debugPrint(
                        "HourController Value Before Sending: '${hourController.text}'",
                      );

                      if (hourController.text.trim().isNotEmpty) {
                        if(widget.module == 'sleephours'){
                          await wellnessProvider.saveHours(
                            widget.module,
                            hourController.text.trim(),
                            timeController.text.trim(),
                            calculatedHours.toString()
                          );
                        }else{
                          await wellnessProvider.saveHours(
                            widget.module,
                            hourController.text.trim(),
                            "",
                            ""
                          );
                        }


                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Hours saved successfully")),
                        );

                        Navigator.of(
                          context,
                        ).pop(); // Close the dialog after saving
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Invalid input. Please enter a valid time.",
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
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

buildInputData(String type, String measure, TextEditingController tec, IconData? icon, {bool readOnly = false, bool openTimePicker = false}) {
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
            readOnly: openTimePicker ? true : readOnly, // Always read-only
            onTap: openTimePicker ? () => _selectTime(context, tec) : null,
            keyboardType: openTimePicker ? null : TextInputType.numberWithOptions(decimal: true),
          ),
        ),



        // Icon placed outside the TextField (Right Side)
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0), // Adjust spacing
            child: Icon(icon, size: 20, color: graphBarColor.withOpacity(0.6)),
          ),

        const SizedBox(width: 10),
        if (measure.isNotEmpty)
          SizedBox(child: Text(measure), width: 20),
      ],
    );
  }
}
