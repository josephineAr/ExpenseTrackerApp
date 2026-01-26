import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AddTransaction extends StatefulWidget {
 
  final int userId;

  const AddTransaction({super.key, required this.userId});

  @override
  State<AddTransaction> createState() => _TransactionState();
}

class _TransactionState extends State<AddTransaction> {
  TextEditingController myAmountController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  String transactiontype = "Income";
  List<String> expensecategories = ["Food", "Transport", "Clothes", "Groceries", "Rent"];
  List<String> incomecategories = ["salary", "gig", "side business", "financial support"];
  String? selectedcategory;
  DateTime selectedDate = DateTime.now();

  List<dynamic> userBudgets = [];
  String? selectedBudgetId;
  bool isFetchingBudgets = false;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }
//budgets for user
  Future<void> _fetchBudgets() async {
    setState(() => isFetchingBudgets = true);
    try {
     
      final response = await http.get(Uri.parse('http://10.103.198.103:3000/budgets/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          userBudgets = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching budgets: $e");
    } finally {
      setState(() => isFetchingBudgets = false);
    }
  }

  Future<void> _handleSave() async {
    final amountText = myAmountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (transactiontype == "Expenses" && selectedBudgetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a budget to deduct from"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.103.198.103:3000/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'transactiontype': transactiontype,
          'category': selectedcategory ?? "Other",
          'date': selectedDate.toIso8601String(),
          'notes': notesController.text.trim(),
          'user_id': widget.userId, 
          'budget_id': transactiontype == "Expenses" ? int.parse(selectedBudgetId!) : null,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Transaction Saved!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception("Failed to save transaction");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("A D D  T R A N S A C T I O N", 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              controller: myAmountController,
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "UGX ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),

           //logic for Income/Expense
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text("Income"),
                    value: "Income",
                    groupValue: transactiontype,
                    activeColor: Colors.purple,
                    onChanged: (value) => setState(() => transactiontype = value.toString()),
                  ),
                  RadioListTile(
                    title: const Text("Expenses"),
                    value: "Expenses",
                    groupValue: transactiontype,
                    activeColor: Colors.purple,
                    onChanged: (value) => setState(() {
                      transactiontype = value.toString();
                      selectedcategory = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedcategory,
              hint: const Text("Select Category"),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              onChanged: (value) => setState(() => selectedcategory = value),
              items: (transactiontype == "Income" ? incomecategories : expensecategories)
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
            ),

            if (transactiontype == "Expenses") ...[
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedBudgetId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: "Deduct from Budget",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.purple),
                ),
                hint: Text(isFetchingBudgets ? "Loading Budgets..." : "Choose Budget"),
                items: userBudgets.map((budget) {
                  return DropdownMenuItem<String>(
                    value: budget['id'].toString(),
                    child: Text("${budget['name']} (Limit: ${budget['total_amount']})"),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedBudgetId = value),
              ),
            ],

            const SizedBox(height: 15),
            
            // Date 
            Card(
              elevation: 0,
              color: Colors.purple.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.purple),
                title: Text("Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: const Text("S A V E", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}