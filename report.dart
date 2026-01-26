import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Reports extends StatefulWidget {
  final int userId; //  fetches user  data

  const Reports({super.key, required this.userId});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  Map<String, double> dataMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpenseData();
  }

  Future<void> fetchExpenseData() async {
  setState(() => isLoading = true);
  try {
   
    final response = await http.get(
      Uri.parse('http://10.103.198.103:3000/transactions/expenses/${widget.userId}'), 
    );

    if (response.statusCode == 200) {
      final List<dynamic> transactions = jsonDecode(response.body);
      Map<String, double> tempMap = {};

      for (var t in transactions) {
        
        String type = t['transactiontype'].toString().toLowerCase();
        
        if (type == "expenses" || type == "expense") {
          String category = t['category'] ?? "Other";
          double amount = double.tryParse(t['amount'].toString()) ?? 0;
          
          // Add to category total
          tempMap[category] = (tempMap[category] ?? 0) + amount;
        }
      }

      setState(() {
        dataMap = tempMap;
        isLoading = false;
      });
    }
  } catch (e) {
    debugPrint("Error: $e");
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "R E P O R T S",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : dataMap.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Expense Distribution",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      PieChart(
                        dataMap: dataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 2.2,
                        colorList: const [
                          Colors.purple,
                          Colors.deepPurpleAccent,
                          Colors.blue,
                          Colors.redAccent,
                          Colors.orange,
                          Colors.green,
                        ],
                        initialAngleInDegree: 0,
                        chartType: ChartType.ring, // pie chart for expenses
                        ringStrokeWidth: 32,
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.bottom,
                          showLegends: true,
                          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValueBackground: true,
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true,
                          decimalPlaces: 1,
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    "No expense data found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
    );
  }
}