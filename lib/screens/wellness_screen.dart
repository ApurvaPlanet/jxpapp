import 'package:flutter/material.dart';
import 'package:jxp_app/screens/Wellness/active_hours_Screen.dart';
import 'package:jxp_app/screens/Wellness/daily_steps_screen.dart';
import 'package:jxp_app/screens/Wellness/sleep_wellness_Screen.dart';
import 'package:jxp_app/screens/Wellness/stand_hours_screen.dart';

import '../constants/app_constants.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/sub_app_bar.dart';
import 'Wellness/bmi_screen.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  final List<Map<String, String>> modules = [
    {'image': 'assets/WellnessModules/Daily Steps.png', 'text': 'Daily Steps'},
    {'image': 'assets/WellnessModules/BMI.png', 'text': 'BMI'},
    {'image': 'assets/WellnessModules/Sleep.png', 'text': 'Sleep'},
    {
      'image': 'assets/WellnessModules/Active Hours.png',
      'text': 'Active Hours',
    },
    {'image': 'assets/WellnessModules/Stand Hours.png', 'text': 'Stand Hours'},
  ];

  Future<bool> showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Exit App"),
                content: Text("Are you sure you want to exit?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Yes"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: appBackground,
        appBar: MainAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              // Banner with Text Overlay
              const SubAppBar(pageTitle: 'Wellness'),

              // GridView inside Expanded to prevent layout errors
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 items per row
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1, // Square images
                        ),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                // Optional rounded corners
                                child: Image.asset(
                                  modules[index]['image']!,
                                  fit:
                                      BoxFit
                                          .cover, // Ensures it fills the square
                                ),
                              ),
                            ),
                            // const SizedBox(height: 5),
                            Text(
                              modules[index]['text']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          switch (modules[index]['text']!) {
                            case 'Daily Steps':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DailyStepsPage(),
                                ),
                              );
                              break;
                            case 'BMI':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BmiScreen(),
                                ),
                              );
                              break;
                            case 'Sleep':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const SleepWellnessScreen(),
                                ),
                              );
                              break;
                            case 'Active Hours':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ActiveHoursScreen(),
                                ),
                              );
                              break;
                            case 'Stand Hours':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const StandHoursScreen(),
                                ),
                              );
                              break;
                            default:
                              break;
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        bool exitApp = await showExitDialog(context);
        return exitApp;
      },
    );
  }
}
