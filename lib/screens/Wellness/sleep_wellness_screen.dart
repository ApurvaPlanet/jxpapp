import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jxp_app/providers/wellness_provider.dart';
import 'package:jxp_app/screens/Wellness/add_record_popup.dart';
import 'package:jxp_app/widgets/HistoryTitleWidget.dart';
import 'package:jxp_app/widgets/graph_widget.dart';
import 'package:jxp_app/widgets/list_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../../models/wellness_response.dart';
import '../../widgets/blur_loader.dart';
import '../../widgets/sub_app_bar.dart';

class SleepWellnessScreen extends StatefulWidget {
  const SleepWellnessScreen({super.key});

  @override
  _SleepWellnessState createState() => _SleepWellnessState();
}

class _SleepWellnessState extends State<SleepWellnessScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  List<WellnessDetail> wellnessData = [];
  String selectedPeriod = "Week"; // Default selection
  @override
  void initState() {
    super.initState();
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
        "sleephours",
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

  @override
  Widget build(BuildContext context) {
    final wellnessProvider = Provider.of<WellnessProvider>(context);
    final wellnessData = wellnessProvider.wellnessData;

    // Filter only valid data (sleepHours > 0)
    List<WellnessDetail> filteredData =
        wellnessData?.details.where((entry) => entry.sleepHours > 0).toList() ??
        [];

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/jxp_logo.png', height: 40),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              const SubAppBar(pageTitle: 'Sleep', showBackBtn: true),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: HistoryTitleWidget(
                  title: "Sleep History",
                  items: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddRecordPopup(module: 'sleephours', title: 'Record Sleep', inputText1: 'Sleep Time', inputText2: 'Wake-up Time');
                          },
                        );
                      },
                    ),
                    IconButton(icon: Icon(Icons.refresh), onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SleepWellnessScreen()), // Reload the same screen
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(
                height: 320,
                width: double.infinity,
                child: GraphWidget(
                  wellnessData: filteredData ?? [],
                  selectedPeriod: selectedPeriod, // Pass selected period
                  onPeriodChange: _fetchData, // Pass the function to update API
                  module: 'sleephours',

                ),
              ),
              Expanded(child: ListWidget(wellnessData: filteredData ?? [], module: 'sleephours',)),
            ],
          ),

          // Show loader on top of everything
          if (wellnessProvider.isLoading) BlurLoader(),
        ],
      ),
    );
  }
}
