import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonalBudgetForm extends StatefulWidget {
  
  final int userId;

  const PersonalBudgetForm({super.key, required this.userId});

  @override
  State<PersonalBudgetForm> createState() => _PersonalBudgetFormState();
}

class _PersonalBudgetFormState extends State<PersonalBudgetForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isLoading = false; 

  final List<String> _categories = [
    'General', 
    'Food', 
    'Rent', 
    'Transport',  
    'Savings'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  
  Future<void> saveBudget() async {
    final String name = _nameController.text.trim();
    final String amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid name and amount"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.103.198.103:3000/budgets/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'total_amount': amount,
          'category': _selectedCategory,
          'is_shared': false,
          'user_id': widget.userId, 
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Budget Saved Successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // to refresh
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? "Failed to save budget");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Personal Budget", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.purple),
                SizedBox(width: 10),
                Text(
                  "Budget Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Set a limit for your personal spending in a specific category.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            // Name Input
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Budget Name",
                hintText: "e.g. Monthly Groceries",
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Budget Limit",
                hintText: "How much can you spend?",
                prefixIcon: const Icon(Icons.money),
                prefixText: "UGX ",
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 40),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _isLoading ? null : saveBudget,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "SAVE BUDGET", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}