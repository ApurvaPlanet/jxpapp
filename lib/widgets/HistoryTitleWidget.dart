import 'package:flutter/material.dart';

class HistoryTitleWidget extends StatelessWidget{

  String title;
  List<Widget> items;

  HistoryTitleWidget({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),

        Row(
            children: items
        )
      ],
    );
  }
  
}