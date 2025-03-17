import 'package:flutter/material.dart';

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
    {'image': 'assets/WellnessModules/Active Hours.png', 'text': 'Active Hours'},
    {'image': 'assets/WellnessModules/Stand Hours.png', 'text': 'Stand Hours'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              borderRadius: BorderRadius.circular(10), // Optional rounded corners
                              child: Image.asset(
                                modules[index]['image']!,
                                fit: BoxFit.cover, // Ensures it fills the square
                              ),
                            ),
                          ),
                          // const SizedBox(height: 5),
                          Text(
                            modules[index]['text']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () {
                        switch (modules[index]['text']!) {
                          case 'Daily Steps':
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const RecordPopup()),
                          // );
                          //   showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return RecordPopup();
                          //     },
                          //   );
                            break;
                          case 'BMI':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BmiScreen()),
                            );
                            break;
                          case 'Sleep':
                            break;
                          case 'Active Hours':
                            break;
                          case 'Stand Hours':
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
    );
  }
}
