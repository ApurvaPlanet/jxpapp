import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jxp_app/screens/Wellness/edit_record_popup.dart';

import '../constants/app_constants.dart';
import '../models/wellness_response.dart';

class ListWidget extends StatefulWidget {
  final List<WellnessDetail> wellnessData;

  final String module;

  const ListWidget({
    super.key,
    required this.wellnessData,
    required this.module,
  });

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {

  // Function to format the date as DD-MM-YYYY
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString); // Convert string to DateTime
    return DateFormat('dd-MM-yyyy').format(date); // Format to DD-MM-YYYY
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on the module type
    List<WellnessDetail> filteredData =
        widget.wellnessData.where((entry) {
          if (widget.module == 'activehours') {
            return entry.activityHours > 0;
          } else if (widget.module == 'standhours') {
            return entry.standHours > 0;
          } else {
            return entry.sleepHours > 0;
          }
        }).toList().reversed.toList();

    return Scaffold(
      backgroundColor: appBackground,
      body: Padding(
        padding: EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define columns based on module
            List<DataColumn> columns = [
              DataColumn(
                label: SizedBox(
                  width: constraints.maxWidth * 0.12,
                  child: Center(
                    child: Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ];

            // Add specific columns based on module
            if (widget.module == 'sleephours') {
              columns.addAll([
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Sleep\nTime",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Wake-up\nTime",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Sleep\nDuration",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            } else if (widget.module == 'activehours') {
              columns.addAll([
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Total\nHours",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Active\nHours",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            } else if (widget.module == 'standhours') {
              columns.addAll([
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Total\nHours",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.15,
                    child: Center(
                      child: Text(
                        "Standing\nHours",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            }

            // Add Edit column (Always present)
            columns.add(
              DataColumn(
                label: SizedBox(
                  width: constraints.maxWidth * 0.09,
                  child: Center(
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );

            return filteredData.isNotEmpty
                ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 12,
                        dataRowHeight: 35,
                        headingRowHeight: 45,
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => darkGrayColor,
                        ),
                        border: TableBorder.all(color: Colors.grey[400]!),
                        columns: columns,
                        rows:
                            filteredData.map((data) {
                              // Build row dynamically
                              List<DataCell> cells = [
                                DataCell(
                                  Center(
                                    child: Text(
                                      formatDate(data.date.toString()),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ];

                              if (widget.module == 'sleephours') {
                                cells.addAll([
                                  DataCell(
                                    Center(
                                      child: Text(
                                        data.sleepTime,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        data.wakeupTime,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        "${data.sleepHours} hr",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ]);
                              } else if (widget.module == 'activehours') {
                                cells.addAll([
                                  DataCell(
                                    Center(
                                      child: Text(
                                        "24 hr",
                                        style: TextStyle(fontSize: 12),
                                      ), // Assuming total hours is 24
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        "${data.activityHours} hr",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ]);
                              } else if (widget.module == 'standhours') {
                                cells.addAll([
                                  DataCell(
                                    Center(
                                      child: Text(
                                        "24 hr",
                                        style: TextStyle(fontSize: 12),
                                      ), // Assuming total hours is 24
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        "${data.standHours} hr",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ]);
                              }
                              // Edit button (Always present)
                              cells.add(
                                DataCell(
                                  Center(
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            if(widget.module == 'sleephours'){
                                              return EditRecord(
                                                  module: 'sleephours',
                                                  title: 'Edit Sleep Hours',
                                                  inputText1: 'Sleep Time',
                                                  inputText2: 'Wake-up Time',
                                                  wellnessDetail: data
                                              );
                                            }else if (widget.module == 'standhours'){
                                              return EditRecord(
                                                  module: 'standhours',
                                                  title: 'Edit Stand Hours',
                                                  inputText1: 'Stand Hours',
                                                  inputText2: '',
                                                  wellnessDetail: data
                                              );
                                            }else {
                                              return EditRecord(
                                                  module: 'activehours',
                                                  title: 'Edit Active Hours',
                                                  inputText1: 'Active Hours',
                                                  inputText2: '',
                                                  wellnessDetail: data
                                              );
                                            }
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.edit, size: 16),
                                    ),
                                  ),
                                ),
                              );
                              return DataRow(cells: cells);
                            }).toList(),
                      ),
                    ),
                  ),
                )
                : Center(
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                );
          },
        ),
      ),
    );
  }
}
