import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:jxp_app/providers/wellness_provider.dart';
import 'package:jxp_app/widgets/HistoryTitleWidget.dart';
import 'package:jxp_app/widgets/main_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../widgets/blur_loader.dart';
import '../../widgets/sub_app_bar.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {

  var heightController = TextEditingController();
  var weightController = TextEditingController();

  String bmiResult = "";

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    getUserDetails();
    super.initState();
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
        heightController.text = '${bmiResponse?.height}';
        weightController.text = '${bmiResponse?.weight}';
        _isLoading = false;
      });
      calculateBMI();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage("Failed to get details. Try again. Error: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: MainAppBar(),
      body: SingleChildScrollView(
        child: Stack(
          children:[
            Column(
            children: [
              const SubAppBar(pageTitle: 'BMI', showBackBtn: true,),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HistoryTitleWidget(
                      title: "BMI Calculator",
                      items: [
                        IconButton(icon: Icon(Icons.refresh), onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => BmiScreen()), // Reload the same screen
                          );
                        }),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                      decoration: BoxDecoration(
                        color: Colors.white, // background color
                        borderRadius: BorderRadius.circular(5), // corner radius
                      ),
                      child: Column(
                        children: [
                          buildInputData('Height', 'Cm', heightController),
                          const SizedBox(height: 15),
                          buildInputData('Weight', 'Kg', weightController),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        calculateBMI();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: appthemeDark, // background color
                          borderRadius: BorderRadius.circular(5), // corner radius
                        ),
                        child: Center(
                          child: Text(
                              bmiResult,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              )
                          ),
                        ),
                      ),
                    ), // column 1

                    const SizedBox(height: 30),
                    HistoryTitleWidget(title: 'Categories', items: []),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white, // background color
                        borderRadius: BorderRadius.circular(5), // corner radius
                      ),
                      child: Column(
                        children: [
                          buildCategories('Under Weight', 'Below 18.5'),
                          const SizedBox(height: 5),
                          buildCategories('Healthy Weight', '18.5 - 24.9'),
                          const SizedBox(height: 5),
                          buildCategories('Over Weight', '25.0 - 29.9'),
                          const SizedBox(height: 5),
                          buildCategories('Obese', '30.0 and above'),
                        ],
                      ),
                    ), // column 2
                  ],
                ),
              ),
            ],
          ),

            if (_isLoading)
              BlurLoader()
          ]
        ),
      ),
    );
  }

  buildTitleWidget(String title, List<Widget> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),

        Row(
            children: items
        )
      ],
    );
  }

  buildInputData(String type, String measure, TextEditingController tec) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$type:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
        Container(width: 50,),
        Flexible(
          child: SizedBox(
            height: 38,
            // width: 150,
            child: TextField(
              controller: tec,
              // keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Text(measure),
      ],
    );
  }

  buildCategories(String name, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(fontSize: 15)),
        SizedBox(
            width: 150,
            child: Text(
                ':     $value',
                style: const TextStyle(fontSize: 15)
            )
        ),
      ],
    );
  }

  void calculateBMI() {
    double height = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;

    print('height : $height');
    print('weight : $weight');

    if (height != 0 && weight != 0) {
      // Convert height from cm to meters (height in cm / 100)
      double heightInMeters = height / 100;
      // Calculate BMI
      double bmi = weight / (heightInMeters * heightInMeters);
      setState(() {
        bmiResult = "Your BMI : ${bmi.toStringAsFixed(2)}";
      });
    } else {
      setState(() {
        bmiResult = "Please enter valid values!";
      });
    }
  }

}
