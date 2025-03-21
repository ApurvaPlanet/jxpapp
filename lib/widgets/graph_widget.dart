import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jxp_app/constants/app_constants.dart';
import 'package:jxp_app/models/wellness_response.dart';
import 'package:http/http.dart' as http;

class GraphWidget extends StatefulWidget {

  final List<WellnessDetail> wellnessData;
  final String selectedPeriod;
  final Function(String) onPeriodChange; // Callback to notify period change
  final String module;

  const GraphWidget({super.key, required this.wellnessData, required this.selectedPeriod, required this.onPeriodChange, required this.module});

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  late String selectedPeriod;
  final List<String> _rangeOptions = ["Day", "Week", "Month", "6M", "Year"];

  List<BarChartGroupData> _chartData = [];
  List<WellnessDetail> _sleepData = [];

  Map<String, double> sixMonthSleepData = {}; // Key: "MM-yyyy",
  Map<String, double> yearlySleepData = {};


  @override
  void initState() {
    super.initState();
    _sleepData = widget.wellnessData;
    selectedPeriod = widget.selectedPeriod;
    _updateChartData();
  }

  @override
  void didUpdateWidget(GraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wellnessData != oldWidget.wellnessData) {
      setState(() {
        _sleepData = widget.wellnessData;
        _updateChartData();
      });
    }
  }

  /// Updates the chart data from API results
  void _updateChartData() {
    if (selectedPeriod == '6M') {
      _prepareSixMonthChartData(widget.module);
    } else if (selectedPeriod == 'Year') {
      _prepareYearChartData(widget.module);
    } else if (selectedPeriod == 'Month') {
      _prepareMonthChartData(widget.module);
    } else if (selectedPeriod == 'Week') {
      _prepareWeekChartData(widget.module);
    } else {
      _prepareRegularChartData(widget.module);
    }
  }

  void _prepareWeekChartData(String module) {
    List<BarChartGroupData> data = [];
    List<DateTime> availableDates = _sleepData.map((e) => e.date).toList();

    for (var date in availableDates) {

      if(module == 'standhours'){
        double standHours = _sleepData.firstWhere(
              (entry) => DateFormat("yyyy-MM-dd").format(entry.date) == DateFormat("yyyy-MM-dd").format(date),
          orElse: () => WellnessDetail(date: date, sleepHours: 0, wakeupTime: '', dailySteps: 0, standHours: 0, activityHours: 0, sleepTime: '', wellnessId: 0),
        ).standHours;

        data.add(
          BarChartGroupData(
            x: availableDates.indexOf(date), // Ensure proper indexing
            barRods: [
              BarChartRodData(
                toY: standHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }else if (module == 'activehours'){
        double activeHours = _sleepData.firstWhere(
              (entry) => DateFormat("yyyy-MM-dd").format(entry.date) == DateFormat("yyyy-MM-dd").format(date),
          orElse: () => WellnessDetail(date: date, sleepHours: 0, wakeupTime: '', dailySteps: 0, standHours: 0, activityHours: 0, sleepTime: '', wellnessId: 0),
        ).activityHours;

        data.add(
          BarChartGroupData(
            x: availableDates.indexOf(date), // Ensure proper indexing
            barRods: [
              BarChartRodData(
                toY: activeHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }else {
        double sleepHours = _sleepData.firstWhere(
              (entry) => DateFormat("yyyy-MM-dd").format(entry.date) == DateFormat("yyyy-MM-dd").format(date),
          orElse: () => WellnessDetail(date: date, sleepHours: 0, wakeupTime: '', dailySteps: 0, standHours: 0, activityHours: 0, sleepTime: '', wellnessId: 0),
        ).sleepHours;

        data.add(
          BarChartGroupData(
            x: availableDates.indexOf(date), // Ensure proper indexing
            barRods: [
              BarChartRodData(
                toY: sleepHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }

    }

    setState(() {
      _chartData = data;
    });
  }


  void _prepareMonthChartData(String module) {
    List<BarChartGroupData> data = [];

    List<DateTime> availableDates = _sleepData.map((e) => e.date).toList();

    for (var date in availableDates) {

      if(module == 'standhours') {
        double standHours = _sleepData.firstWhere(
              (entry) => DateFormat("yyyy-MM-dd").format(entry.date) == DateFormat("yyyy-MM-dd").format(date),
          orElse: () => WellnessDetail(date: date, sleepHours: 0, wakeupTime: '', dailySteps: 0, standHours: 0, activityHours: 0, sleepTime: '', wellnessId: 0),
        ).standHours;

        data.add(
          BarChartGroupData(
            x: availableDates.indexOf(date),
            barRods: [
              BarChartRodData(
                toY: standHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }else if(module == 'activehours') {
        double activeHours = _sleepData.firstWhere(
              (entry) => DateFormat("yyyy-MM-dd").format(entry.date) == DateFormat("yyyy-MM-dd").format(date),
          orElse: () => WellnessDetail(date: date, sleepHours: 0, wakeupTime: '', dailySteps: 0, standHours: 0, activityHours: 0, sleepTime: '', wellnessId: 0),
        ).activityHours;

        data.add(
          BarChartGroupData(
            x: availableDates.indexOf(date),
            barRods: [
              BarChartRodData(
                toY: activeHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }else {
        double sleepHours = _sleepData.firstWhere(
              (entry) => DateFormat("yyyy-MM-dd").format(entry.date) == DateFormat("yyyy-MM-dd").format(date),
          orElse: () => WellnessDetail(date: date, sleepHours: 0, wakeupTime: '', dailySteps: 0, standHours: 0, activityHours: 0, sleepTime: '', wellnessId: 0),
        ).sleepHours;

        data.add(
          BarChartGroupData(
            x: availableDates.indexOf(date),
            barRods: [
              BarChartRodData(
                toY: sleepHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _chartData = data;
    });
  }


  void _prepareSixMonthChartData(String module) {
    sixMonthSleepData.clear();
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    bool isFirstHalf = currentMonth <= 6;

    DateTime from = isFirstHalf ? DateTime(now.year, 1, 1) : DateTime(now.year, 7, 1);
    DateTime to = isFirstHalf ? DateTime(now.year, 6, 30) : DateTime(now.year, 12, 31);

    for (var entry in _sleepData) {
      if (entry.date.isAfter(from.subtract(Duration(days: 1))) && entry.date.isBefore(to.add(Duration(days: 1)))) {
        String monthLabel = DateFormat("MMM").format(entry.date);
        if(module == 'activehours'){
          sixMonthSleepData[monthLabel] = (sixMonthSleepData[monthLabel] ?? 0) + entry.activityHours;
        }else if(module == 'standhours'){
          sixMonthSleepData[monthLabel] = (sixMonthSleepData[monthLabel] ?? 0) + entry.standHours;
        }else {
          sixMonthSleepData[monthLabel] = (sixMonthSleepData[monthLabel] ?? 0) + entry.sleepHours;
        }
      }
    }

    List<BarChartGroupData> data = [];
    int index = 0;
    sixMonthSleepData.forEach((key, value) {
      data.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 10,
            color: graphBarColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
      index++;
    });

    setState(() {
      _chartData = data;
    });
  }

  void _prepareYearChartData(String module) {
    yearlySleepData.clear();

    for (var entry in _sleepData) {
      String monthLabel = DateFormat("MMM").format(entry.date); // Convert date to month name
      if(module == 'standhours'){
        yearlySleepData[monthLabel] = (yearlySleepData[monthLabel] ?? 0) + entry.standHours;
      }else if(module == 'activehours'){
        yearlySleepData[monthLabel] = (yearlySleepData[monthLabel] ?? 0) + entry.activityHours;
      } else{
        yearlySleepData[monthLabel] = (yearlySleepData[monthLabel] ?? 0) + entry.sleepHours;
      }
    }

    List<BarChartGroupData> data = [];
    List<String> availableMonths = yearlySleepData.keys.toList(); // Get only months with data
    availableMonths.sort((a, b) => DateFormat("MMM").parse(a).month.compareTo(DateFormat("MMM").parse(b).month)); // Ensure correct order

    for (int i = 0; i < availableMonths.length; i++) {
      String month = availableMonths[i];

      data.add(
        BarChartGroupData(
          x: i, // Proper indexing based on available months
          barRods: [
            BarChartRodData(
              toY: yearlySleepData[month]!,
              width: 10,
              color: graphBarColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    setState(() {
      _chartData = data;
    });
  }





  /*/// Groups data into 6-month periods and updates `_chartData`
  void _prepareSixMonthChartData() {
    sixMonthSleepData.clear();

    for (var entry in _sleepData) {
      int month = entry.date.month;
      int year = entry.date.year;

      String periodLabel = month <= 6 ? "Jan-Jun $year" : "Jul-Dec $year";

      sixMonthSleepData[periodLabel] =
          (sixMonthSleepData[periodLabel] ?? 0) + entry.sleepHours;
    }

    List<BarChartGroupData> data = [];
    int index = 0;
    sixMonthSleepData.forEach((key, value) {
      data.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 10,
            color: graphBarColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
      index++;
    });

    setState(() {
      _chartData = data;
    });
  }

  /// Groups data by year and updates `_chartData`
  void _prepareYearChartData() {
    yearlySleepData.clear();

    for (var entry in _sleepData) {
      String year = entry.date.year.toString();
      yearlySleepData[year] = (yearlySleepData[year] ?? 0) + entry.sleepHours;
    }

    List<BarChartGroupData> data = [];
    int index = 0;
    yearlySleepData.forEach((key, value) {
      data.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 10,
            color: graphBarColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
      index++;
    });

    setState(() {
      _chartData = data;
    });
  }*/

  /// Processes regular data (Day, Week, Month)
  void _prepareRegularChartData(String module) {
    List<BarChartGroupData> data = [];

    for (int i = 0; i < _sleepData.length; i++) {
      if(module == 'standhours') {
        data.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _sleepData[i].standHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }else if(module == 'activehours') {
        data.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _sleepData[i].activityHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }else {
        data.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _sleepData[i].sleepHours,
                width: 10,
                color: graphBarColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Bar with Selection
        Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: appthemeDark, // Dark blue background
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _rangeOptions.map((label) {
              bool isSelected = selectedPeriod == label;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPeriod = label;
                  });
                  widget.onPeriodChange(selectedPeriod);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? graphBarColor.withOpacity(0.31) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 10), // Spacing

        // Graph Section
        if (_sleepData.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No data available for the selected period.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 25),
            child: SizedBox(
              height: 255, // Restrict graph height
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: _chartData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30, // Space for text
                        getTitlesWidget: (value, meta) {
                          return Text(
                            " ${value.toInt()}", // Right Y-axis labels
                            style: TextStyle(fontSize: 12), // Change size & color
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= _chartData.length) {
                            return const SizedBox(); // Prevents RangeError
                          }

                          if (selectedPeriod == 'Year') {
                            /*List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                            return Text(months[index], style: const TextStyle(fontSize: 12));*/
                            List<String> years = yearlySleepData.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < years.length) {
                              return Text(years[value.toInt()], style: TextStyle(fontSize: 12),);
                            }else{
                              return const Text('', style: TextStyle(fontSize: 12),);
                            }
                          } else if (selectedPeriod == '6M') {
                            List<String> periods = sixMonthSleepData.keys.toList();
                            return index < periods.length ? Text(periods[index], style: const TextStyle(fontSize: 12)) : const SizedBox();
                          } else {
                            DateTime itemDate = _sleepData[index].date;
                            String formattedDate = DateFormat("dd-MM").format(itemDate);
                            return Text(formattedDate, style: const TextStyle(fontSize: 12));
                          }
                        },
                       /* getTitlesWidget: (value, meta) {
                          if (selectedPeriod == 'Year') {
                            List<String> years = yearlySleepData.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < years.length) {
                              return Text(years[value.toInt()], style: TextStyle(fontSize: 12),);
                            }
                          } else if (selectedPeriod == '6M') {
                            List<String> periods = sixMonthSleepData.keys.toList();
                            if (value.toInt() >= 0 && value.toInt() < periods.length) {
                              return Text(periods[value.toInt()], style: TextStyle(fontSize: 12),);
                            }
                          } else if (_chartData.isNotEmpty && value.toInt() < _chartData.length) {
                            DateTime itemDate = _sleepData[value.toInt()].date;
                            String formattedDate = DateFormat("dd-MM").format(itemDate);
                            return Text(formattedDate, style: TextStyle(fontSize: 12),);
                          }
                          return const Text('', style: TextStyle(fontSize: 12),);
                        },*/
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(enabled: true),
                ),
              ),
            ),
          ),
      ],
    );

  }
}
