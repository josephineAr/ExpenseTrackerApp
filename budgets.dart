import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'transactionmodel.dart';
import 'util/personalbudget.dart';
import 'util/shared.dart';

class Budget extends StatefulWidget {
  final List<Transactionmodel> transactions;
  final int userId;
  const Budget({super.key, required this.userId, required this.transactions});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  late Future<List<dynamic>> _budgetFuture;

  @override
  void initState() {
    super.initState();
    _budgetFuture = fetchBudgets();
  }

  Future<List<dynamic>> fetchBudgets() async {
    try {
      // fetches user id
      final response = await http.get(
        Uri.parse('http://10.103.198.103:3000/budgets/${widget.userId}')
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Check if your Backend is running! Error: $e');
    }
  }

  void _refreshBudgets() {
    setState(() {
      _budgetFuture = fetchBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("B U D G E T S", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.purple,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _budgetFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.purple));
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return buildAddBudgetInitial();
            }

            final budgets = snapshot.data!;
            return RefreshIndicator(
              color: Colors.purple,
              onRefresh: () async => _refreshBudgets(),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: budgets.length,
                itemBuilder: (context, index) => budgetCard(budgets[index]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTypeSelection,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget budgetCard(Map budget) {
    double total = double.tryParse(budget['total_amount'].toString()) ?? 0.0;
    double spent = double.tryParse(budget['current_spent'].toString()) ?? 0.0;
    double progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    double remaining = total - spent;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget['name'], 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(budget['category'] ?? "General", 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(budget['id'].toString()),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                color: progress > 0.9 ? Colors.red : Colors.purple,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat("Spent", "UGX ${spent.toStringAsFixed(0)}", Colors.red),
                _buildMiniStat("Remains", "UGX ${remaining.toStringAsFixed(0)}", Colors.green),
                _buildMiniStat("Limit", "UGX ${total.toStringAsFixed(0)}", Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String budgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Budget?"),
        content: const Text("This will remove this budget for you."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // delete via budget ID,
              final response = await http.delete(
                Uri.parse('http://10.103.198.103:3000/budgets/$budgetId')
              );
              if (response.statusCode == 200) _refreshBudgets();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget buildAddBudgetInitial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 70, color: Colors.purple.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text("No Budgets Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showTypeSelection,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("CREATE BUDGET", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showTypeSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Budget Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.person, color: Colors.white)),
                title: const Text("Personal Budget"),
                onTap: () {
                  Navigator.pop(context);
                  // Pass userId to the form
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalBudgetForm(userId: widget.userId))).then((_) => _refreshBudgets());
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.group, color: Colors.white)),
                title: const Text("Shared Budget"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SharedBudgetForm(userId: widget.userId))).then((_) => _refreshBudgets());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}