import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jxp_app/providers/dailysteps_provider.dart';
import 'package:jxp_app/services/database_service.dart';
import 'package:jxp_app/widgets/HistoryTitleWidget.dart';
import 'package:jxp_app/widgets/main_app_bar.dart';
import 'package:jxp_app/widgets/sub_app_bar.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../models/wellness_response.dart';
import '../../providers/wellness_provider.dart';
import '../../widgets/blur_loader.dart';
import '../../widgets/graph_widget.dart';


class DailyStepsPage extends StatefulWidget {
  const DailyStepsPage({super.key});

  @override
  State<DailyStepsPage> createState() => _DailyStepsPageState();
}

class _DailyStepsPageState extends State<DailyStepsPage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  List<WellnessDetail> wellnessData = [];
  String selectedPeriod = "Week"; // Default selection

  DatabaseService _dbService = DatabaseService.instance;

  String _status = '', _steps = '', _kCal = '';
  var _stepsOffline = 0;
  int height = 0, weight = 0;

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    initPlatformState();
    getUserDetails();
    // getDailyStepsData();
    super.initState();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);

    print(formattedDate);

    _fetchData(selectedPeriod);
  }

  void _fetchData(String period) {
    DateTime now = DateTime.now();
    DateTime from, to = now;

    switch (period) {
      case "Day":
        from = now;
        to = now;
        break;
      case "Week":
        from = now.subtract(
          Duration(days: now.weekday - 1),
        ); // Start of the week (Monday)
        to = from.add(Duration(days: 6)); // End of the week (Sunday)
        break;
      case "Month":
        from = DateTime(now.year, now.month, 1); // Start of the month
        to = DateTime(now.year, now.month + 1, 0); // End of the month
        break;
      case "6M":
        int currentMonth = now.month;
        if (currentMonth >= 1 && currentMonth <= 6) {
          // If in Jan - June, show Jan to June
          from = DateTime(now.year, 1, 1);
          to = DateTime(now.year, 6, 30);
        } else {
          // If in July - Dec, show July to Dec
          from = DateTime(now.year, 7, 1);
          to = DateTime(now.year, 12, 31);
        }
        break;
      case "Year":
        from = DateTime(now.year, 1, 1); // Start from Jan 1 of current year
        to = DateTime(now.year, 12, 31); // End at Dec 31 of current year
        break;
      default:
        from = now.subtract(Duration(days: 7));
    }

    String formattedFromDate = DateFormat("dd-MM-yyyy").format(from);
    String formattedToDate = DateFormat("dd-MM-yyyy").format(to);

    print("fromDate - " + formattedFromDate + ", toDate - " + formattedToDate);

    try {
      Provider.of<WellnessProvider>(context, listen: false).getWellnessDetail(
        "dailysteps",
        formattedFromDate,
        formattedToDate,
      );

      print("Fetching data for: $period"); // Debugging
      setState(() {
        selectedPeriod = period; // Ensure UI updates
      });
    } catch (e) {
      print("Error fetching wellness data: $e");
    }
  }

  getStepsFromDB() async {
    var list = await _dbService.getDailyStepsDB();
    print('Steps from DB: ${list.map((e) => '${e.date}: ${e.steps}')}');

    if (list.isNotEmpty) {
      setState(() {
        _steps = list.last.steps; // Show latest step count
      });
    }
  }

  Future<void> getUserDetails() async {
    var prefs = await SharedPreferences.getInstance();
    var idStr = prefs.get('userId').toString();
    var id = int.parse(idStr);

    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<WellnessProvider>(context, listen: false).getBMIDetail(id, 'bmi');
      var bmiResponse = Provider.of<WellnessProvider>(context, listen: false).bmiResponse;
      setState(() {
        height = bmiResponse?.height ?? 0;
        weight = bmiResponse?.weight ?? 0;
        _isLoading = false;
      });
      // calculateBMI();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage("Failed to get details. Try again. Error: $e");
    }
    getStepsFromDB();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepsOffline = prefs.getInt('stepsOffline') ?? 0;
    });
  }

  // Handle step count changed
  // void onStepCount(StepCount event) {
  //   print("Step Event Received: ${event.steps} at ${event.timeStamp}");
  //   int steps = event.steps;
  //   DateTime timeStamp = event.timeStamp;
  //   String formattedDate = DateFormat('dd-MM-yyyy').format(timeStamp);
  //
  //   setState(() {
  //     _steps = event.steps.toString();
  //     _kCal = '${calculateCaloriesBurned(steps, double.parse('$weight'), 'walking')}';
  //   });
  // }

  void onStepCount(StepCount event) async {
    int steps = event.steps;
    DateTime timeStamp = event.timeStamp;
    String formattedDate = DateFormat('dd-MM-yyyy').format(timeStamp);

    setState(() {
      _steps = event.steps.toString();
      _kCal = '${calculateCaloriesBurned(steps, double.parse('$weight'), 'walking')}';
    });

    // Save steps to local database
    await _dbService.addSteps(_steps, formattedDate);
  }

  /// Handle status changed
  void onPedestrianStatusChanged(PedestrianStatus event) {
    String status = event.status;
    DateTime timeStamp = event.timeStamp;

    setState(() {
      _status = event.status;
    });
  }

  /// Handle the error
  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  /// Handle the error
  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  Future<void> initPlatformState() async {
    // Init streams
    _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    _stepCountStream = await Pedometer.stepCountStream;

    // Listen to streams and handle errors
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
  }

  // Future<void> initPlatformState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   int? savedBaseSteps = prefs.getInt('baseSteps');
  //
  //   _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
  //   _stepCountStream = await Pedometer.stepCountStream;
  //
  //   _stepCountStream.listen((event) {
  //     if (savedBaseSteps == null) {
  //       prefs.setInt('baseSteps', event.steps);
  //     }
  //     onStepCount(event);
  //   }).onError(onStepCountError);
  //
  //   _pedestrianStatusStream
  //       .listen(onPedestrianStatusChanged)
  //       .onError(onPedestrianStatusError);
  // }

  double calculateCaloriesBurned(int steps, double weightKg, String activityType) {
    // Calories per step based on activity type
    double caloriesPerStep;

    switch (activityType.toLowerCase()) {
      case 'walking':
        caloriesPerStep = 0.04; // Approximate value for walking (3 mph)
        break;
      case 'brisk walking':
        caloriesPerStep = 0.05; // Brisk walking (4 mph)
        break;
      case 'running':
        caloriesPerStep = 0.1; // Running (6 mph)
        break;
      default:
        caloriesPerStep = 0.04; // Default to walking
    }

    double calories = steps * caloriesPerStep;

    return double.parse(calories.toStringAsFixed(2));
  }




  @override
  Widget build(BuildContext context) {

    final wellnessProvider = Provider.of<WellnessProvider>(context);
    final wellnessData = wellnessProvider.wellnessData;

    // Filter only valid data (sleepHours > 0)
    List<WellnessDetail> filteredData =
        wellnessData?.details.where((entry) => entry.dailySteps > 0).toList() ??
            [];

    return Scaffold(
      backgroundColor: appBackground,
      appBar: MainAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SubAppBar(
                pageTitle: 'Daily Steps',
                showBackBtn: true,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    HistoryTitleWidget(
                      title: "Today's Status",
                      items: [
                        IconButton(icon: Icon(Icons.refresh), onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => DailyStepsPage()), // Reload the same screen
                          );
                        }),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width - 30,
                      // height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white, // background color
                        borderRadius: BorderRadius.circular(5), // corner radius
                      ),
                      child: Column(
                        children: [
                          Text('$_steps steps', style: TextStyle(fontSize: 20)),
                          // Text('$_stepsOffline steps offline', style: TextStyle(fontSize: 20)),
                          Text('Approximate calories burned: $_kCal'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    HistoryTitleWidget(
                      title: "History",
                      items: [],
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: GraphWidget(
                        wellnessData: filteredData ?? [],
                        selectedPeriod: selectedPeriod, // Pass selected period
                        onPeriodChange: _fetchData, // Pass the function to update API
                        module: 'dailysteps',

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_isLoading)
            BlurLoader()
        ],
      ),
    );
  }

}
