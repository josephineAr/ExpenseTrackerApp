import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SharedBudgetForm extends StatefulWidget {
  
  final int userId;

  const SharedBudgetForm({super.key, required this.userId});

  @override
  State<SharedBudgetForm> createState() => _SharedBudgetFormState();
}

class _SharedBudgetFormState extends State<SharedBudgetForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  Future<void> saveSharedBudget() async {
    final String name = _nameController.text.trim();
    final String amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);
    
    // Split emails and remove extra spaces
    final List<String> emails = _participantsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (name.isEmpty || amount == null || amount <= 0 || emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and add at least one participant"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.103.198.103:3000/budgets/create-shared'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'total_amount': amount,
          'category': 'Shared',
          'is_shared': true,
          'owner_id': widget.userId, 
          'participant_emails': emails,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Shared Budget Created Successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh the budget list
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? "Error creating shared budget");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
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
        title: const Text("New Shared Budget", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.purple,
              child: Icon(Icons.group_add, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Share Budgets with Friends and Family",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Text(
              "Participants can see and add transactions to this budget.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 30),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Group Budget Name",
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Total Budget Limit",
                prefixText: "UGX ",
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                prefixIcon: const Icon(Icons.payments),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _participantsController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Participant Emails",
                hintText: "user1@mail.com, user2@mail.com",
                helperText: "Separate emails with commas",
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : saveSharedBudget,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "CREATE SHARED BUDGET", 
                      style: TextStyle(color: Colors.white,  fontSize: 15)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}